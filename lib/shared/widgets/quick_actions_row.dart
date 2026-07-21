import 'package:flutter/material.dart';

import '../theme/doctor_tokens.dart';

/// Quick-action destination. Enum-driven so icon/label/tint stay consistent
/// and callers never switch on free-form strings.
enum QuickActionKind { schedule, patients, prescribe, earnings }

class QuickActionItem {
  const QuickActionItem({required this.kind, required this.onTap});

  final QuickActionKind kind;
  final VoidCallback onTap;

  String get label => switch (kind) {
    QuickActionKind.schedule => 'Schedule',
    QuickActionKind.patients => 'Patients',
    QuickActionKind.prescribe => 'Prescribe',
    QuickActionKind.earnings => 'Earnings',
  };

  IconData get icon => switch (kind) {
    QuickActionKind.schedule => Icons.calendar_month_outlined,
    QuickActionKind.patients => Icons.group_outlined,
    QuickActionKind.prescribe => Icons.receipt_long_outlined,
    QuickActionKind.earnings => Icons.attach_money_rounded,
  };

  Color get accent => switch (kind) {
    QuickActionKind.schedule => DoctorColors.primary,
    QuickActionKind.patients => const Color(0xFF4F6BFF),
    QuickActionKind.prescribe => const Color(0xFF9C4DFF),
    QuickActionKind.earnings => const Color(0xFFE67E00),
  };

  Color get tint => switch (kind) {
    QuickActionKind.schedule => const Color(0xFFE7F6F4),
    QuickActionKind.patients => const Color(0xFFEDF1FF),
    QuickActionKind.prescribe => const Color(0xFFF5EDFF),
    QuickActionKind.earnings => const Color(0xFFFFF2E5),
  };
}

/// Four circular quick-action buttons.
///
/// - Width < 360: 2x2 grid so icons stay legible.
/// - Width >= 360: single equal-width row matching the reference.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key, required this.actions});

  final List<QuickActionItem> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(DoctorSpacing.radiusCard),
        boxShadow: DoctorColors.cardShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Breakpoint is screen width (rule §3), not the padded card width.
          final compact = MediaQuery.sizeOf(context).width < 360;
          if (compact) {
            return Column(
              children: [
                Row(
                  children: [
                    for (final action in actions.take(2))
                      Expanded(child: _ActionCell(action: action)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (final action in actions.skip(2).take(2))
                      Expanded(child: _ActionCell(action: action)),
                  ],
                ),
              ],
            );
          }
          return Row(
            children: [
              for (final action in actions)
                Expanded(child: _ActionCell(action: action)),
            ],
          );
        },
      ),
    );
  }
}

class _ActionCell extends StatelessWidget {
  const _ActionCell({required this.action});

  final QuickActionItem action;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: action.label,
      child: InkWell(
        key: ValueKey('quick-${action.kind.name}'),
        borderRadius: BorderRadius.circular(12),
        onTap: action.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: action.tint,
                shape: BoxShape.circle,
              ),
              child: Icon(action.icon, color: action.accent, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: DoctorColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
