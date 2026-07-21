import 'package:flutter/material.dart';

import '../theme/doctor_tokens.dart';

/// Metric kind for the Today's Overview card. Enum-driven so callers never
/// compare string labels to decide behaviour.
enum OverviewMetricKind { appointments, pending, completed, earnings }

/// One of the four overview stats. Values come from the controller — never
/// hardcode sample numbers in the widget tree.
class OverviewMetric {
  const OverviewMetric({
    required this.kind,
    required this.value,
    required this.onTap,
  });

  final OverviewMetricKind kind;
  final String value;
  final VoidCallback onTap;

  String get label => switch (kind) {
    OverviewMetricKind.appointments => 'Appointments',
    OverviewMetricKind.pending => 'Pending',
    OverviewMetricKind.completed => 'Completed',
    OverviewMetricKind.earnings => 'Earnings',
  };

  IconData get icon => switch (kind) {
    OverviewMetricKind.appointments => Icons.calendar_today_outlined,
    OverviewMetricKind.pending => Icons.schedule_rounded,
    OverviewMetricKind.completed => Icons.task_alt_rounded,
    OverviewMetricKind.earnings => Icons.account_balance_wallet_outlined,
  };

  Color get accent => switch (kind) {
    OverviewMetricKind.appointments => DoctorColors.primary,
    OverviewMetricKind.pending => DoctorColors.warning,
    OverviewMetricKind.completed => DoctorColors.success,
    OverviewMetricKind.earnings => const Color(0xFF4F6BFF),
  };

  Color get tint => switch (kind) {
    OverviewMetricKind.appointments => DoctorColors.mint,
    OverviewMetricKind.pending => const Color(0xFFFFF5E6),
    OverviewMetricKind.completed => const Color(0xFFEAF8EF),
    OverviewMetricKind.earnings => const Color(0xFFEDF1FF),
  };
}

/// "Today's Overview" card with date chip, four stats, and analytics link.
///
/// At widths below 360dp the stats row scrolls horizontally instead of
/// squeezing numbers into clipped text (fixes the prior 320dp overflow).
/// At 360dp+ the four stats share the row equally via [Expanded].
class TodaysOverviewCard extends StatelessWidget {
  const TodaysOverviewCard({
    super.key,
    required this.metrics,
    required this.onAnalyticsTap,
    this.dateLabel,
  });

  final List<OverviewMetric> metrics;
  final VoidCallback onAnalyticsTap;
  final String? dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(DoctorSpacing.radiusCard + 2),
        boxShadow: DoctorColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Today's Overview",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: DoctorColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: DoctorColors.mint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    dateLabel ?? _formatDate(DateTime.now()),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: DoctorColors.primaryDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                // Breakpoint is screen width (rule §3), not the padded card width.
                final compact = MediaQuery.sizeOf(context).width < 360;
                if (compact) {
                  return SizedBox(
                    height: 86,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: metrics.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 88,
                          child: _MetricCell(metric: metrics[index]),
                        );
                      },
                    ),
                  );
                }
                return Row(
                  children: [
                    for (final metric in metrics)
                      Expanded(child: _MetricCell(metric: metric)),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: DoctorColors.border),
            TextButton(
              key: const ValueKey('view-detailed-analytics'),
              onPressed: onAnalyticsTap,
              style: TextButton.styleFrom(
                foregroundColor: DoctorColors.primaryDark,
                minimumSize: const Size(0, 40),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: Text(
                      'View Detailed Analytics',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({required this.metric});

  final OverviewMetric metric;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open ${metric.label}',
      child: InkWell(
        key: ValueKey('overview-${metric.kind.name}'),
        borderRadius: BorderRadius.circular(12),
        onTap: metric.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: metric.tint,
                  shape: BoxShape.circle,
                ),
                child: Icon(metric.icon, color: metric.accent, size: 20),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  metric.value,
                  maxLines: 1,
                  style: const TextStyle(
                    color: DoctorColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  metric.label,
                  maxLines: 1,
                  style: const TextStyle(
                    color: DoctorColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
