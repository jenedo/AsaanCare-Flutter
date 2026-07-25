// ignore_for_file: prefer_initializing_formals
import 'dart:typed_data';

import '../../domain/entities/medical_record.dart';
import '../../domain/entities/upload_intent.dart';
import '../../domain/repositories/medical_records_repository.dart';
import '../datasources/medical_records_remote_data_source.dart';

class MedicalRecordsRepositoryImpl implements MedicalRecordsRepository {
  MedicalRecordsRepositoryImpl({
    required MedicalRecordsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final MedicalRecordsRemoteDataSource _remoteDataSource;

  @override
  Future<List<MedicalRecord>> getMedicalRecords() {
    return _remoteDataSource.getMedicalRecords();
  }

  @override
  Future<MedicalRecordUploadIntent> createUploadIntent({
    required String mimeType,
    required int sizeBytes,
    required MedicalRecordPurpose purpose,
    String? idempotencyKey,
  }) {
    return _remoteDataSource.createUploadIntent(
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      purpose: purpose,
      idempotencyKey: idempotencyKey,
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
  }) {
    return _remoteDataSource.uploadToSignedUrl(
      uploadUrl: uploadUrl,
      bucket: bucket,
      objectPath: objectPath,
      fileBytes: fileBytes,
      mimeType: mimeType,
      uploadExpiresAt: uploadExpiresAt,
    );
  }

  @override
  Future<MedicalRecord> confirmUpload(String storedObjectId) {
    return _remoteDataSource.confirmUpload(storedObjectId);
  }

  @override
  Future<MedicalRecordDownload> getDownloadUrl(String id) {
    return _remoteDataSource.getDownloadUrl(id);
  }
}
