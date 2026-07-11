import 'package:flutter/material.dart';

import '../design/app_motion.dart';
import '../theme/app_theme.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 78,
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        padding: const EdgeInsets.fromLTRB(4, 7, 4, 6),
        child: Row(
          children: [
            _BottomNavItem(icon: Icons.home_rounded, label: 'Home', selected: currentIndex == 0, onTap: () => onTap(0)),
            _BottomNavItem(icon: Icons.medical_services_outlined, label: 'Find Doctor', selected: currentIndex == 1, onTap: () => onTap(1)),
            _BottomNavItem(icon: Icons.local_pharmacy_outlined, label: 'Pharmacy', selected: currentIndex == 2, onTap: () => onTap(2)),
            _BottomNavItem(icon: Icons.assignment_outlined, label: 'Records', selected: currentIndex == 3, onTap: () => onTap(3)),
            _BottomNavItem(icon: Icons.account_balance_wallet_outlined, label: 'Wallet', selected: currentIndex == 4, onTap: () => onTap(4)),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.primary : const Color(0xFF66727F);
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: AppMotion.press,
                curve: AppMotion.standard,
                scale: selected ? 1 : 0.94,
                child: AnimatedContainer(
                  duration: AppMotion.medium,
                  curve: AppMotion.standard,
                  height: 34,
                  width: selected ? 50 : 34,
                  decoration: BoxDecoration(color: selected ? AppTheme.softTeal : Colors.transparent, borderRadius: BorderRadius.circular(99)),
                  child: Icon(icon, color: color, size: 24),
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: AppMotion.fast,
                curve: AppMotion.standard,
                style: TextStyle(color: color, fontSize: 10.5, fontWeight: selected ? FontWeight.w900 : FontWeight.w600),
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

