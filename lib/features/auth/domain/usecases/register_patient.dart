import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class RegisterPatient {
  const RegisterPatient(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String fullName,
    required String emailOrPhone,
    required String password,
  }) {
    return _repository.registerPatient(
      fullName: fullName,
      emailOrPhone: emailOrPhone,
      password: password,
    );
  }
}
