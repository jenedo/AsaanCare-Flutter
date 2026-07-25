class MedicalRecordUploadIntent {
  const MedicalRecordUploadIntent({
    required this.storedObjectId,
    required this.bucket,
    required this.objectPath,
    required this.uploadUrl,
    required this.uploadExpiresAt,
  });

  final String storedObjectId;
  final String bucket;
  final String objectPath;
  final String uploadUrl;
  final DateTime uploadExpiresAt;
}
