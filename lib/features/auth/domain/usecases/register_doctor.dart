import '../entities/auth_user.dart';
import '../entities/doctor_registration_payload.dart';
import '../repositories/auth_repository.dart';

class RegisterDoctor {
  const RegisterDoctor(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call(DoctorRegistrationPayload payload) {
    return _repository.registerDoctor(payload);
  }
}
