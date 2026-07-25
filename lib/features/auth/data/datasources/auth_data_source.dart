import '../../domain/entities/doctor_registration_payload.dart';
import '../models/auth_user_model.dart';

abstract interface class AuthDataSource {
  Future<AuthUserModel?> getCurrentUser();

  Future<AuthUserModel> login({
    required String emailOrPhone,
    required String password,
  });

  Future<AuthUserModel> registerPatient({
    required String fullName,
    required String emailOrPhone,
    required String password,
  });

  Future<AuthUserModel> registerDoctor(DoctorRegistrationPayload payload);

  Future<void> logout();
}
