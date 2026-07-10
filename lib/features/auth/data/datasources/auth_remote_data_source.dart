// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../models/auth_user_model.dart';
import '../storage/auth_token_store.dart';
import 'auth_data_source.dart';

class AuthRemoteDataSource implements AuthDataSource {
  AuthRemoteDataSource({
    required ApiClient apiClient,
    required AuthTokenStore tokenStore,
  }) : _apiClient = apiClient,
       _tokenStore = tokenStore;

  final ApiClient _apiClient;
  final AuthTokenStore _tokenStore;

  @override
  Future<AuthUserModel?> getCurrentUser() async {
    final token = await _readStoredToken();
    if (token == null) return null;

    try {
      final response = await _apiClient.getJson(
        ApiEndpoints.authMe,
        bearerToken: token,
      );
      return _readUser(response);
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await _clearStoredToken();
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

      await _writeStoredToken(token);
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
    final token = await _readStoredToken();
    await _clearStoredToken();

    if (token == null) return;

    try {
      await _apiClient.postJson(ApiEndpoints.authLogout, bearerToken: token);
    } on ApiException catch (error) {
      if (error.isUnauthorized) return;
      throw AuthException(error.message);
    }
  }

  Future<String?> _readStoredToken() async {
    try {
      return await _tokenStore.readAccessToken();
    } catch (error, stackTrace) {
      AppLogger.error(
        'AuthRemoteDataSource.readAccessToken',
        error,
        stackTrace,
      );
      throw const AuthException(
        'Could not restore your secure session. Please log in again.',
      );
    }
  }

  Future<void> _writeStoredToken(String token) async {
    try {
      await _tokenStore.writeAccessToken(token);
    } catch (error, stackTrace) {
      AppLogger.error(
        'AuthRemoteDataSource.writeAccessToken',
        error,
        stackTrace,
      );
      throw const AuthException(
        'Could not securely save your session. Please try again.',
      );
    }
  }

  Future<void> _clearStoredToken() async {
    try {
      await _tokenStore.clearAccessToken();
    } catch (error, stackTrace) {
      AppLogger.error(
        'AuthRemoteDataSource.clearAccessToken',
        error,
        stackTrace,
      );
      throw const AuthException(
        'Could not securely clear your session. Please try again.',
      );
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
