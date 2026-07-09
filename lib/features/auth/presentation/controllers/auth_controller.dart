// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../pharmacy/presentation/controllers/pharmacy_controller.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_patient.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required GetCurrentUser getCurrentUser,
    required LoginUser loginUser,
    required RegisterPatient registerPatient,
    required LogoutUser logoutUser,
  }) : _getCurrentUser = getCurrentUser,
       _loginUser = loginUser,
       _registerPatient = registerPatient,
       _logoutUser = logoutUser;

  final GetCurrentUser _getCurrentUser;
  final LoginUser _loginUser;
  final RegisterPatient _registerPatient;
  final LogoutUser _logoutUser;

  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  Future<void> loadCurrentUser() async {
    _setLoading(true);

    try {
      _currentUser = await _getCurrentUser();
      _errorMessage = null;
    } catch (error, stackTrace) {
      AppLogger.error('AuthController.loadCurrentUser', error, stackTrace);
      _currentUser = null;
      _errorMessage = 'Failed to restore your session.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String emailOrPhone,
    required String password,
  }) async {
    if (_isLoading) return false;

    _setLoading(true);

    try {
      _currentUser = await _loginUser(
        emailOrPhone: emailOrPhone,
        password: password,
      );
      _errorMessage = null;
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (error, stackTrace) {
      AppLogger.error('AuthController.login', error, stackTrace);
      _errorMessage = 'Login failed. Try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerPatient({
    required String fullName,
    required String emailOrPhone,
    required String password,
  }) async {
    if (_isLoading) return false;

    _setLoading(true);

    try {
      await _registerPatient(
        fullName: fullName,
        emailOrPhone: emailOrPhone,
        password: password,
      );
      _errorMessage = null;
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (error, stackTrace) {
      AppLogger.error('AuthController.registerPatient', error, stackTrace);
      _errorMessage = 'Registration failed. Try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    if (_isLoading) return;

    _setLoading(true);
    Object? remoteFailure;

    try {
      await _logoutUser();
    } catch (error, stackTrace) {
      remoteFailure = error;
      AppLogger.error('AuthController.logout', error, stackTrace);
    } finally {
      // Local user data must always be cleared, even if the remote logout
      // request fails, so another user cannot inherit the previous session.
      _currentUser = null;

      if (sl.isRegistered<PharmacyController>()) {
        sl<PharmacyController>().clearCart(resetSession: true);
      }

      _errorMessage = remoteFailure == null
          ? null
          : 'Signed out locally, but server session cleanup failed.';

      _setLoading(false);
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
