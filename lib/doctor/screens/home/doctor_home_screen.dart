import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../shared/theme/doctor_tokens.dart';
import '../../../shared/widgets/doctor_bottom_nav_bar.dart';
import '../../features/dashboard/domain/entities/doctor_dashboard_snapshot.dart';
import '../../features/dashboard/presentation/controllers/doctor_dashboard_controller.dart';
import '../../features/finance/presentation/controllers/doctor_finance_controller.dart';
import '../appointments/doctor_appointments_screen.dart';
import '../consultation/doctor_consultation_screen.dart';
import '../dashboard/widgets/doctor_patients_tab.dart';
import '../earnings/doctor_earnings_screen.dart';
import '../patients/doctor_patient_profile_screen.dart';
import '../profile/doctor_profile_screen.dart';
import 'widgets/incoming_requests_list.dart';
import 'widgets/next_consultation_card.dart';
import 'widgets/todays_appointment_tile.dart';

/// Doctor Home shell: an [IndexedStack] of the five doctor tabs behind a
/// [DoctorBottomNavBar], so switching tabs never rebuilds or loses scroll
/// position on the others. Tab 0 is the appointment-queue feed built from the
/// shared/doctor widgets; the other tabs reuse the existing doctor screens.
///
/// Controllers are resolved once via `get_it` (or injected for tests); this
/// screen never touches repositories directly.
class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    this.dashboardController,
    this.financeController,
  });

  final String doctorId;
  final String doctorName;
  final DoctorDashboardController? dashboardController;
  final DoctorFinanceController? financeController;

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  static const _homeIndex = 0;
  static const _scheduleIndex = 1;
  static const _patientsIndex = 2;
  static const _earningsIndex = 3;
  static const _profileIndex = 4;

  late final DoctorDashboardController _dashboard;
  late final DoctorFinanceController _finance;
  late final bool _ownsDashboard;
  late final bool _ownsFinance;

  int _selectedIndex = _homeIndex;

  @override
  void initState() {
    super.initState();
    _ownsDashboard = widget.dashboardController == null;
    _ownsFinance = widget.financeController == null;
    _dashboard =
        widget.dashboardController ?? sl<DoctorDashboardController>();
    _finance = widget.financeController ?? sl<DoctorFinanceController>();
    _load();
  }

  @override
  void dispose() {
    if (_ownsDashboard) _dashboard.dispose();
    if (_ownsFinance) _finance.dispose();
    super.dispose();
  }

  void _load({bool force = false}) {
    Future<void>.microtask(() async {
      await Future.wait([
        _dashboard.load(doctorId: widget.doctorId, force: force),
        _finance.load(doctorId: widget.doctorId, force: force),
      ]);
    });
  }

  void _selectTab(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  void _openPatient(DoctorPatientSummary patient) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DoctorPatientProfileScreen(
          patientName: patient.name,
          patientAge: patient.age,
          patientGender: patient.gender,
          appointmentId: patient.id,
          imageAsset: patient.imageAsset,
        ),
      ),
    );
  }

  Future<void> _handleAppointment(DoctorAppointmentRecord appointment) async {
    if (appointment.status == DoctorAppointmentStatus.completed) {
      _openPatient(appointment.patient);
      return;
    }
    if (appointment.type == DoctorConsultationType.clinic) {
      _openPatient(appointment.patient);
      return;
    }
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => DoctorConsultationScreen(
          patientName: appointment.patient.name,
          patientAge: appointment.patient.age,
          patientGender: appointment.patient.gender,
          appointmentId: appointment.id,
          isVideo: appointment.type == DoctorConsultationType.video,
        ),
      ),
    );
    if (!mounted) return;
    if (completed == true) {
      await _dashboard.updateStatus(
        appointment.id,
        DoctorAppointmentStatus.completed,
      );
    } else if (appointment.status == DoctorAppointmentStatus.ready) {
      await _dashboard.updateStatus(
        appointment.id,
        DoctorAppointmentStatus.inProgress,
      );
    }
  }

  Future<void> _confirmReject(DoctorAppointmentRecord request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.event_busy_rounded),
        title: const Text('Reject request?'),
        content: Text(
          '${request.patient.name} will be notified that this request was declined.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep request'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: DoctorColors.danger,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _dashboard.rejectRequest(request.id);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      _DoctorHomeQueue(
        controller: _dashboard,
        onPatientTap: _openPatient,
        onAppointmentAction: _handleAppointment,
        onAccept: (request) => _dashboard.acceptRequest(request.id),
        onReject: _confirmReject,
        onSeeAllRequests: () {
          _dashboard.selectAppointmentFilter(DoctorAppointmentFilter.pending);
          _selectTab(_scheduleIndex);
        },
        onSeeAllAppointments: () {
          _dashboard.selectAppointmentFilter(DoctorAppointmentFilter.all);
          _selectTab(_scheduleIndex);
        },
      ),
      DoctorAppointmentsScreen(
        controller: _dashboard,
        onBack: () => _selectTab(_homeIndex),
        onPatientTap: _openPatient,
        onAppointmentAction: _handleAppointment,
      ),
      DoctorPatientsTab(controller: _dashboard, onPatientTap: _openPatient),
      DoctorEarningsScreen(
        controller: _finance,
        dashboardController: _dashboard,
      ),
      const DoctorProfileScreen(showBackButton: false),
    ];

    return Scaffold(
      backgroundColor: DoctorColors.background,
      body: IndexedStack(index: _selectedIndex, children: tabs),
      bottomNavigationBar: DoctorBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _selectTab,
      ),
    );
  }
}

class _DoctorHomeQueue extends StatelessWidget {
  const _DoctorHomeQueue({
    required this.controller,
    required this.onPatientTap,
    required this.onAppointmentAction,
    required this.onAccept,
    required this.onReject,
    required this.onSeeAllRequests,
    required this.onSeeAllAppointments,
  });

  final DoctorDashboardController controller;
  final ValueChanged<DoctorPatientSummary> onPatientTap;
  final ValueChanged<DoctorAppointmentRecord> onAppointmentAction;
  final ValueChanged<DoctorAppointmentRecord> onAccept;
  final ValueChanged<DoctorAppointmentRecord> onReject;
  final VoidCallback onSeeAllRequests;
  final VoidCallback onSeeAllAppointments;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isLoading && controller.snapshot == null) {
          return const _CenteredMessage.loading();
        }
        if (controller.status == DoctorDashboardLoadStatus.failure &&
            controller.snapshot == null) {
          return _CenteredMessage.error(
            message: controller.errorMessage ?? 'Could not load your queue.',
            onRetry: controller.refresh,
          );
        }
        if (controller.snapshot == null) {
          return const _CenteredMessage.loading();
        }

        final requests = controller.pendingRequests.toList(growable: false);
        final active = controller.todayAppointments
            .where(
              (item) =>
                  item.status != DoctorAppointmentStatus.pending &&
                  item.status != DoctorAppointmentStatus.completed &&
                  item.status != DoctorAppointmentStatus.cancelled,
            )
            .toList(growable: false);
        final nextConsultation = active
            .where(
              (item) =>
                  item.status == DoctorAppointmentStatus.ready ||
                  item.status == DoctorAppointmentStatus.confirmed,
            )
            .fold<DoctorAppointmentRecord?>(
              null,
              (soonest, item) =>
                  soonest == null ||
                      item.scheduledAt.isBefore(soonest.scheduledAt)
                  ? item
                  : soonest,
            );

        return SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontal = constraints.maxWidth > 600 ? 24.0 : 16.0;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: RefreshIndicator(
                    color: DoctorColors.primary,
                    onRefresh: controller.refresh,
                    child: ListView(
                      key: const PageStorageKey('doctor-home-queue'),
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 28),
                      children: [
                        _SectionHeader(
                          title: 'Pending Requests',
                          count: requests.length,
                          onSeeAll: requests.isEmpty ? null : onSeeAllRequests,
                        ),
                        const SizedBox(height: 10),
                        IncomingRequestsList(
                          requests: requests,
                          isProcessing: (request) =>
                              controller.isUpdating(request.id),
                          onAccept: onAccept,
                          onReject: onReject,
                          onPatientTap: (request) => onPatientTap(request.patient),
                        ),
                        const SizedBox(height: 22),
                        _SectionHeader(
                          title: "Today's Appointments",
                          onSeeAll: active.isEmpty ? null : onSeeAllAppointments,
                        ),
                        const SizedBox(height: 10),
                        if (active.isEmpty)
                          const _EmptyCard(
                            icon: Icons.event_available_rounded,
                            title: 'No appointments today',
                            subtitle:
                                'Your confirmed consultations will appear here.',
                          )
                        else
                          for (final appointment in active) ...[
                            TodaysAppointmentTile(
                              appointment: appointment,
                              isLoading: controller.isUpdating(appointment.id),
                              onPatientTap: () => onPatientTap(appointment.patient),
                              onAction: () => onAppointmentAction(appointment),
                            ),
                            const SizedBox(height: DoctorSpacing.cardGap - 2),
                          ],
                        const SizedBox(height: 8),
                        NextConsultationCard(
                          appointment: nextConsultation,
                          onStart: () {
                            if (nextConsultation != null) {
                              onAppointmentAction(nextConsultation);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.count, this.onSeeAll});

  final String title;
  final int? count;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: DoctorColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (count != null && count! > 0) ...[
          const SizedBox(width: 8),
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: DoctorColors.danger,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: DoctorColors.primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: const Size(0, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'See All',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(DoctorSpacing.radiusCard),
        boxShadow: DoctorColors.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: DoctorColors.primary, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: DoctorColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: DoctorColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage.loading() : message = null, onRetry = null;
  const _CenteredMessage.error({required this.message, required this.onRetry});

  final String? message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const SafeArea(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 42,
                color: DoctorColors.danger,
              ),
              const SizedBox(height: 12),
              Text(message!, textAlign: TextAlign.center),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
