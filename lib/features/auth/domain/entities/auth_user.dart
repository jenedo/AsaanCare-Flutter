enum UserRole { patient, doctor, admin }

class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.emailOrPhone,
    required this.role,
  });

  final String id;
  final String fullName;
  final String emailOrPhone;
  final UserRole role;
}
