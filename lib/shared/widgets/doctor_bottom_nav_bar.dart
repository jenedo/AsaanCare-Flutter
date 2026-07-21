import 'package:flutter/material.dart';

import '../theme/doctor_tokens.dart';

/// Bottom navigation for the doctor app shell.
///
/// Mirrors the patient app's `AppBottomNavBar` structure (rounded surface,
/// SafeArea-aware, equal-width items) but uses the doctor teal active style
/// with a small dot indicator, per the doctor UI rule.
class DoctorBottomNavBar extends StatelessWidget {
  const DoctorBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_DoctorNavItem> _items = [
    _DoctorNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _DoctorNavItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Schedule',
    ),
    _DoctorNavItem(
      icon: Icons.group_outlined,
      activeIcon: Icons.group_rounded,
      label: 'Patients',
    ),
    _DoctorNavItem(
      icon: Icons.attach_money_rounded,
      activeIcon: Icons.attach_money_rounded,
      label: 'Earnings',
    ),
    _DoctorNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DoctorColors.surface,
        border: Border(top: BorderSide(color: DoctorColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x140D5C63),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;
            return SizedBox(
              height: compact ? 60 : 66,
              child: Row(
                children: [
                  for (var index = 0; index < _items.length; index++)
                    Expanded(
                      child: _DoctorNavButton(
                        item: _items[index],
                        selected: index == currentIndex,
                        compact: compact,
                        onTap: () => onTap(index),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DoctorNavButton extends StatelessWidget {
  const _DoctorNavButton({
    required this.item,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final _DoctorNavItem item;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? DoctorColors.primary : DoctorColors.textMuted;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 6 : 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? item.activeIcon : item.icon,
                color: color,
                size: compact ? 20 : 23,
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: compact ? 9 : 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: selected ? 5 : 0,
                height: selected ? 5 : 0,
                decoration: const BoxDecoration(
                  color: DoctorColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorNavItem {
  const _DoctorNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
