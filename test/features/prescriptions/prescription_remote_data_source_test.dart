import 'dart:convert';
import 'dart:typed_data';

import 'package:asaancare/core/network/api_client.dart';
import 'package:asaancare/features/prescriptions/data/datasources/prescription_mock_data_source.dart';
import 'package:asaancare/features/prescriptions/data/datasources/prescription_remote_data_source.dart';
import 'package:asaancare/features/prescriptions/data/repositories/prescription_repository_impl.dart';
import 'package:asaancare/features/prescriptions/domain/entities/prescription_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('PrescriptionRemoteDataSource Unit Tests', () {
    test(
      'getPrescriptions parses response list into PrescriptionRecord entities',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/v1/prescriptions');
          expect(request.headers['Authorization'], 'Bearer valid_token');
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': 'pres_101',
                  'issuedAt': '2026-07-28T10:00:00Z',
                  'status': 'ISSUED',
                  'instructions': 'Take twice daily',
                  'doctorProfile': {
                    'id': 'doc_1',
                    'fullName': 'Dr. Sarah Ahmed',
                    'specialty': 'Cardiology',
                  },
                  'patientProfile': {'id': 'pat_1', 'fullName': 'Ali Patient'},
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(
          client: mockClient,
          baseUrl: 'https://api.asaancare.pk',
          timeout: const Duration(seconds: 15),
        );

        final dataSource = PrescriptionRemoteDataSource(
          apiClient: apiClient,
          tokenProvider: () async => 'valid_token',
        );

        final records = await dataSource.getPrescriptions(patientId: 'pat_1');
        expect(records.length, 1);
        expect(records.first.id, 'pres_101');
        expect(records.first.issuer, 'Dr. Sarah Ahmed');
        expect(records.first.summary, 'Take twice daily');
        expect(records.first.status, PrescriptionStatus.reviewed);
      },
    );

    test('uploadPrescription initiates upload intent and confirms', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/v1/medical-records/upload-intent') {
          return http.Response(
            jsonEncode({
              'data': {
                'id': 'obj_999',
                'uploadUrl': 'https://storage.asaancare.pk/upload?token=abc',
                'bucket': 'medical',
                'path': 'pat_1/pres_1.pdf',
              },
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.url.path == '/upload') {
          expect(request.method, 'PUT');
          return http.Response('', 200);
        } else if (request.url.path == '/v1/medical-records/confirm') {
          return http.Response(
            jsonEncode({
              'data': {'id': 'rec_777', 'createdAt': '2026-07-28T10:00:00Z'},
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: 'https://api.asaancare.pk',
        timeout: const Duration(seconds: 15),
      );

      final dataSource = PrescriptionRemoteDataSource(
        apiClient: apiClient,
        tokenProvider: () async => 'valid_token',
        httpClient: mockClient,
      );

      final record = await dataSource.uploadPrescription(
        patientId: 'pat_1',
        fileName: 'test_prescription.pdf',
        fileBytes: Uint8List.fromList([1, 2, 3, 4]),
        contentType: 'application/pdf',
      );

      expect(record.id, 'rec_777');
      expect(record.patientId, 'pat_1');
      expect(record.source, PrescriptionSource.patientUploaded);
      expect(record.status, PrescriptionStatus.pending);
    });
  });

  group('PrescriptionRepositoryImpl Unit Tests', () {
    test('uses mockDataSource when useMockApi is true', () async {
      final mockDataSource = PrescriptionMockDataSource();
      final repository = PrescriptionRepositoryImpl(
        mockDataSource: mockDataSource,
      );

      final list = await repository.getPrescriptions(
        patientId: 'mock_patient_001',
      );
      expect(list.isNotEmpty, isTrue);
    });
  });
}
