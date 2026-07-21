import 'package:flutter/material.dart';

import '../../../../shared/theme/doctor_tokens.dart';
import '../../../../shared/widgets/appointment_request_card.dart';
import '../../../../shared/widgets/patient_avatar.dart';
import '../../../features/dashboard/domain/entities/doctor_dashboard_snapshot.dart';

/// Bounded, scrollable list of [AppointmentRequestCard]s.
///
/// Handles zero (empty state), one, and many requests. Uses a shrink-wrapped,
/// non-scrolling [ListView.separated] so it is always bounded when embedded
/// inside a scrolling parent (never an unbounded Column of unknown length).
class IncomingRequestsList extends StatelessWidget {
  const IncomingRequestsList({
    super.key,
    required this.requests,
    required this.onAccept,
    required this.onReject,
    this.onPatientTap,
    this.isProcessing,
    this.maxHeight,
  });

  final List<DoctorAppointmentRecord> requests;
  final ValueChanged<DoctorAppointmentRecord> onAccept;
  final ValueChanged<DoctorAppointmentRecord> onReject;
  final ValueChanged<DoctorAppointmentRecord>? onPatientTap;

  /// Optional predicate to show a spinner on a specific request card.
  final bool Function(DoctorAppointmentRecord request)? isProcessing;

  /// When set and there are enough requests to exceed it, the list scrolls
  /// internally within this height instead of growing unbounded.
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const _EmptyRequests();
    }

    final list = ListView.separated(
      shrinkWrap: maxHeight == null,
      primary: false,
      physics: maxHeight == null
          ? const NeverScrollableScrollPhysics()
          : const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: requests.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: DoctorSpacing.cardGap - 2),
      itemBuilder: (context, index) {
        final request = requests[index];
        return AppointmentRequestCard(
          avatar: PatientAvatar(
            id: request.patient.id,
            name: request.patient.name,
            radius: 22,
            onTap: onPatientTap == null ? null : () => onPatientTap!(request),
          ),
          name: request.patient.name,
          typeIcon: _typeIcon(request.type),
          typeLabel: _shortType(request.type),
          durationMinutes: request.durationMinutes,
          requestedAt: request.requestedAt,
          isProcessing: isProcessing?.call(request) ?? false,
          onAccept: () => onAccept(request),
          onReject: () => onReject(request),
        );
      },
    );

    if (maxHeight == null) return list;
    return SizedBox(height: maxHeight, child: list);
  }
}

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(DoctorSpacing.radiusCard),
        boxShadow: DoctorColors.cardShadow,
      ),
      child: const Column(
        children: [
          Icon(Icons.task_alt_rounded, color: DoctorColors.primary, size: 32),
          SizedBox(height: 8),
          Text(
            'No pending requests',
            style: TextStyle(
              color: DoctorColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 3),
          Text(
            'New consultation requests will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: DoctorColors.textMuted),
          ),
        ],
      ),
    );
  }
}

IconData _typeIcon(DoctorConsultationType type) => switch (type) {
  DoctorConsultationType.video => Icons.videocam_rounded,
  DoctorConsultationType.audio => Icons.mic_none_rounded,
  DoctorConsultationType.clinic => Icons.local_hospital_rounded,
};

String _shortType(DoctorConsultationType type) => switch (type) {
  DoctorConsultationType.video => 'Video',
  DoctorConsultationType.audio => 'Audio',
  DoctorConsultationType.clinic => 'Clinic',
};
