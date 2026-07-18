import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../features/dashboard/domain/entities/doctor_dashboard_snapshot.dart';
import '../../../features/dashboard/presentation/controllers/doctor_dashboard_controller.dart';
import '../../../features/finance/domain/entities/doctor_finance_snapshot.dart';
import '../../../features/finance/presentation/controllers/doctor_finance_controller.dart';

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
            .where((item) => item.status != DoctorAppointmentStatus.pending)
            .take(3)
            .toList(growable: false);
        final requests = dashboardController.pendingRequests
            .take(2)
            .toList(growable: false);

        return SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: RefreshIndicator(
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
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                      sliver: SliverList.list(
                        children: [
                          _DoctorHeader(
                            profile: snapshot.profile,
                            fallbackName: doctorName,
                            notificationCount:
                                dashboardController.notificationCount,
                            isDarkMode: isDarkMode,
                            onThemeToggle: onThemeToggle,
                            onProfileTap: onProfileTap,
                            onNotificationsTap: onNotificationsTap,
                          ),
                          const SizedBox(height: 18),
                          _OverviewCard(
                            appointmentCount: appointments.length,
                            pendingCount:
                                dashboardController.pendingRequests.length,
                            completedCount: dashboardController.completedCount,
                            earningsPkr: finance?.totalEarningsPkr ?? 0,
                            onAppointmentsTap: onAppointmentsTap,
                            onPendingTap: onPendingTap,
                            onCompletedTap: onCompletedTap,
                            onEarningsTap: onEarningsTap,
                          ),
                          const SizedBox(height: 18),
                          _QuickActions(
                            onScheduleTap: onScheduleTap,
                            onPatientsTap: onPatientsTap,
                            onPrescribeTap: onPrescribeTap,
                            onEarningsTap: onEarningsTap,
                          ),
                          const SizedBox(height: 24),
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
                          const SizedBox(height: 18),
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
                        ],
                      ),
                    ),
                  ],
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
    final colors = Theme.of(context).colorScheme;
    final content = Row(
      children: [
        Semantics(
          button: true,
          label: 'Open doctor profile',
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: onProfileTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 31,
                  backgroundColor: colors.primaryContainer,
                  backgroundImage: AssetImage(profile.imageAsset),
                ),
                if (profile.isOnline)
                  Positioned(
                    right: -1,
                    bottom: 2,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: const Color(0xFF18A957),
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctorGreetingForHour(DateTime.now().hour),
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              Text(
                profile.specialty,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        _HeaderButton(
          tooltip: isDarkMode ? 'Use light theme' : 'Use dark theme',
          icon: isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          onTap: onThemeToggle,
        ),
        const SizedBox(width: 8),
        Badge(
          isLabelVisible: notificationCount > 0,
          label: Text(notificationCount > 9 ? '9+' : '$notificationCount'),
          child: _HeaderButton(
            tooltip: 'Open notifications',
            icon: Icons.notifications_none_rounded,
            onTap: onNotificationsTap,
          ),
        ),
      ],
    );
    return _motion(context, content, delay: 0);
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
    color: Theme.of(context).colorScheme.surfaceContainer,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(
        color: Theme.of(context).dividerColor.withValues(alpha: .45),
      ),
    ),
    child: IconButton(tooltip: tooltip, onPressed: onTap, icon: Icon(icon)),
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
    final metrics = [
      (
        Icons.calendar_month_outlined,
        '$appointmentCount',
        'Appointments',
        onAppointmentsTap,
      ),
      (Icons.schedule_rounded, '$pendingCount', 'Pending', onPendingTap),
      (Icons.task_alt_rounded, '$completedCount', 'Completed', onCompletedTap),
      (
        Icons.account_balance_wallet_outlined,
        formatPkr(earningsPkr),
        'Earnings',
        onEarningsTap,
      ),
    ];
    final card = Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF087D72), Color(0xFF0B9E98)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22007870),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Today's Overview",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(DateTime.now()),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth < 400 ? 2 : 4;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: metrics.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      childAspectRatio: columns == 2 ? 1.2 : .92,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final metric = metrics[index];
                      return Semantics(
                        button: true,
                        label: 'Open ${metric.$3}',
                        child: InkWell(
                          key: ValueKey('overview-${metric.$3.toLowerCase()}'),
                          borderRadius: BorderRadius.circular(14),
                          onTap: metric.$4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(metric.$1, color: Colors.white, size: 23),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    metric.$2,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                Text(
                                  metric.$3,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
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
    final actions = [
      (
        Icons.calendar_month_rounded,
        'Schedule',
        colors.primaryContainer,
        colors.primary,
        onScheduleTap,
      ),
      (
        Icons.people_alt_rounded,
        'Patients',
        colors.secondaryContainer,
        colors.secondary,
        onPatientsTap,
      ),
      (
        Icons.edit_note_rounded,
        'Prescribe',
        colors.tertiaryContainer,
        colors.tertiary,
        onPrescribeTap,
      ),
      (
        Icons.account_balance_wallet_rounded,
        'Earnings',
        colors.errorContainer,
        colors.error,
        onEarningsTap,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 400 ? 2 : 4;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: actions
              .map(
                (action) => SizedBox(
                  width: width,
                  child: Material(
                    color: colors.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: colors.outlineVariant.withValues(alpha: .55),
                      ),
                    ),
                    child: InkWell(
                      key: ValueKey('quick-${action.$2.toLowerCase()}'),
                      borderRadius: BorderRadius.circular(18),
                      onTap: action.$5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 16,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: action.$3,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Icon(action.$1, color: action.$4),
                            ),
                            const SizedBox(height: 9),
                            Text(
                              action.$2,
                              maxLines: 1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
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
  Widget build(BuildContext context) => Row(
    children: [
      Flexible(
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      if (count != null) ...[
        const SizedBox(width: 8),
        Badge(label: Text('$count')),
      ],
      const Spacer(),
      if (actionLabel != null)
        TextButton(onPressed: onAction, child: Text(actionLabel!)),
    ],
  );
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
    return Card(
      key: ValueKey('pending-request-${appointment.id}'),
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: .55)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(32),
                  onTap: onPatientTap,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage(appointment.patient.imageAsset),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patient.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${appointment.type.label} · ${appointment.durationMinutes} min',
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Requested ${_relativeTime(appointment.requestedAt)}',
                        style: TextStyle(
                          color: colors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(_typeIcon(appointment.type), color: colors.primary),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : onReject,
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: isLoading ? null : onAccept,
                    child: isLoading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
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
    final inProgress = appointment.status == DoctorAppointmentStatus.inProgress;
    final compactAction = MediaQuery.sizeOf(context).width < 430;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: .55)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              color: inProgress ? colors.primary : Colors.transparent,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    SizedBox(
                      width: 58,
                      child: Text(
                        _formatTime(appointment.scheduledAt),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 18),
                    InkWell(
                      key: ValueKey('home-patient-${appointment.id}'),
                      borderRadius: BorderRadius.circular(28),
                      onTap: onPatientTap,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(
                          appointment.patient.imageAsset,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.patient.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                _typeIcon(appointment.type),
                                color: colors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  appointment.type.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            formatPkr(appointment.feePkr),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (compactAction)
                      IconButton.filledTonal(
                        tooltip: _actionLabel(appointment.status),
                        onPressed:
                            isLoading ||
                                appointment.status ==
                                    DoctorAppointmentStatus.confirmed
                            ? null
                            : onAction,
                        icon: isLoading
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                appointment.status ==
                                        DoctorAppointmentStatus.completed
                                    ? Icons.description_outlined
                                    : Icons.play_arrow_rounded,
                              ),
                      )
                    else
                      FilledButton.tonal(
                        onPressed:
                            isLoading ||
                                appointment.status ==
                                    DoctorAppointmentStatus.confirmed
                            ? null
                            : onAction,
                        child: isLoading
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_actionLabel(appointment.status)),
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
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: Theme.of(
          context,
        ).colorScheme.outlineVariant.withValues(alpha: .55),
      ),
    ),
    child: Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(subtitle, textAlign: TextAlign.center),
      ],
    ),
  );
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
        begin: .025,
        end: 0,
        duration: 240.ms,
        curve: Curves.easeOutCubic,
      );
}

IconData _typeIcon(DoctorConsultationType type) => switch (type) {
  DoctorConsultationType.video => Icons.videocam_rounded,
  DoctorConsultationType.audio => Icons.phone_in_talk_rounded,
  DoctorConsultationType.clinic => Icons.local_hospital_rounded,
};

String _actionLabel(DoctorAppointmentStatus status) => switch (status) {
  DoctorAppointmentStatus.ready => 'Start',
  DoctorAppointmentStatus.inProgress => 'In Progress',
  DoctorAppointmentStatus.completed => 'View Summary',
  _ => 'Upcoming',
};

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
