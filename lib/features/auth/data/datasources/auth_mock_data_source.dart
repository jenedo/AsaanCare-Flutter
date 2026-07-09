import '../../domain/entities/auth_user.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../models/auth_user_model.dart';
import 'auth_data_source.dart';

class AuthMockDataSource implements AuthDataSource {
  AuthMockDataSource() {
    _accounts[_normalizeIdentity(demoEmail)] = const _MockAccount(
      user: AuthUserModel(
        id: 'mock_patient_001',
        fullName: 'Sumiya Ibrahim',
        emailOrPhone: demoEmail,
        role: UserRole.patient,
      ),
      password: demoPassword,
    );
  }

  static const String demoEmail = 'sumiya@asaancare.pk';
  static const String demoPassword = 'password123';

  final Map<String, _MockAccount> _accounts = {};
  AuthUserModel? _currentUser;
  int _nextPatientNumber = 2;

  @override
  Future<AuthUserModel?> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _currentUser;
  }

  @override
  Future<AuthUserModel> login({
    required String emailOrPhone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final identity = _normalizeIdentity(emailOrPhone);
    _validateIdentity(identity);
    _validatePassword(password);

    final account = _accounts[identity];
    if (account == null || account.password != password) {
      throw const AuthException('Invalid email/phone or password.');
    }

    _currentUser = account.user;
    return account.user;
  }

  @override
  Future<AuthUserModel> registerPatient({
    required String fullName,
    required String emailOrPhone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final cleanName = fullName.trim();
    final identity = _normalizeIdentity(emailOrPhone);

    if (cleanName.length < 2) {
      throw const AuthException('Enter your full name.');
    }

    _validateIdentity(identity);
    _validatePassword(password);

    if (_accounts.containsKey(identity)) {
      throw const AuthException(
        'An account already exists for this email/phone.',
      );
    }

    final patientNumber = _nextPatientNumber++;
    final user = AuthUserModel(
      id: 'mock_patient_${patientNumber.toString().padLeft(3, '0')}',
      fullName: cleanName,
      emailOrPhone: emailOrPhone.trim(),
      role: UserRole.patient,
    );

    _accounts[identity] = _MockAccount(user: user, password: password);

    // Registration does not create a login session because the UI routes to Login.
    return user;
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _currentUser = null;
  }

  String _normalizeIdentity(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  void _validateIdentity(String identity) {
    if (identity.isEmpty) {
      throw const AuthException('Email or phone number is required.');
    }

    if (identity.contains('@')) {
      final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailPattern.hasMatch(identity)) {
        throw const AuthException('Enter a valid email address.');
      }
      return;
    }

    final phone = identity.replaceAll(RegExp(r'[^0-9+]'), '');
    if (phone.replaceAll('+', '').length < 10) {
      throw const AuthException('Enter a valid phone number.');
    }
  }

  void _validatePassword(String password) {
    if (password.length < 8) {
      throw const AuthException('Password must be at least 8 characters.');
    }
  }
}

class _MockAccount {
  const _MockAccount({required this.user, required this.password});

  final AuthUserModel user;
  final String password;
}
