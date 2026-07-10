import 'package:asaancare/features/auth/data/models/auth_user_model.dart';
import 'package:asaancare/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> validJson({Object? role = 'patient'}) {
    return {
      'id': 'patient_001',
      'fullName': 'Ayesha Noor',
      'email': 'ayesha@example.com',
      'role': ?role,
    };
  }

  test('parses every valid user role', () {
    for (final role in UserRole.values) {
      final model = AuthUserModel.fromJson(validJson(role: role.name));

      expect(model.role, role);
    }
  });

  test('rejects a missing role', () {
    expect(
      () => AuthUserModel.fromJson(validJson(role: null)),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('role is missing'),
        ),
      ),
    );
  });

  test('rejects an unknown role', () {
    expect(
      () => AuthUserModel.fromJson(validJson(role: 'super_patient')),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('Unsupported user role'),
        ),
      ),
    );
  });
}
