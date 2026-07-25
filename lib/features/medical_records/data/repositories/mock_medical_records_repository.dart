import 'dart:typed_data';

import '../../domain/entities/medical_record.dart';
import '../../domain/entities/upload_intent.dart';
import '../../domain/repositories/medical_records_repository.dart';

class MockMedicalRecordsRepository implements MedicalRecordsRepository {
  final List<MedicalRecord> _records = [
    MedicalRecord(
      id: 'mock_medical_record_001',
      bucket: 'private-medical-records',
      purpose: MedicalRecordPurpose.medicalRecord,
      mimeType: 'application/pdf',
      sizeBytes: 1048576,
      scanStatus: MedicalRecordScanStatus.passed,
      isAvailable: true,
      createdAt: DateTime(2026, 7, 25, 10, 0),
    ),
  ];

  @override
  Future<List<MedicalRecord>> getMedicalRecords() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<MedicalRecord>.unmodifiable(_records);
  }

  @override
  Future<MedicalRecordUploadIntent> createUploadIntent({
    required String mimeType,
    required int sizeBytes,
    required MedicalRecordPurpose purpose,
    String? idempotencyKey,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final id = 'mock_obj_${DateTime.now().millisecondsSinceEpoch}';
    return MedicalRecordUploadIntent(
      storedObjectId: id,
      bucket: 'private-medical-records',
      objectPath: 'medical-records/mock/$id.pdf',
      uploadUrl: 'https://mock.supabase.co/upload?token=mock-token',
      uploadExpiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<void> uploadToSignedUrl({
    required String uploadUrl,
    required String bucket,
    required String objectPath,
    required Uint8List fileBytes,
    required String mimeType,
    DateTime? uploadExpiresAt,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<MedicalRecord> confirmUpload(String storedObjectId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final record = MedicalRecord(
      id: storedObjectId,
      bucket: 'private-medical-records',
      purpose: MedicalRecordPurpose.medicalRecord,
      mimeType: 'application/pdf',
      sizeBytes: 1024,
      scanStatus: MedicalRecordScanStatus.validating,
      isAvailable: false,
      createdAt: DateTime.now(),
      confirmedAt: DateTime.now(),
    );
    _records.insert(0, record);
    return record;
  }

  @override
  Future<MedicalRecordDownload> getDownloadUrl(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return MedicalRecordDownload(
      downloadUrl: 'https://mock.supabase.co/download/$id.pdf',
      expiresAt: DateTime.now().add(const Duration(seconds: 60)),
    );
  }
}
