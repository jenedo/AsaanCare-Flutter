import '../../domain/entities/medical_record.dart';

class MedicalRecordModel extends MedicalRecord {
  const MedicalRecordModel({
    required super.id,
    required super.bucket,
    required super.purpose,
    required super.mimeType,
    required super.sizeBytes,
    required super.scanStatus,
    required super.isAvailable,
    required super.createdAt,
    super.objectPath,
    super.confirmedAt,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['scanStatus'] as String?;
    final scanStatus = parseScanStatus(rawStatus);

    // Fail closed: missing or null isAvailable must not default to true
    final isAvailable = json['isAvailable'] == true;

    return MedicalRecordModel(
      id: json['id'] as String? ?? '',
      bucket: json['bucket'] as String? ?? 'private-medical-records',
      purpose: parsePurpose(json['purpose'] as String?),
      mimeType: json['mimeType'] as String? ?? 'application/pdf',
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      scanStatus: scanStatus,
      isAvailable: isAvailable,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      objectPath: json['objectPath'] as String?,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
    );
  }

  static MedicalRecordScanStatus parseScanStatus(String? rawStatus) {
    if (rawStatus == null || rawStatus.trim().isEmpty) {
      throw const FormatException(
        'Missing scanStatus in medical record response.',
      );
    }

    return switch (rawStatus.trim().toUpperCase()) {
      'PENDING' => MedicalRecordScanStatus.pending,
      'VALIDATING' => MedicalRecordScanStatus.validating,
      'PASSED' => MedicalRecordScanStatus.passed,
      'REJECTED' => MedicalRecordScanStatus.rejected,
      'QUARANTINED' => MedicalRecordScanStatus.quarantined,
      'ERROR' => MedicalRecordScanStatus.error,
      _ => throw FormatException('Unknown scanStatus: $rawStatus'),
    };
  }

  static String serializeScanStatus(MedicalRecordScanStatus status) {
    return switch (status) {
      MedicalRecordScanStatus.pending => 'PENDING',
      MedicalRecordScanStatus.validating => 'VALIDATING',
      MedicalRecordScanStatus.passed => 'PASSED',
      MedicalRecordScanStatus.rejected => 'REJECTED',
      MedicalRecordScanStatus.quarantined => 'QUARANTINED',
      MedicalRecordScanStatus.error => 'ERROR',
    };
  }

  static MedicalRecordPurpose parsePurpose(String? rawPurpose) {
    return switch (rawPurpose?.trim().toUpperCase()) {
      'MEDICAL_RECORD' => MedicalRecordPurpose.medicalRecord,
      'LAB_RESULT' => MedicalRecordPurpose.labResult,
      'IMAGING' => MedicalRecordPurpose.imaging,
      'PRESCRIPTION_ATTACHMENT' => MedicalRecordPurpose.prescriptionAttachment,
      _ => MedicalRecordPurpose.other,
    };
  }

  static String serializePurpose(MedicalRecordPurpose purpose) {
    return switch (purpose) {
      MedicalRecordPurpose.medicalRecord => 'MEDICAL_RECORD',
      MedicalRecordPurpose.labResult => 'LAB_RESULT',
      MedicalRecordPurpose.imaging => 'IMAGING',
      MedicalRecordPurpose.prescriptionAttachment => 'PRESCRIPTION_ATTACHMENT',
      MedicalRecordPurpose.other => 'OTHER',
    };
  }
}

class MedicalRecordDownloadModel extends MedicalRecordDownload {
  const MedicalRecordDownloadModel({
    required super.downloadUrl,
    required super.expiresAt,
  });

  factory MedicalRecordDownloadModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordDownloadModel(
      downloadUrl: json['downloadUrl'] as String? ?? '',
      expiresAt: DateTime.parse(
        json['expiresAt'] as String? ??
            DateTime.now().add(const Duration(seconds: 60)).toIso8601String(),
      ),
    );
  }
}
