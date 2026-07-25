import 'dart:typed_data';

import '../entities/medical_record.dart';
import '../entities/upload_intent.dart';

abstract class MedicalRecordsRepository {
  Future<List<MedicalRecord>> getMedicalRecords();

  Future<MedicalRecordUploadIntent> createUploadIntent({
    required String mimeType,
    required int sizeBytes,
    required MedicalRecordPurpose purpose,
    String? idempotencyKey,
  });

  Future<void> uploadToSignedUrl({
    required String uploadUrl,
    required String bucket,
    required String objectPath,
    required Uint8List fileBytes,
    required String mimeType,
    DateTime? uploadExpiresAt,
  });

  Future<MedicalRecord> confirmUpload(String storedObjectId);

  Future<MedicalRecordDownload> getDownloadUrl(String id);
}
