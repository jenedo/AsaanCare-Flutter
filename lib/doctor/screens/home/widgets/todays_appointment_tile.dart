import 'package:flutter/material.dart';

import '../../../../shared/theme/doctor_tokens.dart';
import '../../../../shared/utils/doctor_time_format.dart';
import '../../../../shared/widgets/patient_avatar.dart';
import '../../../features/dashboard/domain/entities/doctor_dashboard_snapshot.dart';
import '../../../features/finance/domain/entities/doctor_finance_snapshot.dart';
import 'appointment_status_button.dart';

/// A single row in "Today's Appointments": time, avatar, patient name,
/// consultation type (icon + label), price, and the trailing status control.
class TodaysAppointmentTile extends StatelessWidget {
  const TodaysAppointmentTile({
    super.key,
    required this.appointment,
    required this.onAction,
    this.onPatientTap,
    this.isLoading = false,
  });

  final DoctorAppointmentRecord appointment;
  final VoidCallback onAction;
  final VoidCallback? onPatientTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final inProgress = appointment.status == DoctorAppointmentStatus.inProgress;
    return Container(
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(DoctorSpacing.radiusCard - 2),
        boxShadow: DoctorColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              color: inProgress ? DoctorColors.primary : Colors.transparent,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 46,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          clockLabel(appointment.scheduledAt),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: DoctorColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: DoctorColors.border,
                    ),
                    PatientAvatar(
                      id: appointment.patient.id,
                      name: appointment.patient.name,
                      imageAsset: appointment.patient.imageAsset,
                      radius: 18,
                      onTap: onPatientTap,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            appointment.patient.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: DoctorColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                _typeIcon(appointment.type),
                                color: DoctorColors.primary,
                                size: 15,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _typeLabel(appointment.type),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: DoctorColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _priceLabel(appointment.feePkr),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: DoctorColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    AppointmentStatusButton(
                      variant: statusVariantFor(appointment.status),
                      isLoading: isLoading,
                      onPressed: onAction,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _typeIcon(DoctorConsultationType type) => switch (type) {
  DoctorConsultationType.video => Icons.videocam_rounded,
  DoctorConsultationType.audio => Icons.mic_none_rounded,
  DoctorConsultationType.clinic => Icons.local_hospital_rounded,
};

String _typeLabel(DoctorConsultationType type) => switch (type) {
  DoctorConsultationType.video => 'Video Consultation',
  DoctorConsultationType.audio => 'Audio Consultation',
  DoctorConsultationType.clinic => 'Clinic Visit',
};

String _priceLabel(int rupees) =>
    formatPkr(rupees).replaceFirst('PKR ', 'Rs. ');
