import 'package:flutter/material.dart';

import '../../../../shared/theme/doctor_tokens.dart';
import '../../../features/finance/domain/entities/doctor_finance_snapshot.dart';

/// Earnings title + period filter chip. The chip opens a real bottom sheet
/// (This month / Last month / This week / Custom range); selecting a period
/// is the caller's responsibility via [onPeriodSelected].
class EarningsHeader extends StatelessWidget {
  const EarningsHeader({
    super.key,
    required this.periodLabel,
    required this.selectedPeriod,
    required this.onPeriodSelected,
  });

  final String periodLabel;
  final DoctorFinancePeriod selectedPeriod;
  final ValueChanged<DoctorFinancePeriod> onPeriodSelected;

  Future<void> _openPeriodSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<DoctorFinancePeriod>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose earnings period',
                  style: TextStyle(
                    color: DoctorColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                for (final period in DoctorFinancePeriod.values)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      period == selectedPeriod
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: period == selectedPeriod
                          ? DoctorColors.primary
                          : DoctorColors.textMuted,
                    ),
                    title: Text(
                      period.label,
                      style: TextStyle(
                        color: DoctorColors.textPrimary,
                        fontWeight: period == selectedPeriod
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                    onTap: () => Navigator.pop(sheetContext, period),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) onPeriodSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Earnings',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: DoctorColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            key: const ValueKey('earnings-period-control'),
            borderRadius: BorderRadius.circular(DoctorSpacing.radiusPill),
            onTap: () => _openPeriodSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: DoctorColors.surface,
                borderRadius: BorderRadius.circular(DoctorSpacing.radiusPill),
                border: Border.all(color: DoctorColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: 16,
                    color: DoctorColors.primary,
                  ),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: Text(
                      periodLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: DoctorColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
