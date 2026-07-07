import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.fullName,
    required super.emailOrPhone,
    required super.role,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      emailOrPhone: json['emailOrPhone'] as String,
      role: _roleFromString(json['role'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'emailOrPhone': emailOrPhone,
      'role': role.name,
    };
  }

  static UserRole _roleFromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.patient,
    );
  }
}
