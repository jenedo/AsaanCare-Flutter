import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:asaancare/core/network/api_client.dart';
import 'package:asaancare/core/network/api_exception.dart';
import 'package:asaancare/features/clinical_prescriptions/data/datasources/clinical_prescription_remote_data_source.dart';
import 'package:asaancare/features/clinical_prescriptions/data/models/clinical_prescription_model.dart';
import 'package:asaancare/features/clinical_prescriptions/data/repositories/clinical_prescription_repository_impl.dart';
import 'package:asaancare/features/clinical_prescriptions/domain/entities/clinical_prescription.dart';

void main() {
  const baseUrl = 'https://api.asaancare.test/api';
  const validToken = 'valid-jwt-token';

  group('ClinicalPrescriptionModel JSON & Status Mapping', () {
    test(
      'maps ISSUED status correctly to ClinicalPrescriptionStatus.issued',
      () {
        final json = {
          'id': 'presc-001',
          'appointmentId': 'appt-001',
          'doctorProfileId': 'doc-001',
          'patientProfileId': 'pat-001',
          'status': 'ISSUED',
          'version': 1,
          'medicines': [
            {
              'name': 'Amoxicillin',
              'dosage': '500mg',
              'frequency': '3x daily',
              'duration': '7 days',
              'instructions': 'After meals',
              'route': 'oral',
              'notes': 'Take with full glass of water',
            },
          ],
          'instructions': 'Rest and drink water',
          'issuedAt': '2026-07-25T10:00:00.000Z',
          'createdAt': '2026-07-25T10:00:00.000Z',
          'doctorProfile': {'id': 'doc-001', 'fullName': 'Dr. Ali Raza'},
        };

        final model = ClinicalPrescriptionModel.fromJson(json);

        expect(model.id, 'presc-001');
        expect(model.status, ClinicalPrescriptionStatus.issued);
        expect(model.isIssued, isTrue);
        expect(model.isSuperseded, isFalse);
        expect(model.isVoided, isFalse);
        expect(model.medicines.length, 1);
        expect(model.medicines.first.name, 'Amoxicillin');
        expect(model.medicines.first.route, 'oral');
        expect(model.medicines.first.notes, 'Take with full glass of water');
        expect(model.doctorName, 'Dr. Ali Raza');
      },
    );

    test(
      'maps SUPERSEDED status correctly to ClinicalPrescriptionStatus.superseded',
      () {
        final json = {
          'id': 'presc-002',
          'appointmentId': 'appt-002',
          'doctorProfileId': 'doc-001',
          'patientProfileId': 'pat-001',
          'status': 'SUPERSEDED',
          'version': 2,
          'medicines': [],
          'issuedAt': '2026-07-25T10:00:00.000Z',
          'createdAt': '2026-07-25T10:00:00.000Z',
        };

        final model = ClinicalPrescriptionModel.fromJson(json);
        expect(model.status, ClinicalPrescriptionStatus.superseded);
        expect(model.isSuperseded, isTrue);
      },
    );

    test(
      'maps VOIDED status correctly to ClinicalPrescriptionStatus.voided',
      () {
        final json = {
          'id': 'presc-003',
          'appointmentId': 'appt-003',
          'doctorProfileId': 'doc-001',
          'patientProfileId': 'pat-001',
          'status': 'VOIDED',
          'version': 1,
          'medicines': [],
          'issuedAt': '2026-07-25T10:00:00.000Z',
          'createdAt': '2026-07-25T10:00:00.000Z',
        };

        final model = ClinicalPrescriptionModel.fromJson(json);
        expect(model.status, ClinicalPrescriptionStatus.voided);
        expect(model.isVoided, isTrue);
      },
    );

    test('throws FormatException when encountering unknown status', () {
      final json = {
        'id': 'presc-004',
        'appointmentId': 'appt-004',
        'doctorProfileId': 'doc-001',
        'patientProfileId': 'pat-001',
        'status': 'UNKNOWN_STATUS_XYZ',
        'version': 1,
        'medicines': [],
        'issuedAt': '2026-07-25T10:00:00.000Z',
        'createdAt': '2026-07-25T10:00:00.000Z',
      };

      expect(
        () => ClinicalPrescriptionModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('ClinicalPrescriptionRemoteDataSource & Repository Integration', () {
    test(
      'throws 401 ApiException when access token is missing or null',
      () async {
        final mockClient = MockClient(
          (request) async => http.Response('[]', 200),
        );
        final apiClient = ApiClient(
          client: mockClient,
          baseUrl: baseUrl,
          timeout: const Duration(seconds: 5),
        );

        final dataSource = ClinicalPrescriptionRemoteDataSource(
          apiClient: apiClient,
          tokenProvider: () async => null,
        );

        expect(
          () => dataSource.getClinicalPrescriptions(),
          throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
          ),
        );
      },
    );

    test('parses raw array response from GET /v1/prescriptions', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/v1/prescriptions'));
        expect(request.headers['Authorization'], 'Bearer $validToken');
        return http.Response(
          jsonEncode([
            {
              'id': 'presc-101',
              'appointmentId': 'appt-101',
              'doctorProfileId': 'doc-101',
              'patientProfileId': 'pat-101',
              'status': 'ISSUED',
              'version': 1,
              'medicines': [],
              'issuedAt': '2026-07-25T10:00:00.000Z',
              'createdAt': '2026-07-25T10:00:00.000Z',
            },
          ]),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final repository = ClinicalPrescriptionRepositoryImpl(
        remoteDataSource: ClinicalPrescriptionRemoteDataSource(
          apiClient: apiClient,
          tokenProvider: () async => validToken,
        ),
      );

      final list = await repository.getClinicalPrescriptions();
      expect(list.length, 1);
      expect(list.first.id, 'presc-101');
      expect(list.first.status, ClinicalPrescriptionStatus.issued);
    });

    test(
      'fetches single prescription by ID via GET /v1/prescriptions/:id with full details',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, endsWith('/v1/prescriptions/presc-777'));
          return http.Response(
            jsonEncode({
              'id': 'presc-777',
              'appointmentId': 'appt-777',
              'doctorProfileId': 'doc-777',
              'patientProfileId': 'pat-777',
              'status': 'ISSUED',
              'version': 1,
              'medicines': [
                {
                  'name': 'Panadol Extra',
                  'dosage': '500mg',
                  'frequency': '2x daily',
                  'duration': '5 days',
                  'instructions': 'After food',
                  'route': 'oral',
                  'notes': 'Keep hydrated',
                },
              ],
              'instructions': 'Follow dosage carefully',
              'issuedAt': '2026-07-25T12:34:56.000Z',
              'createdAt': '2026-07-25T12:34:56.000Z',
            }),
            200,
          );
        });

        final apiClient = ApiClient(
          client: mockClient,
          baseUrl: baseUrl,
          timeout: const Duration(seconds: 5),
        );

        final repository = ClinicalPrescriptionRepositoryImpl(
          remoteDataSource: ClinicalPrescriptionRemoteDataSource(
            apiClient: apiClient,
            tokenProvider: () async => validToken,
          ),
        );

        final detail = await repository.getClinicalPrescription('presc-777');
        expect(detail.id, 'presc-777');
        expect(detail.status, ClinicalPrescriptionStatus.issued);
        expect(detail.issuedAt, DateTime.parse('2026-07-25T12:34:56.000Z'));
        expect(detail.medicines.first.name, 'Panadol Extra');
        expect(detail.medicines.first.route, 'oral');
        expect(detail.medicines.first.notes, 'Keep hydrated');
      },
    );

    test('handles 403 Forbidden backend error gracefully', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'message': 'You do not have access to this prescription',
          }),
          403,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final repository = ClinicalPrescriptionRepositoryImpl(
        remoteDataSource: ClinicalPrescriptionRemoteDataSource(
          apiClient: apiClient,
          tokenProvider: () async => validToken,
        ),
      );

      expect(
        () => repository.getClinicalPrescription('presc-403'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 403)
              .having((e) => e.message, 'message', contains('access')),
        ),
      );
    });

    test('handles 404 Not Found backend error gracefully', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Prescription not found'}),
          404,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: baseUrl,
        timeout: const Duration(seconds: 5),
      );

      final repository = ClinicalPrescriptionRepositoryImpl(
        remoteDataSource: ClinicalPrescriptionRemoteDataSource(
          apiClient: apiClient,
          tokenProvider: () async => validToken,
        ),
      );

      expect(
        () => repository.getClinicalPrescription('non-existent-id'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having((e) => e.message, 'message', contains('not found')),
        ),
      );
    });
  });
}
