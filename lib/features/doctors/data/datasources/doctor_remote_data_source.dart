// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../auth/domain/exceptions/auth_exception.dart';
import '../models/doctor_model.dart';

class DoctorRemoteDataSource {
  DoctorRemoteDataSource({
    required ApiClient apiClient,
    required AccessTokenProvider tokenProvider,
  }) : _apiClient = apiClient,
       _tokenProvider = tokenProvider;

  final ApiClient _apiClient;
  final AccessTokenProvider _tokenProvider;

  Future<List<DoctorModel>> getDoctors({
    String? specialty,
    String? city,
  }) async {
    final token = await _getToken();
    final queryParams = <String, String>{};
    if (specialty != null && specialty.trim().isNotEmpty) {
      queryParams['specialty'] = specialty.trim();
    }
    if (city != null && city.trim().isNotEmpty) {
      queryParams['city'] = city.trim();
    }

    final response = await _apiClient.getJson(
      ApiEndpoints.doctors,
      bearerToken: token,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final rawList = response['doctors'] ?? response['data'] ?? response;
    if (rawList is List) {
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(DoctorModel.fromJson)
          .toList(growable: false);
    }

    return const [];
  }

  Future<DoctorModel> getDoctorById(String id) {
    return getDoctorDetail(id);
  }

  Future<DoctorModel> getDoctorDetail(String doctorId) async {
    final token = await _getToken();
    final path = '${ApiEndpoints.doctors}/${doctorId.trim()}';
    final response = await _apiClient.getJson(path, bearerToken: token);

    final doctorData = response['doctor'] ?? response['data'] ?? response;
    if (doctorData is Map<String, dynamic>) {
      return DoctorModel.fromJson(doctorData);
    }

    return DoctorModel.fromJson(response);
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
