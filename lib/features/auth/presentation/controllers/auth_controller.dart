import 'package:flutter/foundation.dart';

import '../../data/datasources/auth_mock_data_source.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_patient.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required this._getCurrentUser,
    required this._loginUser,
    required this._registerPatient,
    required this._logoutUser,
  });

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
    } catch (_) {
      _errorMessage = 'Failed to load current user.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String emailOrPhone,
    required String password,
  }) async {
    _setLoading(true);

    try {
      _currentUser = await _loginUser(
        emailOrPhone: emailOrPhone,
        password: password,
      );
      _errorMessage = null;
      return true;
    } on AuthDataException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
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
    _setLoading(true);

    try {
      await _registerPatient(
        fullName: fullName,
        emailOrPhone: emailOrPhone,
        password: password,
      );
      _errorMessage = null;
      return true;
    } on AuthDataException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Registration failed. Try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _logoutUser();
      _currentUser = null;
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Logout failed. Try again.';
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
