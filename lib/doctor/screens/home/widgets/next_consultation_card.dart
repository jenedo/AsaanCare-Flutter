import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../shared/theme/doctor_tokens.dart';
import '../../../../shared/utils/doctor_time_format.dart';
import '../../../../shared/widgets/patient_avatar.dart';
import '../../../features/dashboard/domain/entities/doctor_dashboard_snapshot.dart';

/// Gradient "Next Consultation" card with a live countdown chip.
///
/// - Collapses to [SizedBox.shrink] (zero height) when [appointment] is null,
///   so no empty gradient box is ever rendered.
/// - The countdown recomputes once a minute via a [Timer] (not every second,
///   and not a static string).
/// - Renders the real payment status (Confirmed / Pending / Failed).
class NextConsultationCard extends StatefulWidget {
  const NextConsultationCard({
    super.key,
    required this.appointment,
    required this.onStart,
  });

  final DoctorAppointmentRecord? appointment;
  final VoidCallback onStart;

  @override
  State<NextConsultationCard> createState() => _NextConsultationCardState();
}

class _NextConsultationCardState extends State<NextConsultationCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant NextConsultationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appointment?.id != widget.appointment?.id) _syncTicker();
  }

  void _syncTicker() {
    _ticker?.cancel();
    if (widget.appointment == null) return;
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    if (appointment == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: DoctorColors.primaryGradient,
        borderRadius: BorderRadius.circular(DoctorSpacing.radiusCard + 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26006D5B),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'NEXT CONSULTATION',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFFBEE9E3),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(DoctorSpacing.radiusPill),
                ),
                child: Text(
                  etaLabel(appointment.scheduledAt),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              PatientAvatar(
                id: appointment.patient.id,
                name: appointment.patient.name,
                imageAsset: appointment.patient.imageAsset,
                radius: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      appointment.patient.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${appointment.type.label} - ${clockLabel(appointment.scheduledAt).replaceAll('\n', ' ')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFD7F2EE),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.white24),
          Row(
            children: [
              Expanded(child: _PaymentStatusChip(status: appointment.paymentStatus)),
              const SizedBox(width: 8),
              Text(
                '${appointment.durationMinutes} min',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: widget.onStart,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: DoctorColors.primaryDark,
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.chevron_right_rounded, size: 18),
            label: const Text(
              'Start Consultation',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentStatusChip extends StatelessWidget {
  const _PaymentStatusChip({required this.status});

  final DoctorPaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      DoctorPaymentStatus.confirmed => (
        Icons.check_circle_rounded,
        const Color(0xFF77E4B1),
      ),
      DoctorPaymentStatus.pending => (
        Icons.schedule_rounded,
        const Color(0xFFFFD48A),
      ),
      DoctorPaymentStatus.failed => (
        Icons.error_rounded,
        const Color(0xFFFF9E9E),
      ),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            status.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
