import 'package:flutter/material.dart';

import '../theme/doctor_tokens.dart';
import '../utils/doctor_time_format.dart';

/// Incoming consultation request card: avatar + name, mode/duration line,
/// "Requested X ago" timestamp, and Accept / Reject actions.
///
/// Lives in `shared` because it is reused by both the Doctor Home appointment
/// queue and the Dashboard's Pending Requests section. It is intentionally
/// decoupled from any domain model: callers pass primitives + callbacks.
class AppointmentRequestCard extends StatelessWidget {
  const AppointmentRequestCard({
    super.key,
    required this.avatar,
    required this.name,
    required this.typeIcon,
    required this.typeLabel,
    required this.durationMinutes,
    required this.requestedAt,
    required this.onAccept,
    required this.onReject,
    this.isProcessing = false,
  });

  final Widget avatar;
  final String name;
  final IconData typeIcon;
  final String typeLabel;
  final int durationMinutes;
  final DateTime requestedAt;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(DoctorSpacing.radiusCard - 2),
        boxShadow: DoctorColors.cardShadow,
      ),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DoctorColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(typeIcon, color: DoctorColors.primary, size: 15),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '$typeLabel - $durationMinutes min',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: DoctorColors.primaryDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Requested: ${relativeTime(requestedAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DoctorColors.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 72,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: FilledButton(
                    onPressed: isProcessing ? null : onAccept,
                    style: FilledButton.styleFrom(
                      backgroundColor: DoctorColors.success,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: DoctorColors.success.withValues(
                        alpha: 0.55,
                      ),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: isProcessing
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Accept'),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: OutlinedButton(
                    onPressed: isProcessing ? null : onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DoctorColors.danger,
                      side: const BorderSide(color: DoctorColors.danger),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
