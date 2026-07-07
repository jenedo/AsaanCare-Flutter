import '../models/auth_user_model.dart';

class AuthRemoteDataSource {
  Future<AuthUserModel?> getCurrentUser() {
    throw UnimplementedError(
      'AuthRemoteDataSource.getCurrentUser will be connected to NestJS later.',
    );
  }

  Future<AuthUserModel> login({
    required String emailOrPhone,
    required String password,
  }) {
    throw UnimplementedError(
      'AuthRemoteDataSource.login will be connected to NestJS later.',
    );
  }

  Future<AuthUserModel> registerPatient({
    required String fullName,
    required String emailOrPhone,
    required String password,
  }) {
    throw UnimplementedError(
      'AuthRemoteDataSource.registerPatient will be connected to NestJS later.',
    );
  }

  Future<void> logout() {
    throw UnimplementedError(
      'AuthRemoteDataSource.logout will be connected to NestJS later.',
    );
  }
}
