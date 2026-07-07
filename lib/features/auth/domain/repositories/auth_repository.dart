import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser?> getCurrentUser();

  Future<AuthUser> login({
    required String emailOrPhone,
    required String password,
  });

  Future<AuthUser> registerPatient({
    required String fullName,
    required String emailOrPhone,
    required String password,
  });

  Future<void> logout();
}
