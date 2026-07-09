import 'package:flutter/material.dart';

import '../../../../core/layout/app_layout.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/appointment_record.dart';
import '../../domain/entities/consultation_type.dart';
import '../controllers/appointment_list_controller.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({
    super.key,
    required this.controller,
    required this.patientId,
  });

  final AppointmentListController controller;
  final String patientId;

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);

    Future<void>.microtask(
      () => widget.controller.load(patientId: widget.patientId),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    widget.controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshAppointments() {
    return widget.controller.refresh(widget.patientId);
  }

  void _showAppointmentDetails(AppointmentRecord appointment) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AppointmentDetailsSheet(appointment: appointment);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('My Appointments'),
          bottom: const TabBar(
            indicatorColor: AppTheme.primary,
            indicatorWeight: 3,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textMuted,
            labelStyle: TextStyle(fontWeight: FontWeight.w900),
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Previous'),
            ],
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.maxMobileContentWidth,
              ),
              child: _buildContent(controller),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AppointmentListController controller) {
    if ((controller.isInitial || controller.isLoading) &&
        controller.appointments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.hasError && controller.appointments.isEmpty) {
      return _ErrorState(
        message:
            controller.errorMessage ??
            'Could not load appointments. Please try again.',
        onRetry: () =>
            controller.load(patientId: widget.patientId, forceRefresh: true),
      );
    }

    if (controller.isEmpty) {
      return _EmptyAppointmentsState(onRefresh: _refreshAppointments);
    }

    return TabBarView(
      children: [
        _AppointmentList(
          appointments: controller.upcomingAppointments,
          emptyIcon: Icons.event_available_outlined,
          emptyTitle: 'No upcoming appointments',
          emptyMessage:
              'Appointments you book will appear here with their confirmed date and time.',
          onRefresh: _refreshAppointments,
          onAppointmentTap: _showAppointmentDetails,
        ),
        _AppointmentList(
          appointments: controller.historyAppointments,
          emptyIcon: Icons.history_rounded,
          emptyTitle: 'No previous appointments',
          emptyMessage:
              'Completed and cancelled consultations will appear here.',
          onRefresh: _refreshAppointments,
          onAppointmentTap: _showAppointmentDetails,
        ),
      ],
    );
  }
}

class _AppointmentList extends StatelessWidget {
  const _AppointmentList({
    required this.appointments,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.onRefresh,
    required this.onAppointmentTap,
  });

  final List<AppointmentRecord> appointments;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final ValueChanged<AppointmentRecord> onAppointmentTap;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 80, 24, 32),
          children: [
            _TabEmptyState(
              icon: emptyIcon,
              title: emptyTitle,
              message: emptyMessage,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppLayout.horizontalPadding(context),
          20,
          AppLayout.horizontalPadding(context),
          32,
        ),
        itemCount: appointments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final appointment = appointments[index];

          return _AppointmentCard(
            appointment: appointment,
            onTap: () => onAppointmentTap(appointment),
          );
        },
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment, required this.onTap});

  final AppointmentRecord appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(appointment.status);

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DoctorImage(imageAsset: appointment.doctorImageAsset),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.doctorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.doctorSpecialty,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(
                    label: appointment.status.title,
                    color: statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppTheme.border),
              const SizedBox(height: 14),
              Wrap(
                spacing: 14,
                runSpacing: 10,
                children: [
                  _AppointmentMeta(
                    icon: Icons.calendar_month_outlined,
                    label: appointment.dateLabel,
                  ),
                  _AppointmentMeta(
                    icon: Icons.schedule_rounded,
                    label: appointment.timeLabel,
                  ),
                  _AppointmentMeta(
                    icon: appointment.consultationType == ConsultationType.video
                        ? Icons.videocam_outlined
                        : Icons.call_outlined,
                    label: appointment.consultationType.title,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    'Rs. ${appointment.totalFee}',
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.visibility_outlined, size: 19),
                    label: const Text('View details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorImage extends StatelessWidget {
  const _DoctorImage({required this.imageAsset});

  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 64,
        height: 64,
        color: AppTheme.softTeal,
        child: Image.asset(
          imageAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.person_rounded,
              color: AppTheme.primary,
              size: 34,
            );
          },
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AppointmentMeta extends StatelessWidget {
  const _AppointmentMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AppointmentDetailsSheet extends StatelessWidget {
  const _AppointmentDetailsSheet({required this.appointment});

  final AppointmentRecord appointment;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(appointment.status);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXLarge),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _DoctorImage(imageAsset: appointment.doctorImageAsset),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.doctorName,
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.doctorSpecialty,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(
                    label: appointment.status.title,
                    color: statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _DetailRow(
                icon: Icons.calendar_month_outlined,
                title: 'Date',
                value: appointment.dateLabel,
              ),
              _DetailRow(
                icon: Icons.schedule_rounded,
                title: 'Time',
                value: appointment.timeLabel,
              ),
              _DetailRow(
                icon: appointment.consultationType == ConsultationType.video
                    ? Icons.videocam_outlined
                    : Icons.call_outlined,
                title: 'Consultation',
                value: appointment.consultationType.title,
              ),
              _DetailRow(
                icon: Icons.payments_outlined,
                title: 'Consultation fee',
                value: 'Rs. ${appointment.totalFee}',
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.softTeal,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 54,
              color: AppTheme.danger,
            ),
            const SizedBox(height: 14),
            const Text(
              'Appointments unavailable',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMuted, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class _EmptyAppointmentsState extends StatelessWidget {
  const _EmptyAppointmentsState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(26, 90, 26, 32),
        children: const [
          _TabEmptyState(
            icon: Icons.calendar_month_outlined,
            title: 'No appointments yet',
            message:
                'Book a consultation with a doctor and it will appear here.',
          ),
        ],
      ),
    );
  }
}

class _TabEmptyState extends StatelessWidget {
  const _TabEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: const BoxDecoration(
            color: AppTheme.softTeal,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 40, color: AppTheme.primary),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textMuted, height: 1.45),
        ),
      ],
    );
  }
}

Color _statusColor(AppointmentStatus status) {
  return switch (status) {
    AppointmentStatus.confirmed => AppTheme.success,
    AppointmentStatus.completed => AppTheme.primary,
    AppointmentStatus.cancelled => AppTheme.danger,
  };
}
