import 'package:flutter/material.dart';

import '../../../../shared/theme/doctor_tokens.dart';

/// Overview vs Transactions tab for the earnings screen.
enum EarningsTab { overview, transactions }

/// Two-option pill segmented control matching the earnings reference.
///
/// No generic shared segmented-control widget existed in `lib/shared/` or the
/// patient app (only Material `SegmentedButton` and a local `TabBarWidget`
/// inside the unused earnings `dashboard.dart` demo), so this is purpose-built
/// for the doctor earnings visual language.
class EarningsTabSegment extends StatelessWidget {
  const EarningsTabSegment({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final EarningsTab selected;
  final ValueChanged<EarningsTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(DoctorSpacing.radiusPill),
        border: Border.all(color: DoctorColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _Segment(
                tab: EarningsTab.overview,
                label: 'Overview',
                icon: Icons.bar_chart_rounded,
                selected: selected == EarningsTab.overview,
                onTap: () => onChanged(EarningsTab.overview),
              ),
            ),
            Container(width: 1, color: DoctorColors.border),
            Expanded(
              child: _Segment(
                tab: EarningsTab.transactions,
                label: 'Transactions',
                icon: Icons.receipt_long_rounded,
                selected: selected == EarningsTab.transactions,
                onTap: () => onChanged(EarningsTab.transactions),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.tab,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final EarningsTab tab;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? DoctorColors.primaryDark
        : DoctorColors.textPrimary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? DoctorColors.mint : Colors.transparent,
        child: InkWell(
          key: ValueKey('earnings-tab-${tab.name}'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
