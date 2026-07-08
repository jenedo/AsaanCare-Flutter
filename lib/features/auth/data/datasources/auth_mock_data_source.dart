import '../models/auth_user_model.dart';
import '../../domain/entities/auth_user.dart';

class AuthMockDataSource {
  AuthUserModel? _currentUser;

  Future<AuthUserModel?> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _currentUser;
  }

  Future<AuthUserModel> login({
    required String emailOrPhone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    final cleanEmailOrPhone = emailOrPhone.trim();

    if (cleanEmailOrPhone.isEmpty || password.trim().isEmpty) {
      throw AuthDataException('Email/phone and password are required.');
    }

    if (password.length < 6) {
      throw AuthDataException('Password must be at least 6 characters.');
    }

    _currentUser = AuthUserModel(
      id: 'mock_patient_001',
      fullName: 'AsaanCare Patient',
      emailOrPhone: cleanEmailOrPhone,
      role: UserRole.patient,
    );

    return _currentUser!;
  }

  Future<AuthUserModel> registerPatient({
    required String fullName,
    required String emailOrPhone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 750));

    final cleanFullName = fullName.trim();
    final cleanEmailOrPhone = emailOrPhone.trim();

    if (cleanFullName.isEmpty) {
      throw AuthDataException('Full name is required.');
    }

    if (cleanEmailOrPhone.isEmpty) {
      throw AuthDataException('Email or phone number is required.');
    }

    if (password.length < 6) {
      throw AuthDataException('Password must be at least 6 characters.');
    }

    _currentUser = AuthUserModel(
      id: 'mock_patient_001',
      fullName: cleanFullName,
      emailOrPhone: cleanEmailOrPhone,
      role: UserRole.patient,
    );

    return _currentUser!;
  }

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _currentUser = null;
  }
}

class AuthDataException implements Exception {
  const AuthDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
