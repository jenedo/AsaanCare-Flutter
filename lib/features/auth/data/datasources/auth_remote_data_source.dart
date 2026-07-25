// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals
import 'package:http/http.dart' as http;

import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/doctor_registration_payload.dart';
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
    final accessToken = await _readStoredAccessToken();

    if (accessToken == null) {
      await _clearStoredTokens();
      return null;
    }

    return _hydrateCurrentUser(accessToken, returnNullWhenUnauthorized: true);
  }

  @override
  Future<AuthUserModel> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final response = await _apiClient.postJson(
        ApiEndpoints.authLogin,
        body: {'email': emailOrPhone.trim(), 'password': password},
      );

      final accessToken = _readAccessToken(response);
      final refreshToken = _readRefreshToken(response);

      if (accessToken == null || refreshToken == null) {
        await _bestEffortClearStoredTokens();
        throw const AuthException(
          'The login response did not include a complete token pair.',
        );
      }

      await _writeStoredTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      final user = await _hydrateCurrentUser(
        accessToken,
        returnNullWhenUnauthorized: false,
      );

      if (user == null) {
        await _clearStoredTokens();
        throw const AuthException(
          'The authenticated user profile is unavailable.',
        );
      }

      return user;
    } on AuthException {
      rethrow;
    } on ApiException catch (error) {
      throw AuthException(error.message);
    } on FormatException {
      await _bestEffortClearStoredTokens();
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
      await _apiClient.postJson(
        ApiEndpoints.authRegister,
        body: {
          'fullName': fullName.trim(),
          'email': emailOrPhone.trim(),
          'password': password,
          'role': 'PATIENT',
        },
      );

      return login(emailOrPhone: emailOrPhone, password: password);
    } on AuthException {
      rethrow;
    } on ApiException catch (error) {
      throw AuthException(error.message);
    } on FormatException {
      throw const AuthException(
        'The server returned invalid registration data.',
      );
    }
  }

  @override
  Future<AuthUserModel> registerDoctor(
    DoctorRegistrationPayload payload,
  ) async {
    try {
      await _apiClient.postMultipart(
        ApiEndpoints.authRegister,
        fields: {
          'fullName': payload.fullName.trim(),
          'email': payload.email.trim(),
          'mobile': payload.phone.trim(),
          'password': payload.password,
          'role': 'DOCTOR',
          'gender': payload.gender.trim(),
          'pmdcNumber': payload.pmdcOrLicenseNumber.trim(),
          'specialty': payload.specialty.trim(),
          'yearsOfExperience': payload.yearsOfExperience.toString(),
          'hospitalOrClinicName': payload.hospitalOrClinicName.trim(),
          'consultationFeePkr': payload.consultationFeePkr.toString(),
        },
        files: [
          http.MultipartFile.fromBytes(
            'medicalLicense',
            payload.medicalLicense.bytes,
            filename: payload.medicalLicense.name,
          ),
          http.MultipartFile.fromBytes(
            'idFront',
            payload.idFront.bytes,
            filename: payload.idFront.name,
          ),
          http.MultipartFile.fromBytes(
            'idBack',
            payload.idBack.bytes,
            filename: payload.idBack.name,
          ),
        ],
      );

      return login(
        emailOrPhone: payload.email.trim(),
        password: payload.password,
      );
    } on AuthException {
      rethrow;
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
    try {
      final refreshToken = await _readStoredRefreshToken();
      if (refreshToken == null) return;

      try {
        await _apiClient.postJson(
          ApiEndpoints.authLogout,
          body: {'refreshToken': refreshToken},
        );
      } on ApiException catch (error) {
        if (error.isUnauthorized) return;
        throw AuthException(error.message);
      }
    } finally {
      await _clearStoredTokens();
    }
  }

  Future<AuthUserModel?> _hydrateCurrentUser(
    String accessToken, {
    required bool returnNullWhenUnauthorized,
  }) async {
    try {
      final response = await _apiClient.getJson(
        ApiEndpoints.usersMe,
        bearerToken: accessToken,
      );
      return _readUser(response);
    } on ApiException catch (error) {
      if (_isTerminalProfileFailure(error)) {
        await _clearStoredTokens();
      }

      if (error.isUnauthorized && returnNullWhenUnauthorized) {
        return null;
      }

      if (_isTerminalProfileFailure(error)) {
        throw const AuthException(
          'Your authenticated profile could not be verified. Please sign in again.',
        );
      }

      throw const AuthException(
        'Signed in, but your profile could not be loaded. Please try again.',
      );
    } on FormatException {
      await _clearStoredTokens();
      throw const AuthException(
        'The server returned invalid authenticated user data.',
      );
    }
  }

  bool _isTerminalProfileFailure(ApiException error) {
    final statusCode = error.statusCode;
    return statusCode != null &&
        statusCode >= 400 &&
        statusCode < 500 &&
        statusCode != 408 &&
        statusCode != 429;
  }

  Future<String?> _readStoredAccessToken() async {
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

  Future<String?> _readStoredRefreshToken() async {
    try {
      return await _tokenStore.readRefreshToken();
    } catch (error, stackTrace) {
      AppLogger.error(
        'AuthRemoteDataSource.readRefreshToken',
        error,
        stackTrace,
      );
      throw const AuthException(
        'Could not restore your secure session. Please log in again.',
      );
    }
  }

  Future<void> _writeStoredTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _clearStoredTokens();
      await _tokenStore.writeRefreshToken(refreshToken);
      await _tokenStore.writeAccessToken(accessToken);
    } catch (error, stackTrace) {
      AppLogger.error('AuthRemoteDataSource.writeTokens', error, stackTrace);
      await _bestEffortClearStoredTokens();
      throw const AuthException(
        'Could not securely save your session. Please try again.',
      );
    }
  }

  Future<void> _clearStoredTokens() async {
    try {
      await Future.wait([
        _tokenStore.clearAccessToken(),
        _tokenStore.clearRefreshToken(),
      ]);
    } catch (error, stackTrace) {
      AppLogger.error('AuthRemoteDataSource.clearTokens', error, stackTrace);
      throw const AuthException(
        'Could not securely clear your session. Please try again.',
      );
    }
  }

  Future<void> _bestEffortClearStoredTokens() async {
    try {
      await Future.wait([
        _tokenStore.clearAccessToken(),
        _tokenStore.clearRefreshToken(),
      ]);
    } catch (error, stackTrace) {
      AppLogger.error('AuthRemoteDataSource.cleanupTokens', error, stackTrace);
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

  String? _readRefreshToken(JsonObject response) {
    final data = response['data'];

    final candidate =
        response['refreshToken'] ??
        response['refresh_token'] ??
        (data is Map ? data['refreshToken'] ?? data['refresh_token'] : null);

    if (candidate is String && candidate.trim().isNotEmpty) {
      return candidate.trim();
    }

    return null;
  }
}
