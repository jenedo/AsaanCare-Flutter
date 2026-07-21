import 'package:flutter/material.dart';

import '../../../../shared/theme/doctor_tokens.dart';
import '../../../features/finance/domain/entities/doctor_finance_snapshot.dart';

/// Gradient earnings summary: total PKR + consultations / pending / growth.
///
/// [growthPercent] must be a real current-vs-previous calculation from the
/// repository — this widget only renders the signed value with up/down color.
class EarningsSummaryCard extends StatelessWidget {
  const EarningsSummaryCard({
    super.key,
    required this.totalEarningsPkr,
    required this.consultationCount,
    required this.pendingPkr,
    required this.growthPercent,
  });

  final int totalEarningsPkr;
  final int consultationCount;
  final int pendingPkr;
  final double growthPercent;

  @override
  Widget build(BuildContext context) {
    final growthPositive = growthPercent >= 0;
    final growthLabel =
        '${growthPositive ? '+' : ''}${growthPercent.toStringAsFixed(1)}%';
    final growthColor = growthPositive
        ? const Color(0xFFB8F5D4)
        : const Color(0xFFFFB4B4);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: DoctorColors.primaryGradient,
        borderRadius: BorderRadius.circular(DoctorSpacing.radiusCard + 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26006D5B),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total earnings',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatPkr(totalEarningsPkr),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = MediaQuery.sizeOf(context).width < 360;
              final stats = [
                _Stat(
                  value: '$consultationCount',
                  label: 'Consultations',
                ),
                _Stat(value: formatPkr(pendingPkr), label: 'Pending'),
                _Stat(
                  value: growthLabel,
                  label: 'Growth',
                  valueColor: growthColor,
                  leading: Icon(
                    growthPositive
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 14,
                    color: growthColor,
                  ),
                ),
              ];
              if (compact) {
                return Column(
                  children: [
                    for (var i = 0; i < stats.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      stats[i],
                    ],
                  ],
                );
              }
              return Row(
                children: [
                  for (var i = 0; i < stats.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(child: stats[i]),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    this.valueColor = Colors.white,
    this.leading,
  });

  final String value;
  final String label;
  final Color valueColor;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 4)],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
