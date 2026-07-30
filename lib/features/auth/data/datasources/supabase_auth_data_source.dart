// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/doctor_registration_payload.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../models/auth_user_model.dart';
import 'auth_data_source.dart';

class SupabaseAuthDataSource implements AuthDataSource {
  SupabaseAuthDataSource({
    required supabase.SupabaseClient client,
    required ApiClient apiClient,
  }) : _client = client,
       _apiClient = apiClient;

  final supabase.SupabaseClient _client;
  final ApiClient _apiClient;

  @override
  Future<AuthUserModel?> getCurrentUser() async {
    final authUser = _client.auth.currentUser;
    final session = _client.auth.currentSession;
    if (authUser == null || session == null) return null;

    return _bootstrapUser(
      accessToken: session.accessToken,
      requestedRole: UserRole.patient,
    );
  }

  @override
  Future<AuthUserModel> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: emailOrPhone,
        password: password,
      );

      return _bootstrapAuthResponse(
        response,
        requestedRole: UserRole.patient,
        unavailableMessage: 'The authenticated user profile is unavailable.',
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
      final response = await _client.auth.signUp(
        email: emailOrPhone,
        password: password,
        data: {'full_name': fullName, 'role': 'patient'},
      );

      return _bootstrapAuthResponse(
        response,
        requestedRole: UserRole.patient,
        fullName: fullName,
        unavailableMessage: 'The registered patient profile is unavailable.',
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
      final response = await _client.auth.signUp(
        email: payload.email,
        password: payload.password,
        data: {'full_name': payload.fullName, 'role': 'doctor'},
      );

      return _bootstrapAuthResponse(
        response,
        requestedRole: UserRole.doctor,
        fullName: payload.fullName,
        pmdcNumber: payload.pmdcOrLicenseNumber,
        specialty: payload.specialty,
        unavailableMessage: 'The registered doctor profile is unavailable.',
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

  Future<AuthUserModel> _bootstrapAuthResponse(
    supabase.AuthResponse response, {
    required UserRole requestedRole,
    required String unavailableMessage,
    String? fullName,
    String? pmdcNumber,
    String? specialty,
  }) {
    final authUser = response.user ?? _client.auth.currentUser;
    final session = response.session ?? _client.auth.currentSession;

    if (authUser == null || session == null) {
      throw AuthException(unavailableMessage);
    }

    return _bootstrapUser(
      accessToken: session.accessToken,
      requestedRole: requestedRole,
      fullName: fullName,
      pmdcNumber: pmdcNumber,
      specialty: specialty,
    );
  }

  Future<AuthUserModel> _bootstrapUser({
    required String accessToken,
    required UserRole requestedRole,
    String? fullName,
    String? pmdcNumber,
    String? specialty,
  }) async {
    final response = await _apiClient.postJson(
      ApiEndpoints.authBootstrap,
      bearerToken: accessToken,
      body: {
        'role': requestedRole.name.toUpperCase(),
        if (fullName != null && fullName.trim().isNotEmpty)
          'fullName': fullName.trim(),
        if (pmdcNumber != null && pmdcNumber.trim().isNotEmpty)
          'pmdcNumber': pmdcNumber.trim(),
        if (specialty != null && specialty.trim().isNotEmpty)
          'specialty': specialty.trim(),
      },
    );

    try {
      final data = _requireJsonObject(response['data']);
      final user = _requireJsonObject(data['user']);
      return AuthUserModel.fromJson(user);
    } on FormatException catch (error) {
      throw ApiException(
        'The server returned an invalid application profile.',
        cause: error,
      );
    }
  }

  Map<String, dynamic> _requireJsonObject(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw const FormatException('Required response object is missing.');
  }
}
