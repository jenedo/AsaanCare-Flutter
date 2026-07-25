import '../../domain/entities/upload_intent.dart';

class MedicalRecordUploadIntentModel extends MedicalRecordUploadIntent {
  const MedicalRecordUploadIntentModel({
    required super.storedObjectId,
    required super.bucket,
    required super.objectPath,
    required super.uploadUrl,
    required super.uploadExpiresAt,
  });

  factory MedicalRecordUploadIntentModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordUploadIntentModel(
      storedObjectId: json['storedObjectId'] as String? ?? '',
      bucket: json['bucket'] as String? ?? 'private-medical-records',
      objectPath: json['objectPath'] as String? ?? '',
      uploadUrl: json['uploadUrl'] as String? ?? '',
      uploadExpiresAt: DateTime.parse(
        json['uploadExpiresAt'] as String? ??
            DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      ),
    );
  }
}
