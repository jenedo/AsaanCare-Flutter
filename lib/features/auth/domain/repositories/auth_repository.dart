import '../entities/auth_user.dart';
import '../entities/doctor_registration_payload.dart';

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

  Future<AuthUser> registerDoctor(DoctorRegistrationPayload payload);

  Future<void> logout();
}
