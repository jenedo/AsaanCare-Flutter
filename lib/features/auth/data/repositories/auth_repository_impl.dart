import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_mock_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required this._mockDataSource});

  final AuthMockDataSource _mockDataSource;

  @override
  Future<AuthUser?> getCurrentUser() {
    return _mockDataSource.getCurrentUser();
  }

  @override
  Future<AuthUser> login({
    required String emailOrPhone,
    required String password,
  }) {
    return _mockDataSource.login(
      emailOrPhone: emailOrPhone,
      password: password,
    );
  }

  @override
  Future<AuthUser> registerPatient({
    required String fullName,
    required String emailOrPhone,
    required String password,
  }) {
    return _mockDataSource.registerPatient(
      fullName: fullName,
      emailOrPhone: emailOrPhone,
      password: password,
    );
  }

  @override
  Future<void> logout() {
    return _mockDataSource.logout();
  }
}
