import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../shared/theme/doctor_tokens.dart';
import '../../../../shared/widgets/doctor_home_header.dart';
import '../../../../shared/widgets/quick_actions_row.dart';
import '../../../../shared/widgets/todays_overview_card.dart';
import '../../../features/finance/domain/entities/doctor_finance_snapshot.dart';

/// Composed section 2b of the doctor Home tab: gradient header, Today's
/// Overview stats, and Quick Actions.
///
/// Intended to sit at the top of the same scrollable Home column as the
/// queue widgets (pending requests / today's appointments / next
/// consultation). Not wired as a live entry point yet — callers must
/// compose it explicitly.
class DoctorHomeDashboardSection extends StatelessWidget {
  const DoctorHomeDashboardSection({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.isAvailable,
    required this.onAvailabilityChanged,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onNotificationsTap,
    required this.appointmentCount,
    required this.pendingCount,
    required this.completedCount,
    required this.earningsPkr,
    required this.onAppointmentsTap,
    required this.onPendingTap,
    required this.onCompletedTap,
    required this.onEarningsTap,
    required this.onScheduleTap,
    required this.onPatientsTap,
    required this.onPrescribeTap,
    this.imageAsset,
    this.notificationCount = 0,
    this.isUpdatingAvailability = false,
    this.onProfileTap,
  });

  final String doctorId;
  final String doctorName;
  final String specialty;
  final String? imageAsset;
  final bool isAvailable;
  final ValueChanged<bool> onAvailabilityChanged;
  final bool isUpdatingAvailability;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final VoidCallback onNotificationsTap;
  final VoidCallback? onProfileTap;
  final int notificationCount;

  final int appointmentCount;
  final int pendingCount;
  final int completedCount;
  final int earningsPkr;
  final VoidCallback onAppointmentsTap;
  final VoidCallback onPendingTap;
  final VoidCallback onCompletedTap;
  final VoidCallback onEarningsTap;

  final VoidCallback onScheduleTap;
  final VoidCallback onPatientsTap;
  final VoidCallback onPrescribeTap;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      OverviewMetric(
        kind: OverviewMetricKind.appointments,
        value: '$appointmentCount',
        onTap: onAppointmentsTap,
      ),
      OverviewMetric(
        kind: OverviewMetricKind.pending,
        value: '$pendingCount',
        onTap: onPendingTap,
      ),
      OverviewMetric(
        kind: OverviewMetricKind.completed,
        value: '$completedCount',
        onTap: onCompletedTap,
      ),
      OverviewMetric(
        kind: OverviewMetricKind.earnings,
        value: _formatCompactPkr(earningsPkr),
        onTap: onEarningsTap,
      ),
    ];

    final actions = [
      QuickActionItem(kind: QuickActionKind.schedule, onTap: onScheduleTap),
      QuickActionItem(kind: QuickActionKind.patients, onTap: onPatientsTap),
      QuickActionItem(kind: QuickActionKind.prescribe, onTap: onPrescribeTap),
      QuickActionItem(kind: QuickActionKind.earnings, onTap: onEarningsTap),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _motion(
          context,
          DoctorHomeHeader(
            doctorId: doctorId,
            doctorName: doctorName,
            specialty: specialty,
            imageAsset: imageAsset,
            isAvailable: isAvailable,
            isUpdatingAvailability: isUpdatingAvailability,
            onAvailabilityChanged: onAvailabilityChanged,
            isDarkMode: isDarkMode,
            onThemeToggle: onThemeToggle,
            onNotificationsTap: onNotificationsTap,
            onProfileTap: onProfileTap,
            notificationCount: notificationCount,
          ),
          delay: 0,
        ),
        Transform.translate(
          offset: const Offset(0, -18),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DoctorSpacing.screenHorizontal,
            ),
            child: _motion(
              context,
              TodaysOverviewCard(
                metrics: metrics,
                onAnalyticsTap: onEarningsTap,
              ),
              delay: 50,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DoctorSpacing.screenHorizontal,
            4,
            DoctorSpacing.screenHorizontal,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Actions',
                style: TextStyle(
                  color: DoctorColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              _motion(context, QuickActionsRow(actions: actions), delay: 90),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _motion(BuildContext context, Widget child, {required int delay}) {
  if (MediaQuery.disableAnimationsOf(context)) return child;
  return child
      .animate(delay: Duration(milliseconds: delay))
      .fadeIn(duration: 220.ms, curve: Curves.easeOutCubic)
      .slideY(
        begin: 0.025,
        end: 0,
        duration: 240.ms,
        curve: Curves.easeOutCubic,
      );
}

String _formatCompactPkr(int rupees) {
  return formatPkr(rupees).replaceFirst('PKR ', 'Rs. ');
}
