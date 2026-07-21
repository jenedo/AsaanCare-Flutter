import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../features/dashboard/domain/entities/doctor_dashboard_snapshot.dart';
import '../../../features/dashboard/presentation/controllers/doctor_dashboard_controller.dart';
import '../../../features/finance/domain/entities/doctor_finance_snapshot.dart';
import '../../../features/finance/presentation/controllers/doctor_finance_controller.dart';

const _doctorTeal = Color(0xFF006D5B);
const _doctorTealDark = Color(0xFF005A4B);
const _doctorTealMid = Color(0xFF007568);
const _doctorMint = Color(0xFFE9F8F5);
const _doctorBg = Color(0xFFF5F7F6);
const _doctorText = Color(0xFF1F3438);
const _doctorMuted = Color(0xFF6F8588);
const _doctorBorder = Color(0xFFE3ECEA);
const _doctorWarning = Color(0xFFFF9800);
const _doctorSuccess = Color(0xFF21B66F);
const _doctorDanger = Color(0xFFF44336);
const _doctorBlue = Color(0xFF4F6BFF);
const _doctorPurple = Color(0xFF9C4DFF);

const _cardShadow = [
  BoxShadow(color: Color(0x140D5C63), blurRadius: 16, offset: Offset(0, 5)),
];

class DoctorHomeContent extends StatelessWidget {
  const DoctorHomeContent({
    super.key,
    required this.doctorName,
    required this.dashboardController,
    required this.financeController,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onProfileTap,
    required this.onNotificationsTap,
    required this.onAppointmentsTap,
    required this.onPendingTap,
    required this.onCompletedTap,
    required this.onScheduleTap,
    required this.onPatientsTap,
    required this.onPrescribeTap,
    required this.onEarningsTap,
    required this.onPatientTap,
    required this.onAppointmentAction,
  });

  final String doctorName;
  final DoctorDashboardController dashboardController;
  final DoctorFinanceController financeController;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onAppointmentsTap;
  final VoidCallback onPendingTap;
  final VoidCallback onCompletedTap;
  final VoidCallback onScheduleTap;
  final VoidCallback onPatientsTap;
  final VoidCallback onPrescribeTap;
  final VoidCallback onEarningsTap;
  final ValueChanged<DoctorPatientSummary> onPatientTap;
  final ValueChanged<DoctorAppointmentRecord> onAppointmentAction;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([dashboardController, financeController]),
      builder: (context, _) {
        if (dashboardController.isLoading &&
            dashboardController.snapshot == null) {
          return const _DashboardLoading();
        }
        if (dashboardController.status == DoctorDashboardLoadStatus.failure &&
            dashboardController.snapshot == null) {
          return _DashboardFailure(
            message:
                dashboardController.errorMessage ?? 'Could not load dashboard.',
            onRetry: dashboardController.refresh,
          );
        }
        final snapshot = dashboardController.snapshot;
        if (snapshot == null) return const _DashboardLoading();
        final finance = financeController.snapshot;
        final appointments = dashboardController.todayAppointments
            .where(
              (item) =>
                  item.status != DoctorAppointmentStatus.pending &&
                  item.status != DoctorAppointmentStatus.completed &&
                  item.status != DoctorAppointmentStatus.cancelled,
            )
            .take(3)
            .toList(growable: false);
        final requests = dashboardController.pendingRequests
            .take(2)
            .toList(growable: false);
        final nextConsultation = appointments.isEmpty
            ? null
            : appointments.first;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final pageBg = isDark
            ? Theme.of(context).colorScheme.surface
            : _doctorBg;

        return ColoredBox(
          color: pageBg,
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: RefreshIndicator(
                  color: _doctorTeal,
                  onRefresh: () async {
                    await Future.wait([
                      dashboardController.refresh(),
                      financeController.refresh(),
                    ]);
                  },
                  child: CustomScrollView(
                    key: const PageStorageKey('doctor-home-scroll'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _DoctorHeader(
                          profile: snapshot.profile,
                          fallbackName: doctorName,
                          notificationCount:
                              dashboardController.notificationCount,
                          isDarkMode: isDarkMode,
                          onThemeToggle: onThemeToggle,
                          onProfileTap: onProfileTap,
                          onNotificationsTap: onNotificationsTap,
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                        sliver: SliverList.list(
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -18),
                              child: _OverviewCard(
                                appointmentCount: dashboardController
                                    .todayAppointments
                                    .length,
                                pendingCount:
                                    dashboardController.pendingRequests.length,
                                completedCount:
                                    dashboardController.completedCount,
                                earningsPkr: finance?.totalEarningsPkr ?? 0,
                                onAppointmentsTap: onAppointmentsTap,
                                onPendingTap: onPendingTap,
                                onCompletedTap: onCompletedTap,
                                onEarningsTap: onEarningsTap,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Quick Actions',
                              style: TextStyle(
                                color: isDark
                                    ? Theme.of(context).colorScheme.onSurface
                                    : _doctorText,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _QuickActions(
                              onScheduleTap: onScheduleTap,
                              onPatientsTap: onPatientsTap,
                              onPrescribeTap: onPrescribeTap,
                              onEarningsTap: onEarningsTap,
                            ),
                            const SizedBox(height: 22),
                            _SectionHeader(
                              title: 'Pending Requests',
                              count: dashboardController.pendingRequests.length,
                              actionLabel: 'See All',
                              onAction: onPendingTap,
                            ),
                            const SizedBox(height: 10),
                            if (requests.isEmpty)
                              const _EmptyCard(
                                icon: Icons.task_alt_rounded,
                                title: 'No pending requests',
                                subtitle:
                                    'New consultation requests will appear here.',
                              )
                            else
                              for (final request in requests) ...[
                                _PendingRequestCard(
                                  appointment: request,
                                  isLoading: dashboardController.isUpdating(
                                    request.id,
                                  ),
                                  onPatientTap: () =>
                                      onPatientTap(request.patient),
                                  onAccept: () => dashboardController
                                      .acceptRequest(request.id),
                                  onReject: () =>
                                      _confirmReject(context, request),
                                ),
                                const SizedBox(height: 10),
                              ],
                            const SizedBox(height: 14),
                            _SectionHeader(
                              title: "Today's Appointments",
                              actionLabel: 'See All',
                              onAction: onAppointmentsTap,
                            ),
                            const SizedBox(height: 10),
                            if (appointments.isEmpty)
                              const _EmptyCard(
                                icon: Icons.event_available_rounded,
                                title: 'No appointments today',
                                subtitle:
                                    'Your confirmed consultations will appear here.',
                              )
                            else
                              for (final appointment in appointments) ...[
                                _AppointmentCard(
                                  appointment: appointment,
                                  onPatientTap: () =>
                                      onPatientTap(appointment.patient),
                                  onAction: () =>
                                      onAppointmentAction(appointment),
                                  isLoading: dashboardController.isUpdating(
                                    appointment.id,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            if (nextConsultation != null) ...[
                              const SizedBox(height: 8),
                              _NextConsultationCard(
                                appointment: nextConsultation,
                                onStart: () =>
                                    onAppointmentAction(nextConsultation),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmReject(
    BuildContext context,
    DoctorAppointmentRecord request,
  ) async {
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
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirmed == true) await dashboardController.rejectRequest(request.id);
  }
}

class _DoctorHeader extends StatelessWidget {
  const _DoctorHeader({
    required this.profile,
    required this.fallbackName,
    required this.notificationCount,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onProfileTap,
    required this.onNotificationsTap,
  });

  final DoctorProfileSummary profile;
  final String fallbackName;
  final int notificationCount;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final name = fallbackName.trim().isEmpty ? profile.name : fallbackName;
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 34),
      decoration: const BoxDecoration(
        color: _doctorTeal,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Semantics(
                button: true,
                label: 'Open doctor profile',
                child: InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: onProfileTap,
                  child: CircleAvatar(
                    key: const ValueKey('doctor-profile-image'),
                    radius: 24,
                    backgroundColor: const Color(0xFF48B7AC),
                    backgroundImage: AssetImage(profile.imageAsset),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorGreetingForHour(DateTime.now().hour).toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFC8EEE9),
                        fontSize: 11,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFD8F3F0),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _HeaderButton(
                tooltip: isDarkMode ? 'Use light theme' : 'Use dark theme',
                icon: isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                onTap: onThemeToggle,
              ),
              const SizedBox(width: 8),
              Badge(
                isLabelVisible: notificationCount > 0,
                backgroundColor: _doctorDanger,
                label: Text(
                  notificationCount > 9 ? '9+' : '$notificationCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: _HeaderButton(
                  tooltip: 'Open notifications',
                  icon: Icons.notifications_none_rounded,
                  onTap: onNotificationsTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AvailabilityStrip(initialValue: profile.isOnline),
        ],
      ),
    );
    return _motion(context, content, delay: 0);
  }
}

class _AvailabilityStrip extends StatefulWidget {
  const _AvailabilityStrip({required this.initialValue});

  final bool initialValue;

  @override
  State<_AvailabilityStrip> createState() => _AvailabilityStripState();
}

class _AvailabilityStripState extends State<_AvailabilityStrip> {
  late bool _available = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.only(left: 14, right: 8),
      decoration: BoxDecoration(
        color: _doctorTealMid,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: _available
                  ? const Color(0xFF40E38F)
                  : Colors.white.withValues(alpha: 0.55),
              shape: BoxShape.circle,
              boxShadow: _available
                  ? const [BoxShadow(color: Color(0x6639E68C), blurRadius: 7)]
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _available
                  ? 'Available for Consultation'
                  : 'Not Available for Consultation',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch.adaptive(
            key: const ValueKey('doctor-availability-switch'),
            value: _available,
            activeTrackColor: Colors.white,
            activeThumbColor: _doctorTeal,
            inactiveTrackColor: const Color(0xFF8FB7B2),
            inactiveThumbColor: Colors.white,
            onChanged: (value) => setState(() => _available = value),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: 0.14),
    shape: const CircleBorder(),
    child: IconButton(
      tooltip: tooltip,
      color: Colors.white,
      iconSize: 20,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      onPressed: onTap,
      icon: Icon(icon),
    ),
  );
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.appointmentCount,
    required this.pendingCount,
    required this.completedCount,
    required this.earningsPkr,
    required this.onAppointmentsTap,
    required this.onPendingTap,
    required this.onCompletedTap,
    required this.onEarningsTap,
  });
  final int appointmentCount;
  final int pendingCount;
  final int completedCount;
  final int earningsPkr;
  final VoidCallback onAppointmentsTap;
  final VoidCallback onPendingTap;
  final VoidCallback onCompletedTap;
  final VoidCallback onEarningsTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final metrics = [
      (
        Icons.calendar_today_outlined,
        '$appointmentCount',
        'Appointments',
        onAppointmentsTap,
        _doctorTeal,
        _doctorMint,
      ),
      (
        Icons.schedule_rounded,
        '$pendingCount',
        'Pending',
        onPendingTap,
        _doctorWarning,
        const Color(0xFFFFF5E6),
      ),
      (
        Icons.task_alt_rounded,
        '$completedCount',
        'Completed',
        onCompletedTap,
        _doctorSuccess,
        const Color(0xFFEAF8EF),
      ),
      (
        Icons.account_balance_wallet_outlined,
        _formatCompactPkr(earningsPkr),
        'Earnings',
        onEarningsTap,
        _doctorTeal,
        _doctorMint,
      ),
    ];
    final card = Container(
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDark ? null : _cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Today's Overview",
                      style: TextStyle(
                        color: isDark ? colors.onSurface : _doctorText,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? colors.primaryContainer : _doctorMint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatDate(DateTime.now()),
                      style: TextStyle(
                        color: isDark
                            ? colors.onPrimaryContainer
                            : _doctorTealDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (var index = 0; index < metrics.length; index++)
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: 'Open ${metrics[index].$3}',
                        child: InkWell(
                          key: ValueKey(
                            'overview-${metrics[index].$3.toLowerCase()}',
                          ),
                          borderRadius: BorderRadius.circular(12),
                          onTap: metrics[index].$4,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? colors.surfaceContainerHigh
                                        : metrics[index].$6,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    metrics[index].$1,
                                    color: metrics[index].$5,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    metrics[index].$2,
                                    style: TextStyle(
                                      color: isDark
                                          ? colors.onSurface
                                          : _doctorText,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    metrics[index].$3,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: isDark
                                          ? colors.onSurfaceVariant
                                          : _doctorMuted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                height: 1,
                color: isDark ? colors.outlineVariant : _doctorBorder,
              ),
              TextButton(
                key: const ValueKey('view-detailed-analytics'),
                onPressed: onEarningsTap,
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? colors.primary : _doctorTealDark,
                  minimumSize: const Size(0, 40),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Detailed Analytics',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return _motion(context, card, delay: 50);
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onScheduleTap,
    required this.onPatientsTap,
    required this.onPrescribeTap,
    required this.onEarningsTap,
  });
  final VoidCallback onScheduleTap;
  final VoidCallback onPatientsTap;
  final VoidCallback onPrescribeTap;
  final VoidCallback onEarningsTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actions = [
      (
        Icons.calendar_month_outlined,
        'Schedule',
        _doctorTeal,
        const Color(0xFFE7F6F4),
        onScheduleTap,
      ),
      (
        Icons.group_outlined,
        'Patients',
        _doctorBlue,
        const Color(0xFFEDF1FF),
        onPatientsTap,
      ),
      (
        Icons.receipt_long_outlined,
        'Prescribe',
        _doctorPurple,
        const Color(0xFFF5EDFF),
        onPrescribeTap,
      ),
      (
        Icons.attach_money_rounded,
        'Earnings',
        const Color(0xFFE67E00),
        const Color(0xFFFFF2E5),
        onEarningsTap,
      ),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : _cardShadow,
      ),
      child: Row(
        children: [
          for (final action in actions)
            Expanded(
              child: Semantics(
                button: true,
                label: action.$2,
                child: InkWell(
                  key: ValueKey('quick-${action.$2.toLowerCase()}'),
                  borderRadius: BorderRadius.circular(12),
                  onTap: action.$5,
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark
                              ? colors.surfaceContainerHigh
                              : action.$4,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(action.$1, color: action.$3, size: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? colors.onSurface : _doctorText,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.count,
    this.actionLabel,
    this.onAction,
  });
  final String title;
  final int? count;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              color: isDark ? colors.onSurface : _doctorText,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _doctorDanger,
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
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: isDark ? colors.primary : _doctorTealDark,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: const Size(0, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          ),
      ],
    );
  }
}

class _PendingRequestCard extends StatelessWidget {
  const _PendingRequestCard({
    required this.appointment,
    required this.isLoading,
    required this.onPatientTap,
    required this.onAccept,
    required this.onReject,
  });
  final DoctorAppointmentRecord appointment;
  final bool isLoading;
  final VoidCallback onPatientTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = _initials(appointment.patient.name);
    final avatarColor = _avatarColor(initials);
    return Container(
      key: ValueKey('pending-request-${appointment.id}'),
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark ? null : _cardShadow,
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: onPatientTap,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: avatarColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.patient.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? colors.onSurface : _doctorText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _typeIcon(appointment.type),
                      color: isDark ? colors.primary : _doctorTeal,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${_shortType(appointment.type)} - ${appointment.durationMinutes} min',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark
                              ? colors.onSurfaceVariant
                              : _doctorTealDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Requested: ${_relativeTime(appointment.requestedAt)}',
                  style: const TextStyle(
                    color: _doctorWarning,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 70,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: FilledButton(
                    onPressed: isLoading ? null : onAccept,
                    style: FilledButton.styleFrom(
                      backgroundColor: _doctorTeal,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _doctorTeal.withValues(
                        alpha: 0.55,
                      ),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Accept'),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: OutlinedButton(
                    onPressed: isLoading ? null : onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _doctorDanger,
                      side: const BorderSide(color: _doctorDanger),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.onPatientTap,
    required this.onAction,
    required this.isLoading,
  });
  final DoctorAppointmentRecord appointment;
  final VoidCallback onPatientTap;
  final VoidCallback onAction;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inProgress = appointment.status == DoctorAppointmentStatus.inProgress;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark ? null : _cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              color: inProgress ? _doctorTeal : Colors.transparent,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: Text(
                        _formatTime(appointment.scheduledAt),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? colors.primary : _doctorTeal,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: isDark ? colors.outlineVariant : _doctorBorder,
                    ),
                    InkWell(
                      key: ValueKey('home-patient-${appointment.id}'),
                      borderRadius: BorderRadius.circular(28),
                      onTap: onPatientTap,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage(
                          appointment.patient.imageAsset,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.patient.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? colors.onSurface : _doctorText,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                _typeIcon(appointment.type),
                                color: isDark ? colors.primary : _doctorTeal,
                                size: 15,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _shortType(appointment.type),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isDark
                                        ? colors.onSurfaceVariant
                                        : _doctorMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _formatCompactPkr(appointment.feePkr),
                            style: TextStyle(
                              color: isDark
                                  ? colors.onSurfaceVariant
                                  : _doctorMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 68,
                      child:
                          appointment.status ==
                              DoctorAppointmentStatus.inProgress
                          ? FilledButton(
                              onPressed: isLoading ? null : onAction,
                              style: FilledButton.styleFrom(
                                backgroundColor: _doctorTeal,
                                minimumSize: const Size(68, 36),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox.square(
                                      dimension: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const FittedBox(child: Text('In Progress')),
                            )
                          : OutlinedButton(
                              onPressed: isLoading ? null : onAction,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _doctorTeal,
                                side: const BorderSide(color: _doctorTeal),
                                minimumSize: const Size(68, 36),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox.square(
                                      dimension: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : FittedBox(
                                      child: Text(
                                        _actionLabel(appointment.status),
                                      ),
                                    ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextConsultationCard extends StatelessWidget {
  const _NextConsultationCard({
    required this.appointment,
    required this.onStart,
  });

  final DoctorAppointmentRecord appointment;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('next-consultation-card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _doctorTeal,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26006D5B),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'NEXT CONSULTATION',
                  style: TextStyle(
                    color: Color(0xFFBEE9E3),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  _etaLabel(appointment.scheduledAt),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage(appointment.patient.imageAsset),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patient.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      appointment.type.label,
                      style: const TextStyle(
                        color: Color(0xFFD7F2EE),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.white24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  '✓ Confirmed',
                  style: TextStyle(
                    color: Color(0xFF77E4B1),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${appointment.durationMinutes} min',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const ValueKey('start-next-consultation'),
            onPressed: onStart,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _doctorTealDark,
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.chevron_right_rounded, size: 18),
            label: const Text(
              'Start Consultation',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
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
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : _cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: _doctorTeal, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: isDark ? colors.onSurface : _doctorText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? colors.onSurfaceVariant : _doctorMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();
  @override
  Widget build(BuildContext context) =>
      const SafeArea(child: Center(child: CircularProgressIndicator()));
}

class _DashboardFailure extends StatelessWidget {
  const _DashboardFailure({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 42,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
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

String doctorGreetingForHour(int hour) {
  if (hour >= 5 && hour < 12) return 'Good Morning';
  if (hour >= 12 && hour < 17) return 'Good Afternoon';
  if (hour >= 17 && hour < 21) return 'Good Evening';
  return 'Good Night';
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

IconData _typeIcon(DoctorConsultationType type) => switch (type) {
  DoctorConsultationType.video => Icons.videocam_rounded,
  DoctorConsultationType.audio => Icons.mic_none_rounded,
  DoctorConsultationType.clinic => Icons.local_hospital_rounded,
};

String _shortType(DoctorConsultationType type) => switch (type) {
  DoctorConsultationType.video => 'Video',
  DoctorConsultationType.audio => 'Audio',
  DoctorConsultationType.clinic => 'Clinic',
};

String _actionLabel(DoctorAppointmentStatus status) => switch (status) {
  DoctorAppointmentStatus.ready => 'Start',
  DoctorAppointmentStatus.confirmed => 'Start',
  DoctorAppointmentStatus.inProgress => 'In Progress',
  DoctorAppointmentStatus.completed => 'View Summary',
  _ => 'Upcoming',
};

String _formatCompactPkr(int rupees) {
  return formatPkr(rupees).replaceFirst('PKR ', 'Rs. ');
}

String _etaLabel(DateTime value) {
  final minutes = value.difference(DateTime.now()).inMinutes;
  if (minutes <= 0) return 'Ready now';
  if (minutes < 60) return 'in $minutes min';
  final hours = (minutes / 60).ceil();
  return 'in $hours hr';
}

String _relativeTime(DateTime value) {
  final difference = DateTime.now().difference(value);
  if (difference.inMinutes < 1) return 'just now';
  if (difference.inHours < 1) return '${difference.inMinutes} min ago';
  if (difference.inDays < 1) return '${difference.inHours} hr ago';
  return '${difference.inDays} d ago';
}

String _formatTime(DateTime value) {
  final hour = value.hour == 0
      ? 12
      : value.hour > 12
      ? value.hour - 12
      : value.hour;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute\n$period';
}

String _formatDate(DateTime value) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${weekdays[value.weekday - 1]}, ${value.day} ${months[value.month - 1]}';
}

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) return 'P';
  if (parts.length == 1) {
    final value = parts.first;
    return value.substring(0, value.length >= 2 ? 2 : 1).toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

Color _avatarColor(String initials) {
  final seed = initials.codeUnits.fold<int>(0, (sum, value) => sum + value);
  const colors = [
    Color(0xFFEF4A8A),
    Color(0xFF00C896),
    Color(0xFF5C6CFF),
    Color(0xFFFF8A00),
    Color(0xFFD858E8),
  ];
  return colors[seed % colors.length];
}
