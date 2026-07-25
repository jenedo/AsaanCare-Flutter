// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/entities/auth_user.dart';
import '../../domain/entities/doctor_registration_payload.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../models/auth_user_model.dart';
import 'auth_data_source.dart';

class SupabaseAuthDataSource implements AuthDataSource {
  SupabaseAuthDataSource({required supabase.SupabaseClient client})
    : _client = client;

  final supabase.SupabaseClient _client;

  @override
  Future<AuthUserModel?> getCurrentUser() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;
    return _userFromAuthMetadata(authUser);
  }

  @override
  Future<AuthUserModel> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(
        email: emailOrPhone,
        password: password,
      );

      return _requireCurrentUser(
        'The authenticated user profile is unavailable.',
      );
    } on supabase.AuthException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<AuthUserModel> registerPatient({
    required String fullName,
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      await _client.auth.signUp(
        email: emailOrPhone,
        password: password,
        data: {'full_name': fullName, 'role': 'patient'},
      );

      return _requireCurrentUser(
        'The registered patient profile is unavailable.',
      );
    } on supabase.AuthException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<AuthUserModel> registerDoctor(
    DoctorRegistrationPayload payload,
  ) async {
    try {
      await _client.auth.signUp(
        email: payload.email,
        password: payload.password,
        data: {'full_name': payload.fullName, 'role': 'doctor'},
      );

      return _requireCurrentUser(
        'The registered doctor profile is unavailable.',
      );
    } on supabase.AuthException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } on supabase.AuthException catch (error) {
      throw AuthException(error.message);
    }
  }

  Future<AuthUserModel> _requireCurrentUser(String unavailableMessage) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw AuthException(unavailableMessage);
    }
    return user;
  }

  AuthUserModel _userFromAuthMetadata(supabase.User authUser) {
    final metadata = authUser.userMetadata ?? const <String, dynamic>{};

    return AuthUserModel(
      id: authUser.id,
      fullName: _metadataString(metadata['full_name']),
      emailOrPhone: authUser.email ?? '',
      role: _roleFromMetadata(metadata['role']),
    );
  }

  String _metadataString(Object? value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  UserRole _roleFromMetadata(Object? value) {
    final normalized = _metadataString(value).toLowerCase();

    for (final role in UserRole.values) {
      if (role.name == normalized) return role;
    }

    return UserRole.patient;
  }
}
