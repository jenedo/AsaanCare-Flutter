import 'dart:convert';

import 'package:asaancare/core/network/api_client.dart';
import 'package:asaancare/doctor/features/profile/data/datasources/doctor_profile_mock_data_source.dart';
import 'package:asaancare/doctor/features/profile/data/datasources/doctor_profile_remote_data_source.dart';
import 'package:asaancare/doctor/features/profile/data/repositories/doctor_profile_repository_impl.dart';
import 'package:asaancare/doctor/features/profile/domain/entities/doctor_profile_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('DoctorProfileRemoteDataSource Unit Tests', () {
    test('loadProfile parses doctor profile from GET /v1/users/me', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/v1/users/me');
        return http.Response(
          jsonEncode({
            'user': {
              'id': 'u_1',
              'email': 'dr.ali@asaancare.pk',
              'mobile': '+923001234567',
              'doctorProfile': {
                'fullName': 'Dr. Ali Raza',
                'specialty': 'Cardiologist',
                'pmdcNumber': 'PMDC-999',
              },
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

      final dataSource = DoctorProfileRemoteDataSource(
        apiClient: apiClient,
        tokenProvider: () async => 'valid_token',
      );

      final state = await dataSource.loadProfile(doctorId: 'u_1');
      expect(state.name, 'Dr. Ali Raza');
      expect(state.specialty, 'Cardiologist');
      expect(state.email, 'dr.ali@asaancare.pk');
    });

    test('saveProfile updates profile via PATCH /v1/doctors/me', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/v1/doctors/me');
        expect(request.method, 'PATCH');
        return http.Response(
          jsonEncode({
            'doctor': {
              'fullName': 'Dr. Ali Raza Updated',
              'specialty': 'Cardiologist',
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

      final dataSource = DoctorProfileRemoteDataSource(
        apiClient: apiClient,
        tokenProvider: () async => 'valid_token',
      );

      final updated = await dataSource.saveProfile(
        doctorId: 'u_1',
        state: const DoctorProfileState(name: 'Dr. Ali Raza Updated'),
      );

      expect(updated.name, 'Dr. Ali Raza Updated');
    });
  });

  group('DoctorProfileRepositoryImpl Unit Tests', () {
    test('uses mockDataSource when AppConfig.useMockApi is true', () async {
      final mockDataSource = DoctorProfileMockDataSource();
      final repository = DoctorProfileRepositoryImpl(
        mockDataSource: mockDataSource,
      );

      final state = await repository.loadProfile(doctorId: 'u_1');
      expect(state.name, isNotEmpty);
    });
  });
}
