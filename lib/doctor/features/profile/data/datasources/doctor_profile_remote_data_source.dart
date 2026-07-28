// ignore_for_file: prefer_initializing_formals

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../features/auth/domain/exceptions/auth_exception.dart';
import '../../domain/entities/doctor_profile_state.dart';

class DoctorProfileRemoteDataSource {
  DoctorProfileRemoteDataSource({
    required ApiClient apiClient,
    required AccessTokenProvider tokenProvider,
  }) : _apiClient = apiClient,
       _tokenProvider = tokenProvider;

  final ApiClient _apiClient;
  final AccessTokenProvider _tokenProvider;

  Future<DoctorProfileState> loadProfile({required String doctorId}) async {
    final token = await _getToken();
    final response = await _apiClient.getJson(
      ApiEndpoints.usersMe,
      bearerToken: token,
    );

    final rawUser = response['user'] ?? response['data'] ?? response;
    final userData = rawUser is Map<String, dynamic>
        ? rawUser
        : <String, dynamic>{};
    final docData = userData['doctorProfile'];

    if (docData is Map<String, dynamic>) {
      return DoctorProfileState(
        name:
            docData['fullName']?.toString() ??
            userData['email']?.toString() ??
            'Doctor',
        specialty: docData['specialty']?.toString() ?? 'General Physician',
        qualification:
            docData['qualification']?.toString() ??
            docData['pmdcNumber']?.toString() ??
            'MBBS',
        email: userData['email']?.toString() ?? '',
        phone: userData['mobile']?.toString() ?? '',
      );
    }

    return const DoctorProfileState();
  }

  Future<DoctorProfileState> saveProfile({
    required String doctorId,
    required DoctorProfileState state,
  }) async {
    final token = await _getToken();
    final body = <String, dynamic>{
      'fullName': state.name,
      'specialty': state.specialty,
      'qualification': state.qualification,
    };

    final response = await _apiClient.patchJson(
      '${ApiEndpoints.doctors}/me',
      body: body,
      bearerToken: token,
    );

    final docData = response['doctor'] ?? response['data'] ?? response;
    if (docData is Map<String, dynamic>) {
      return state.copyWith(
        name: docData['fullName']?.toString() ?? state.name,
        specialty: docData['specialty']?.toString() ?? state.specialty,
      );
    }

    return state;
  }

  Future<String> _getToken() async {
    final token = await _tokenProvider();
    if (token != null && token.trim().isNotEmpty) {
      return token.trim();
    }
    try {
      final currentSessionToken =
          Supabase.instance.client.auth.currentSession?.accessToken;
      if (currentSessionToken != null &&
          currentSessionToken.trim().isNotEmpty) {
        return currentSessionToken.trim();
      }
    } catch (_) {}

    throw const AuthException('Session expired. Please log in again.');
  }
}
