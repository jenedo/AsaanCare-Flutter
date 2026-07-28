import 'dart:convert';

import 'package:asaancare/core/network/api_client.dart';
import 'package:asaancare/features/doctors/data/datasources/doctor_mock_data_source.dart';
import 'package:asaancare/features/doctors/data/datasources/doctor_remote_data_source.dart';
import 'package:asaancare/features/doctors/data/repositories/doctor_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('DoctorRemoteDataSource Unit Tests', () {
    test(
      'getDoctors fetches verified doctors list from GET /v1/doctors',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/v1/doctors');
          expect(request.headers['Authorization'], 'Bearer valid_token');
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': 'doc_101',
                  'fullName': 'Dr. Sara Ahmed',
                  'specialty': 'Cardiology',
                  'qualification': 'MBBS, FCPS',
                  'rating': 4.9,
                  'consultationFee': 1500,
                  'isVerified': true,
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

        final dataSource = DoctorRemoteDataSource(
          apiClient: apiClient,
          tokenProvider: () async => 'valid_token',
        );

        final doctors = await dataSource.getDoctors(specialty: 'Cardiology');
        expect(doctors.length, 1);
        expect(doctors.first.id, 'doc_101');
        expect(doctors.first.name, 'Dr. Sara Ahmed');
        expect(doctors.first.specialty, 'Cardiology');
      },
    );

    test(
      'getDoctorById fetches single doctor details from GET /v1/doctors/:id',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/v1/doctors/doc_101');
          return http.Response(
            jsonEncode({
              'data': {
                'id': 'doc_101',
                'fullName': 'Dr. Sara Ahmed',
                'specialty': 'Cardiology',
                'qualification': 'MBBS, FCPS',
                'isVerified': true,
              },
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

        final dataSource = DoctorRemoteDataSource(
          apiClient: apiClient,
          tokenProvider: () async => 'valid_token',
        );

        final doctor = await dataSource.getDoctorById('doc_101');
        expect(doctor.id, 'doc_101');
        expect(doctor.name, 'Dr. Sara Ahmed');
      },
    );
  });

  group('DoctorRepositoryImpl Unit Tests', () {
    test('uses mockDataSource when AppConfig.useMockApi is true', () async {
      final mockDataSource = DoctorMockDataSource();
      final repository = DoctorRepositoryImpl(mockDataSource: mockDataSource);

      final list = await repository.getDoctors();
      expect(list.isNotEmpty, isTrue);
    });
  });
}
