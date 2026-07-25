import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:asaancare/core/network/api_client.dart';
import 'package:asaancare/core/network/api_exception.dart';
import 'package:asaancare/features/medical_records/data/datasources/medical_records_remote_data_source.dart';
import 'package:asaancare/features/medical_records/data/models/medical_record_model.dart';
import 'package:asaancare/features/medical_records/data/repositories/medical_records_repository_impl.dart';
import 'package:asaancare/features/medical_records/domain/entities/medical_record.dart';

void main() {
  const baseUrl = 'https://api.asaancare.test/api';
  const validToken = 'valid-patient-jwt-token';
  const validSignedUploadUrl =
      'https://yngsqabpnghmfysiiwaq.supabase.co/storage/v1/object/upload/sign/private-medical-records/medical-records/pat-1/record-1.pdf?token=valid-upload-token-xyz';

  group('Medical Record Domain & Fail-Closed Parsing Rules', () {
    test(
      'canDownload returns true ONLY when scanStatus == PASSED and isAvailable == true',
      () {
        final passedRecord = MedicalRecord(
          id: 'rec-passed',
          bucket: 'private-medical-records',
          purpose: MedicalRecordPurpose.medicalRecord,
          mimeType: 'application/pdf',
          sizeBytes: 1024,
          scanStatus: MedicalRecordScanStatus.passed,
          isAvailable: true,
          createdAt: DateTime.parse('2026-07-25T10:00:00.000Z'),
        );
        expect(passedRecord.canDownload, isTrue);

        final validatingRecord = MedicalRecord(
          id: 'rec-validating',
          bucket: 'private-medical-records',
          purpose: MedicalRecordPurpose.medicalRecord,
          mimeType: 'application/pdf',
          sizeBytes: 1024,
          scanStatus: MedicalRecordScanStatus.validating,
          isAvailable: false,
          createdAt: DateTime.parse('2026-07-25T10:00:00.000Z'),
        );
        expect(validatingRecord.canDownload, isFalse);

        final passedButUnavailable = MedicalRecord(
          id: 'rec-unavailable',
          bucket: 'private-medical-records',
          purpose: MedicalRecordPurpose.medicalRecord,
          mimeType: 'application/pdf',
          sizeBytes: 1024,
          scanStatus: MedicalRecordScanStatus.passed,
          isAvailable: false,
          createdAt: DateTime.parse('2026-07-25T10:00:00.000Z'),
        );
        expect(passedButUnavailable.canDownload, isFalse);

        final rejectedRecord = MedicalRecord(
          id: 'rec-rejected',
          bucket: 'private-medical-records',
          purpose: MedicalRecordPurpose.medicalRecord,
          mimeType: 'application/pdf',
          sizeBytes: 1024,
          scanStatus: MedicalRecordScanStatus.rejected,
          isAvailable: false,
          createdAt: DateTime.parse('2026-07-25T10:00:00.000Z'),
        );
        expect(rejectedRecord.canDownload, isFalse);
      },
    );

    test(
      'fails closed when isAvailable is missing from JSON response (isAvailable becomes false)',
      () {
        final json = {
          'id': 'rec-missing-available',
          'bucket': 'private-medical-records',
          'purpose': 'MEDICAL_RECORD',
          'mimeType': 'application/pdf',
          'sizeBytes': 1024,
          'scanStatus': 'PASSED',
          'createdAt': '2026-07-25T10:00:00.000Z',
        };

        final model = MedicalRecordModel.fromJson(json);
        expect(model.isAvailable, isFalse);
        expect(model.canDownload, isFalse);
      },
    );

    test('throws controlled FormatException when scanStatus is missing', () {
      final json = {
        'id': 'rec-missing-status',
        'bucket': 'private-medical-records',
        'purpose': 'MEDICAL_RECORD',
        'mimeType': 'application/pdf',
        'sizeBytes': 1024,
        'isAvailable': true,
        'createdAt': '2026-07-25T10:00:00.000Z',
      };

      expect(
        () => MedicalRecordModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws controlled FormatException when scanStatus is unknown', () {
      final json = {
        'id': 'rec-unknown-status',
        'bucket': 'private-medical-records',
        'purpose': 'MEDICAL_RECORD',
        'mimeType': 'application/pdf',
        'sizeBytes': 1024,
        'scanStatus': 'FOO_BAR_UNKNOWN',
        'isAvailable': true,
        'createdAt': '2026-07-25T10:00:00.000Z',
      };

      expect(
        () => MedicalRecordModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('MedicalRecordsRemoteDataSource Pre-upload Validations', () {
    test('rejects unsupported MIME types before calling network', () async {
      final mockClient = MockClient(
        (request) async => http.Response('{}', 200),
      );
      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final dataSource = MedicalRecordsRemoteDataSource(
        apiClient: apiClient,
        tokenProvider: () async => validToken,
      );

      expect(
        () => dataSource.createUploadIntent(
          mimeType: 'application/x-msdownload',
          sizeBytes: 1000,
          purpose: MedicalRecordPurpose.medicalRecord,
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having(
                (e) => e.message,
                'message',
                contains('Unsupported MIME type'),
              ),
        ),
      );
    });

    test(
      'rejects file size above 5 MiB (5,242,880 bytes) before calling network',
      () async {
        final mockClient = MockClient(
          (request) async => http.Response('{}', 200),
        );
        final apiClient = ApiClient(
          client: mockClient,
          baseUrl: baseUrl,
          timeout: const Duration(seconds: 5),
        );

        final dataSource = MedicalRecordsRemoteDataSource(
          apiClient: apiClient,
          tokenProvider: () async => validToken,
        );

        const overLimitBytes = 5242881;

        expect(
          () => dataSource.createUploadIntent(
            mimeType: 'application/pdf',
            sizeBytes: overLimitBytes,
            purpose: MedicalRecordPurpose.medicalRecord,
          ),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 400)
                .having(
                  (e) => e.message,
                  'message',
                  contains('exceeds maximum permitted limit'),
                ),
          ),
        );
      },
    );

    test('rejects upload attempt when upload intent has expired', () async {
      final mockApiClient = ApiClient(
        client: MockClient((_) async => http.Response('{}', 200)),
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final dataSource = MedicalRecordsRemoteDataSource(
        apiClient: mockApiClient,
        tokenProvider: () async => validToken,
      );

      final expiredTime = DateTime.now().subtract(const Duration(minutes: 5));

      expect(
        () => dataSource.uploadToSignedUrl(
          uploadUrl: validSignedUploadUrl,
          bucket: 'private-medical-records',
          objectPath: 'medical-records/pat-1/record-1.pdf',
          fileBytes: Uint8List.fromList([1, 2, 3]),
          mimeType: 'application/pdf',
          uploadExpiresAt: expiredTime,
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', contains('expired')),
        ),
      );
    });

    test('throws 401 ApiException when auth token is missing', () async {
      final mockClient = MockClient(
        (request) async => http.Response('{}', 200),
      );
      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final dataSource = MedicalRecordsRemoteDataSource(
        apiClient: apiClient,
        tokenProvider: () async => null,
      );

      expect(
        () => dataSource.getMedicalRecords(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });
  });

  group('MedicalRecords Signed Upload & Token Extraction', () {
    test(
      'extracts token and performs binary upload to signed upload URL',
      () async {
        final dummyBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        final mockHttpClient = MockClient((request) async {
          expect(request.method, 'PUT');
          expect(request.url.toString(), validSignedUploadUrl);
          expect(
            request.url.queryParameters['token'],
            'valid-upload-token-xyz',
          );
          expect(request.headers['Content-Type'], 'application/pdf');
          expect(request.bodyBytes, dummyBytes);
          return http.Response('', 200);
        });

        final mockApiClient = ApiClient(
          client: MockClient((_) async => http.Response('{}', 200)),
          baseUrl: baseUrl,
          timeout: const Duration(seconds: 5),
        );

        final dataSource = MedicalRecordsRemoteDataSource(
          apiClient: mockApiClient,
          tokenProvider: () async => validToken,
          httpClient: mockHttpClient,
        );

        await dataSource.uploadToSignedUrl(
          uploadUrl: validSignedUploadUrl,
          bucket: 'private-medical-records',
          objectPath: 'medical-records/pat-1/record-1.pdf',
          fileBytes: dummyBytes,
          mimeType: 'application/pdf',
        );
      },
    );

    test('throws ApiException on non-HTTPS signed upload URL', () async {
      final mockApiClient = ApiClient(
        client: MockClient((_) async => http.Response('{}', 200)),
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final dataSource = MedicalRecordsRemoteDataSource(
        apiClient: mockApiClient,
        tokenProvider: () async => validToken,
      );

      expect(
        () => dataSource.uploadToSignedUrl(
          uploadUrl: 'http://insecure-domain.com/upload?token=abc',
          bucket: 'private-medical-records',
          objectPath: 'record-1.pdf',
          fileBytes: Uint8List.fromList([1, 2]),
          mimeType: 'application/pdf',
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', contains('HTTPS')),
        ),
      );
    });

    test(
      'throws ApiException when token query parameter is missing from signed upload URL',
      () async {
        final mockApiClient = ApiClient(
          client: MockClient((_) async => http.Response('{}', 200)),
          baseUrl: baseUrl,
          timeout: const Duration(seconds: 5),
        );

        final dataSource = MedicalRecordsRemoteDataSource(
          apiClient: mockApiClient,
          tokenProvider: () async => validToken,
        );

        expect(
          () => dataSource.uploadToSignedUrl(
            uploadUrl: 'https://storage.supabase.co/upload/sign/path/file.pdf',
            bucket: 'private-medical-records',
            objectPath: 'file.pdf',
            fileBytes: Uint8List.fromList([1, 2]),
            mimeType: 'application/pdf',
          ),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 400)
                .having((e) => e.message, 'message', contains('Missing token')),
          ),
        );
      },
    );
  });

  group('MedicalRecords Intent, Confirm & Download E2E Flow', () {
    test('createUploadIntent parses NestJS response correctly', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/v1/medical-records/upload-intent'));
        final body = jsonDecode(request.body);
        expect(body['mimeType'], 'application/pdf');
        expect(body['sizeBytes'], 1024);
        expect(body['purpose'], 'MEDICAL_RECORD');

        return http.Response(
          jsonEncode({
            'storedObjectId': 'obj-uuid-001',
            'bucket': 'private-medical-records',
            'objectPath': 'medical-records/pat-1/obj-uuid-001.pdf',
            'uploadUrl': validSignedUploadUrl,
            'uploadExpiresAt': '2026-07-25T11:00:00.000Z',
          }),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final repository = MedicalRecordsRepositoryImpl(
        remoteDataSource: MedicalRecordsRemoteDataSource(
          apiClient: apiClient,
          tokenProvider: () async => validToken,
        ),
      );

      final intent = await repository.createUploadIntent(
        mimeType: 'application/pdf',
        sizeBytes: 1024,
        purpose: MedicalRecordPurpose.medicalRecord,
      );

      expect(intent.storedObjectId, 'obj-uuid-001');
      expect(intent.uploadUrl, validSignedUploadUrl);
      expect(intent.bucket, 'private-medical-records');
    });

    test(
      'confirmUpload returns record in VALIDATING state with isAvailable == false',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, endsWith('/v1/medical-records/confirm'));
          final body = jsonDecode(request.body);
          expect(body['storedObjectId'], 'obj-uuid-001');

          return http.Response(
            jsonEncode({
              'id': 'obj-uuid-001',
              'bucket': 'private-medical-records',
              'purpose': 'MEDICAL_RECORD',
              'mimeType': 'application/pdf',
              'sizeBytes': 1024,
              'scanStatus': 'VALIDATING',
              'isAvailable': false,
              'createdAt': '2026-07-25T10:00:00.000Z',
              'confirmedAt': '2026-07-25T10:01:00.000Z',
            }),
            200,
          );
        });

        final apiClient = ApiClient(
          client: mockClient,
          baseUrl: baseUrl,
          timeout: const Duration(seconds: 5),
        );

        final repository = MedicalRecordsRepositoryImpl(
          remoteDataSource: MedicalRecordsRemoteDataSource(
            apiClient: apiClient,
            tokenProvider: () async => validToken,
          ),
        );

        final record = await repository.confirmUpload('obj-uuid-001');

        expect(record.id, 'obj-uuid-001');
        expect(record.scanStatus, MedicalRecordScanStatus.validating);
        expect(record.isAvailable, isFalse);
        expect(record.canDownload, isFalse);
      },
    );

    test(
      'getDownloadUrl returns signed URL when record is PASSED and available',
      () async {
        final mockClient = MockClient((request) async {
          expect(
            request.url.path,
            endsWith('/v1/medical-records/obj-uuid-001/download-url'),
          );

          return http.Response(
            jsonEncode({
              'downloadUrl': 'https://download-signed-url.supabase.co/file.pdf',
              'expiresAt': '2026-07-25T10:05:00.000Z',
            }),
            200,
          );
        });

        final apiClient = ApiClient(
          client: mockClient,
          baseUrl: baseUrl,
          timeout: const Duration(seconds: 5),
        );

        final repository = MedicalRecordsRepositoryImpl(
          remoteDataSource: MedicalRecordsRemoteDataSource(
            apiClient: apiClient,
            tokenProvider: () async => validToken,
          ),
        );

        final download = await repository.getDownloadUrl('obj-uuid-001');
        expect(
          download.downloadUrl,
          'https://download-signed-url.supabase.co/file.pdf',
        );
      },
    );

    test(
      'handles 403 Forbidden on download when record has not passed security verification',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'message':
                  'Medical record is pending validation or has not passed security verification',
            }),
            403,
          );
        });

        final apiClient = ApiClient(
          client: mockClient,
          baseUrl: baseUrl,
          timeout: const Duration(seconds: 5),
        );

        final repository = MedicalRecordsRepositoryImpl(
          remoteDataSource: MedicalRecordsRemoteDataSource(
            apiClient: apiClient,
            tokenProvider: () async => validToken,
          ),
        );

        expect(
          () => repository.getDownloadUrl('unverified-obj-id'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 403)
                .having(
                  (e) => e.message,
                  'message',
                  contains('pending validation'),
                ),
          ),
        );
      },
    );
  });
}
