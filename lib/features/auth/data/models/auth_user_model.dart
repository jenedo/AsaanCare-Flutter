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
      id: _requiredString(json, const ['id', 'userId', 'user_id']),
      fullName: _requiredString(json, const ['fullName', 'full_name', 'name']),
      emailOrPhone: _requiredString(json, const [
        'emailOrPhone',
        'email_or_phone',
        'email',
        'phone',
      ]),
      role: _roleFromString(
        _optionalString(json, const ['role']) ?? UserRole.patient.name,
      ),
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

  static String _requiredString(Map<String, dynamic> json, List<String> keys) {
    final value = _optionalString(json, keys);
    if (value == null) {
      throw const FormatException('Required user field is missing.');
    }
    return value;
  }

  static String? _optionalString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return null;
  }

  static UserRole _roleFromString(String value) {
    final normalized = value.trim().toLowerCase();

    return UserRole.values.firstWhere(
      (role) => role.name == normalized,
      orElse: () => UserRole.patient,
    );
  }
}
