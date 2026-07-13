import 'consultation_type.dart';

enum AppointmentStatus { confirmed, completed, cancelled }

extension AppointmentStatusX on AppointmentStatus {
  String get title {
    return switch (this) {
      AppointmentStatus.confirmed => 'Confirmed',
      AppointmentStatus.completed => 'Completed',
      AppointmentStatus.cancelled => 'Cancelled',
    };
  }

  bool get isUpcoming => this == AppointmentStatus.confirmed;
}

class AppointmentRecord {
  const AppointmentRecord({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorImageAsset,
    required this.consultationType,
    required this.appointmentDate,
    required this.dateLabel,
    required this.timeLabel,
    required this.totalFee,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorImageAsset;
  final ConsultationType consultationType;
  final DateTime appointmentDate;
  final String dateLabel;
  final String timeLabel;
  final int totalFee;
  final AppointmentStatus status;
  final DateTime createdAt;

  bool get isUpcoming => status.isUpcoming;
  bool get isHistory => !status.isUpcoming;
}
