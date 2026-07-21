import 'package:flutter/material.dart';

import '../theme/doctor_tokens.dart';
import '../utils/doctor_greeting.dart';
import 'patient_avatar.dart';

/// Gradient header for the doctor Home tab: avatar, greeting, name,
/// specialty, dark-mode toggle, notification bell (badge hidden at 0),
/// and a real "Available for Consultation" switch.
///
/// Availability is driven by [isAvailable] / [onAvailabilityChanged] so the
/// parent (controller + repository) owns persistence — this widget never
/// keeps cosmetic-only local state as the source of truth.
class DoctorHomeHeader extends StatelessWidget {
  const DoctorHomeHeader({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.isAvailable,
    required this.onAvailabilityChanged,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onNotificationsTap,
    this.imageAsset,
    this.notificationCount = 0,
    this.isUpdatingAvailability = false,
    this.onProfileTap,
  });

  final String doctorId;
  final String doctorName;
  final String specialty;
  final String? imageAsset;
  final bool isAvailable;
  final ValueChanged<bool> onAvailabilityChanged;
  final bool isUpdatingAvailability;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final VoidCallback onNotificationsTap;
  final VoidCallback? onProfileTap;
  final int notificationCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 34),
      decoration: const BoxDecoration(
        gradient: DoctorColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              PatientAvatar(
                id: doctorId,
                name: doctorName,
                imageAsset: imageAsset,
                radius: 24,
                onTap: onProfileTap,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorGreetingForHour(DateTime.now().hour).toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFC8EEE9),
                        fontSize: 11,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctorName,
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
                      specialty,
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
              _HeaderIconButton(
                tooltip: isDarkMode ? 'Use light theme' : 'Use dark theme',
                icon: isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                onTap: onThemeToggle,
              ),
              const SizedBox(width: 8),
              Badge(
                isLabelVisible: notificationCount > 0,
                backgroundColor: DoctorColors.danger,
                label: Text(
                  notificationCount > 9 ? '9+' : '$notificationCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: _HeaderIconButton(
                  tooltip: 'Open notifications',
                  icon: Icons.notifications_none_rounded,
                  onTap: onNotificationsTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AvailabilityStrip(
            isAvailable: isAvailable,
            isUpdating: isUpdatingAvailability,
            onChanged: onAvailabilityChanged,
          ),
        ],
      ),
    );
  }
}

class _AvailabilityStrip extends StatelessWidget {
  const _AvailabilityStrip({
    required this.isAvailable,
    required this.isUpdating,
    required this.onChanged,
  });

  final bool isAvailable;
  final bool isUpdating;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.only(left: 14, right: 8),
      decoration: BoxDecoration(
        color: DoctorColors.primaryMid,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: isAvailable
                  ? const Color(0xFF40E38F)
                  : Colors.white.withValues(alpha: 0.55),
              shape: BoxShape.circle,
              boxShadow: isAvailable
                  ? const [BoxShadow(color: Color(0x6639E68C), blurRadius: 7)]
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isAvailable
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
          if (isUpdating)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            Switch.adaptive(
              key: const ValueKey('doctor-availability-switch'),
              value: isAvailable,
              activeTrackColor: Colors.white,
              activeThumbColor: DoctorColors.primary,
              inactiveTrackColor: const Color(0xFF8FB7B2),
              inactiveThumbColor: Colors.white,
              onChanged: onChanged,
            ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
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
}
