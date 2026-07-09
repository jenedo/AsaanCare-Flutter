// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../models/auth_user_model.dart';
import 'auth_data_source.dart';

class AuthRemoteDataSource implements AuthDataSource {
  AuthRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;
  String? _accessToken;

  @override
  Future<AuthUserModel?> getCurrentUser() async {
    final token = _accessToken;
    if (token == null || token.isEmpty) return null;

    try {
      final response = await _apiClient.getJson(
        ApiEndpoints.authMe,
        bearerToken: token,
      );
      return _readUser(response);
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        _accessToken = null;
        return null;
      }
      throw AuthException(error.message);
    } on FormatException {
      throw const AuthException('The server returned invalid user data.');
    }
  }

  @override
  Future<AuthUserModel> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final response = await _apiClient.postJson(
        ApiEndpoints.authLogin,
        body: {'emailOrPhone': emailOrPhone.trim(), 'password': password},
      );

      final token = _readAccessToken(response);
      final user = _readUser(response);

      if (token == null) {
        throw const AuthException(
          'The login response did not include an access token.',
        );
      }

      _accessToken = token;
      return user;
    } on ApiException catch (error) {
      throw AuthException(error.message);
    } on FormatException {
      throw const AuthException('The server returned invalid login data.');
    }
  }

  @override
  Future<AuthUserModel> registerPatient({
    required String fullName,
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final response = await _apiClient.postJson(
        ApiEndpoints.authRegister,
        body: {
          'fullName': fullName.trim(),
          'emailOrPhone': emailOrPhone.trim(),
          'password': password,
          'role': 'patient',
        },
      );

      return _readUser(response);
    } on ApiException catch (error) {
      throw AuthException(error.message);
    } on FormatException {
      throw const AuthException(
        'The server returned invalid registration data.',
      );
    }
  }

  @override
  Future<void> logout() async {
    final token = _accessToken;
    _accessToken = null;

    if (token == null || token.isEmpty) return;

    try {
      await _apiClient.postJson(ApiEndpoints.authLogout, bearerToken: token);
    } on ApiException catch (error) {
      if (error.isUnauthorized) return;
      throw AuthException(error.message);
    }
  }

  AuthUserModel _readUser(JsonObject response) {
    final data = response['data'];
    final candidate =
        response['user'] ??
        (data is Map ? data['user'] : null) ??
        data ??
        response;

    if (candidate is Map<String, dynamic>) {
      return AuthUserModel.fromJson(candidate);
    }

    if (candidate is Map) {
      return AuthUserModel.fromJson(Map<String, dynamic>.from(candidate));
    }

    throw const FormatException('User object is missing.');
  }

  String? _readAccessToken(JsonObject response) {
    final data = response['data'];

    final candidate =
        response['accessToken'] ??
        response['access_token'] ??
        (data is Map ? data['accessToken'] ?? data['access_token'] : null);

    if (candidate is String && candidate.trim().isNotEmpty) {
      return candidate.trim();
    }

    return null;
  }
}
