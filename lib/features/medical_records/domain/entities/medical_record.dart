enum MedicalRecordScanStatus {
  pending,
  validating,
  passed,
  rejected,
  quarantined,
  error,
}

enum MedicalRecordPurpose {
  medicalRecord,
  labResult,
  imaging,
  prescriptionAttachment,
  other,
}

class MedicalRecord {
  const MedicalRecord({
    required this.id,
    required this.bucket,
    required this.purpose,
    required this.mimeType,
    required this.sizeBytes,
    required this.scanStatus,
    required this.isAvailable,
    required this.createdAt,
    this.objectPath,
    this.confirmedAt,
  });

  final String id;
  final String bucket;
  final MedicalRecordPurpose purpose;
  final String mimeType;
  final int sizeBytes;
  final MedicalRecordScanStatus scanStatus;
  final bool isAvailable;
  final DateTime createdAt;
  final String? objectPath;
  final DateTime? confirmedAt;

  bool get canDownload =>
      scanStatus == MedicalRecordScanStatus.passed && isAvailable;
}

class MedicalRecordDownload {
  const MedicalRecordDownload({
    required this.downloadUrl,
    required this.expiresAt,
  });

  final String downloadUrl;
  final DateTime expiresAt;
}
