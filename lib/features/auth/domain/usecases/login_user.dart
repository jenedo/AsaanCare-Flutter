import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class LoginUser {
  const LoginUser(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String emailOrPhone,
    required String password,
  }) {
    return _repository.login(emailOrPhone: emailOrPhone, password: password);
  }
}
