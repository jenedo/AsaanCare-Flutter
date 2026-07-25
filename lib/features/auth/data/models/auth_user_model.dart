import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.fullName,
    required super.emailOrPhone,
    required super.role,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final roleValue = _optionalString(json, const ['role']);

    if (roleValue == null) {
      throw const FormatException('Required user role is missing.');
    }

    final role = _roleFromString(roleValue);
    final profile = switch (role) {
      UserRole.patient => _optionalMap(json, const [
        'patientProfile',
        'patient_profile',
      ]),
      UserRole.doctor => _optionalMap(json, const [
        'doctorProfile',
        'doctor_profile',
      ]),
      UserRole.admin => null,
    };

    final fullName =
        _optionalString(json, const ['fullName', 'full_name', 'name']) ??
        (profile == null
            ? null
            : _optionalString(profile, const [
                'fullName',
                'full_name',
                'name',
              ]));

    if (fullName == null) {
      throw const FormatException('Required user full name is missing.');
    }

    return AuthUserModel(
      id: _requiredString(json, const ['id', 'userId', 'user_id']),
      fullName: fullName,
      emailOrPhone: _requiredString(json, const [
        'emailOrPhone',
        'email_or_phone',
        'email',
        'phone',
      ]),
      role: role,
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

  static Map<String, dynamic>? _optionalMap(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }

    return null;
  }

  static UserRole _roleFromString(String value) {
    final normalized = value.trim().toLowerCase();

    for (final role in UserRole.values) {
      if (role.name == normalized) {
        return role;
      }
    }

    throw FormatException('Unsupported user role: $value');
  }
}
