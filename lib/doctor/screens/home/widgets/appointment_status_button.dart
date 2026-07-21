import 'package:flutter/material.dart';

import '../../../../shared/theme/doctor_tokens.dart';
import '../../../features/dashboard/domain/entities/doctor_dashboard_snapshot.dart';

/// The three visual states of the trailing status control on an appointment
/// tile. Driven by an enum (never string comparison).
enum AppointmentStatusVariant { start, inProgress, completed }

/// Maps a domain [DoctorAppointmentStatus] onto a button variant.
AppointmentStatusVariant statusVariantFor(DoctorAppointmentStatus status) {
  return switch (status) {
    DoctorAppointmentStatus.inProgress => AppointmentStatusVariant.inProgress,
    DoctorAppointmentStatus.completed => AppointmentStatusVariant.completed,
    DoctorAppointmentStatus.pending ||
    DoctorAppointmentStatus.confirmed ||
    DoctorAppointmentStatus.ready ||
    DoctorAppointmentStatus.cancelled => AppointmentStatusVariant.start,
  };
}

/// Trailing status control for an appointment row.
///
/// - [AppointmentStatusVariant.start]: outline primary button, tappable, shows
///   a spinner while [isLoading].
/// - [AppointmentStatusVariant.inProgress]: filled success pill, non-tappable.
/// - [AppointmentStatusVariant.completed]: neutral/gray pill; tappable only if
///   an [onPressed] is supplied (e.g. "view summary").
class AppointmentStatusButton extends StatelessWidget {
  const AppointmentStatusButton({
    super.key,
    required this.variant,
    this.onPressed,
    this.isLoading = false,
  });

  final AppointmentStatusVariant variant;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 36,
      child: switch (variant) {
        AppointmentStatusVariant.start => _startButton(),
        AppointmentStatusVariant.inProgress => _pill(
          label: 'In Progress',
          background: DoctorColors.success,
          foreground: Colors.white,
        ),
        AppointmentStatusVariant.completed => _pill(
          label: 'Completed',
          background: DoctorColors.neutralPill,
          foreground: DoctorColors.neutralPillText,
          onTap: onPressed,
        ),
      },
    );
  }

  Widget _startButton() {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: DoctorColors.primary,
        side: const BorderSide(color: DoctorColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
      child: isLoading
          ? const SizedBox.square(
              dimension: 15,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const FittedBox(fit: BoxFit.scaleDown, child: Text('Start')),
    );
  }

  Widget _pill({
    required String label,
    required Color background,
    required Color foreground,
    VoidCallback? onTap,
  }) {
    final pill = Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
    if (onTap == null) {
      return Semantics(label: label, child: pill);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: pill,
      ),
    );
  }
}
