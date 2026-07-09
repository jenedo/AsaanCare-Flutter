// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required AuthDataSource dataSource})
    : _dataSource = dataSource;

  final AuthDataSource _dataSource;

  @override
  Future<AuthUser?> getCurrentUser() {
    return _dataSource.getCurrentUser();
  }

  @override
  Future<AuthUser> login({
    required String emailOrPhone,
    required String password,
  }) {
    return _dataSource.login(emailOrPhone: emailOrPhone, password: password);
  }

  @override
  Future<AuthUser> registerPatient({
    required String fullName,
    required String emailOrPhone,
    required String password,
  }) {
    return _dataSource.registerPatient(
      fullName: fullName,
      emailOrPhone: emailOrPhone,
      password: password,
    );
  }

  @override
  Future<void> logout() {
    return _dataSource.logout();
  }
}
