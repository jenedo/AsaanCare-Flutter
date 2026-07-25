import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:asaancare/core/network/api_exception.dart';
import 'package:asaancare/features/medical_records/data/repositories/mock_medical_records_repository.dart';
import 'package:asaancare/features/medical_records/domain/entities/medical_record.dart';
import 'package:asaancare/features/medical_records/domain/entities/upload_intent.dart';
import 'package:asaancare/features/medical_records/domain/repositories/medical_records_repository.dart';
import 'package:asaancare/features/medical_records/presentation/controllers/medical_records_controller.dart';

class FailingMedicalRecordsRepository implements MedicalRecordsRepository {
  FailingMedicalRecordsRepository({this.statusCode = 403});

  final int statusCode;

  @override
  Future<List<MedicalRecord>> getMedicalRecords() async {
    throw ApiException('Access denied', statusCode: statusCode);
  }

  @override
  Future<MedicalRecordUploadIntent> createUploadIntent({
    required String mimeType,
    required int sizeBytes,
    required MedicalRecordPurpose purpose,
    String? idempotencyKey,
  }) async {
    throw ApiException('Intent creation forbidden', statusCode: statusCode);
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
    throw ApiException('Signed upload failed', statusCode: statusCode);
  }

  @override
  Future<MedicalRecord> confirmUpload(String storedObjectId) async {
    throw ApiException('Confirm forbidden', statusCode: statusCode);
  }

  @override
  Future<MedicalRecordDownload> getDownloadUrl(String id) async {
    throw ApiException(
      'Medical record is pending validation or has not passed security verification',
      statusCode: statusCode,
    );
  }
}

void main() {
  group('MedicalRecordsController Unit Tests', () {
    test('loads records from mock repository', () async {
      final mockRepo = MockMedicalRecordsRepository();
      final controller = MedicalRecordsController(repository: mockRepo);

      expect(controller.status, MedicalRecordsStatus.initial);

      await controller.loadRecords();

      expect(controller.isLoaded, isTrue);
      expect(controller.records.length, 1);
      expect(
        controller.records.first.scanStatus,
        MedicalRecordScanStatus.passed,
      );
      expect(controller.records.first.canDownload, isTrue);
    });

    test('rejects file larger than 5 MiB (5,242,880 bytes)', () async {
      final mockRepo = MockMedicalRecordsRepository();
      final controller = MedicalRecordsController(repository: mockRepo);

      final overLimitBytes = Uint8List(5242881);

      final success = await controller.uploadBytes(
        bytes: overLimitBytes,
        fileName: 'huge_file.pdf',
        mimeType: 'application/pdf',
        purpose: MedicalRecordPurpose.medicalRecord,
      );

      expect(success, isFalse);
      expect(controller.hasError, isTrue);
      expect(
        controller.errorMessage,
        contains('exceeds maximum permitted limit'),
      );
    });

    test('rejects unsupported MIME type (e.g. application/zip)', () async {
      final mockRepo = MockMedicalRecordsRepository();
      final controller = MedicalRecordsController(repository: mockRepo);

      final success = await controller.uploadBytes(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'archive.zip',
        mimeType: 'application/zip',
        purpose: MedicalRecordPurpose.medicalRecord,
      );

      expect(success, isFalse);
      expect(controller.hasError, isTrue);
      expect(controller.errorMessage, contains('Unsupported MIME type'));
    });

    test(
      'upload process creates intent, uploads, and confirms record as VALIDATING',
      () async {
        final mockRepo = MockMedicalRecordsRepository();
        final controller = MedicalRecordsController(repository: mockRepo);

        await controller.loadRecords();
        final initialCount = controller.records.length;

        final success = await controller.uploadBytes(
          bytes: Uint8List.fromList([1, 2, 3, 4, 5]),
          fileName: 'blood_report.pdf',
          mimeType: 'application/pdf',
          purpose: MedicalRecordPurpose.medicalRecord,
        );

        expect(success, isTrue);
        expect(controller.records.length, initialCount + 1);

        final newRecord = controller.records.first;
        expect(newRecord.scanStatus, MedicalRecordScanStatus.validating);
        expect(newRecord.isAvailable, isFalse);
        expect(newRecord.canDownload, isFalse);
      },
    );

    test(
      'prevents duplicate upload submission while isUploading is true',
      () async {
        final mockRepo = MockMedicalRecordsRepository();
        final controller = MedicalRecordsController(repository: mockRepo);

        final future1 = controller.uploadBytes(
          bytes: Uint8List.fromList([1, 2, 3]),
          fileName: 'report1.pdf',
          mimeType: 'application/pdf',
          purpose: MedicalRecordPurpose.medicalRecord,
        );

        expect(controller.isUploading, isTrue);

        final future2 = controller.uploadBytes(
          bytes: Uint8List.fromList([1, 2, 3]),
          fileName: 'report2.pdf',
          mimeType: 'application/pdf',
          purpose: MedicalRecordPurpose.medicalRecord,
        );

        final result2 = await future2;
        expect(result2, isFalse);

        final result1 = await future1;
        expect(result1, isTrue);
      },
    );

    test(
      'hides/denies download when record is not downloadable (canDownload == false)',
      () async {
        final mockRepo = MockMedicalRecordsRepository();
        final controller = MedicalRecordsController(repository: mockRepo);

        final validatingRecord = MedicalRecord(
          id: 'val-rec',
          bucket: 'private-medical-records',
          purpose: MedicalRecordPurpose.medicalRecord,
          mimeType: 'application/pdf',
          sizeBytes: 1024,
          scanStatus: MedicalRecordScanStatus.validating,
          isAvailable: false,
          createdAt: DateTime.now(),
        );

        expect(validatingRecord.canDownload, isFalse);

        final url = await controller.fetchDownloadUrl(validatingRecord);
        expect(url, isNull);
        expect(controller.errorMessage, contains('Download unavailable'));
      },
    );

    test(
      'enables download URL fetching when record scanStatus == PASSED and isAvailable == true',
      () async {
        final mockRepo = MockMedicalRecordsRepository();
        final controller = MedicalRecordsController(repository: mockRepo);

        final passedRecord = MedicalRecord(
          id: 'passed-rec-1',
          bucket: 'private-medical-records',
          purpose: MedicalRecordPurpose.medicalRecord,
          mimeType: 'application/pdf',
          sizeBytes: 1024,
          scanStatus: MedicalRecordScanStatus.passed,
          isAvailable: true,
          createdAt: DateTime.now(),
        );

        expect(passedRecord.canDownload, isTrue);

        final url = await controller.fetchDownloadUrl(passedRecord);
        expect(url, isNotNull);
        expect(url, contains('mock.supabase.co/download'));
      },
    );

    test('handles 403 download denial from backend gracefully', () async {
      final failingRepo = FailingMedicalRecordsRepository(statusCode: 403);
      final controller = MedicalRecordsController(repository: failingRepo);

      final record = MedicalRecord(
        id: 'unverified-1',
        bucket: 'private-medical-records',
        purpose: MedicalRecordPurpose.medicalRecord,
        mimeType: 'application/pdf',
        sizeBytes: 1024,
        scanStatus: MedicalRecordScanStatus.passed,
        isAvailable: true,
        createdAt: DateTime.now(),
      );

      final url = await controller.fetchDownloadUrl(record);
      expect(url, isNull);
      expect(controller.errorMessage, contains('Download request denied'));
    });
  });
}
