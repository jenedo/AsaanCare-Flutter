import 'prescribed_medicine.dart';

enum ClinicalPrescriptionStatus { issued, superseded, voided }

class ClinicalPrescription {
  const ClinicalPrescription({
    required this.id,
    required this.appointmentId,
    required this.doctorProfileId,
    required this.patientProfileId,
    required this.status,
    required this.version,
    required this.medicines,
    this.instructions,
    required this.issuedAt,
    required this.createdAt,
    this.doctorName,
    this.doctorSpecialty,
    this.patientName,
  });

  final String id;
  final String appointmentId;
  final String doctorProfileId;
  final String patientProfileId;
  final ClinicalPrescriptionStatus status;
  final int version;
  final List<PrescribedMedicine> medicines;
  final String? instructions;
  final DateTime issuedAt;
  final DateTime createdAt;

  final String? doctorName;
  final String? doctorSpecialty;
  final String? patientName;

  bool get isIssued => status == ClinicalPrescriptionStatus.issued;
  bool get isSuperseded => status == ClinicalPrescriptionStatus.superseded;
  bool get isVoided => status == ClinicalPrescriptionStatus.voided;
}
