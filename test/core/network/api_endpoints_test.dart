import 'package:asaancare/core/network/api_endpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiEndpoints', () {
    test('declares unique versioned absolute paths without double slashes', () {
      final paths = ApiEndpoints.declared.values.toList(growable: false);

      expect(paths.toSet(), hasLength(paths.length));

      for (final entry in ApiEndpoints.declared.entries) {
        expect(
          entry.value,
          startsWith('/v1/'),
          reason: '${entry.key} must use the v1 API namespace.',
        );
        expect(
          entry.value,
          isNot(contains('//')),
          reason: '${entry.key} must not contain accidental double slashes.',
        );
        expect(
          entry.value,
          matches(RegExp(r'^/v1/[a-z0-9/-]+$')),
          reason: '${entry.key} must be lowercase kebab-case path segments.',
        );
        expect(
          Uri.parse(entry.value).query,
          isEmpty,
          reason: '${entry.key} must not hard-code query parameters.',
        );
      }
    });

    test('keeps auth actions and clinical resource collections stable', () {
      expect(ApiEndpoints.authLogin, '/v1/auth/login');
      expect(ApiEndpoints.authRegister, '/v1/auth/register');
      expect(ApiEndpoints.authMe, '/v1/auth/me');
      expect(ApiEndpoints.authLogout, '/v1/auth/logout');
      expect(ApiEndpoints.doctors, '/v1/doctors');
      expect(ApiEndpoints.appointments, '/v1/appointments');
      expect(ApiEndpoints.prescriptions, '/v1/prescriptions');
      expect(ApiEndpoints.medicalRecords, '/v1/medical-records');
      expect(ApiEndpoints.patientProfile, '/v1/patients/me');
    });
  });
}
