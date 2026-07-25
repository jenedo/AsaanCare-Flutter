import '../../domain/entities/clinical_prescription.dart';
import 'prescribed_medicine_model.dart';

class ClinicalPrescriptionModel extends ClinicalPrescription {
  const ClinicalPrescriptionModel({
    required super.id,
    required super.appointmentId,
    required super.doctorProfileId,
    required super.patientProfileId,
    required super.status,
    required super.version,
    required super.medicines,
    super.instructions,
    required super.issuedAt,
    required super.createdAt,
    super.doctorName,
    super.doctorSpecialty,
    super.patientName,
  });

  factory ClinicalPrescriptionModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String?;
    final status = _parseStatus(statusStr);

    final medicinesRaw = json['medicines'];
    final List<PrescribedMedicineModel> medicinesList;
    if (medicinesRaw is List) {
      medicinesList = medicinesRaw
          .whereType<Map<String, dynamic>>()
          .map(PrescribedMedicineModel.fromJson)
          .toList();
    } else {
      medicinesList = const [];
    }

    final doctorProfile = json['doctorProfile'] as Map<String, dynamic>?;
    final patientProfile = json['patientProfile'] as Map<String, dynamic>?;

    return ClinicalPrescriptionModel(
      id: json['id'] as String? ?? '',
      appointmentId: json['appointmentId'] as String? ?? '',
      doctorProfileId:
          json['doctorProfileId'] as String? ??
          (doctorProfile?['id'] as String? ?? ''),
      patientProfileId:
          json['patientProfileId'] as String? ??
          (patientProfile?['id'] as String? ?? ''),
      status: status,
      version: (json['version'] as num?)?.toInt() ?? 1,
      medicines: medicinesList,
      instructions: json['instructions'] as String?,
      issuedAt: DateTime.parse(
        json['issuedAt'] as String? ?? json['createdAt'] as String,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      doctorName: doctorProfile?['fullName'] as String?,
      doctorSpecialty: doctorProfile?['specialty'] as String?,
      patientName: patientProfile?['fullName'] as String?,
    );
  }

  static ClinicalPrescriptionStatus _parseStatus(String? rawStatus) {
    return switch (rawStatus?.toUpperCase()) {
      'ISSUED' => ClinicalPrescriptionStatus.issued,
      'SUPERSEDED' => ClinicalPrescriptionStatus.superseded,
      'VOIDED' => ClinicalPrescriptionStatus.voided,
      _ => throw FormatException('Unknown prescription status: $rawStatus'),
    };
  }
}
