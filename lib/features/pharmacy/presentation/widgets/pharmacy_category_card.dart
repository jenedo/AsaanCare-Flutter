import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class PharmacyCategoryCard extends StatelessWidget {
  const PharmacyCategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.width = 82,
    this.isSelected = false,
    this.isEnabled = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final double width;
  final bool isSelected;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    final Color backgroundColor = isSelected
        ? AppTheme.softTeal
        : AppTheme.surface;

    final Color borderColor = isSelected ? AppTheme.primary : AppTheme.border;

    final Color iconColor = isEnabled
        ? AppTheme.primary
        : const Color(0xFF94A3B8);

    final Color textColor = isEnabled
        ? const Color(0xFF07132D)
        : const Color(0xFF94A3B8);

    return SizedBox(
      width: width,
      child: Semantics(
        button: true,
        enabled: isEnabled,
        label: title,
        child: Tooltip(
          message: title,
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  height: 66,
                  width: 66,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: borderColor,
                      width: isSelected ? 1.4 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.12),
                              blurRadius: 14,
                              offset: const Offset(0, 7),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(icon, color: iconColor, size: 31),
                ),
                const SizedBox(height: 9),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textScaler: textScaler.clamp(
                    minScaleFactor: 1,
                    maxScaleFactor: 1.12,
                  ),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 11.8,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
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
