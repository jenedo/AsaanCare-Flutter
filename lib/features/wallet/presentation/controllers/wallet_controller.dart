// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/wallet_account.dart';
import '../../domain/entities/wallet_payment_method.dart';
import '../../domain/entities/wallet_snapshot.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/exceptions/wallet_exception.dart';
import '../../domain/usecases/add_wallet_money.dart';
import '../../domain/usecases/get_wallet_snapshot.dart';
import '../../domain/usecases/wallet_payment_method_actions.dart';

enum WalletStatus { initial, loading, loaded, error }

class WalletController extends ChangeNotifier {
  WalletController({
    required GetWalletSnapshot getWalletSnapshot,
    required AddWalletMoney addWalletMoney,
    required AddWalletPaymentMethod addPaymentMethod,
    required SetDefaultWalletPaymentMethod setDefaultPaymentMethod,
    required RemoveWalletPaymentMethod removePaymentMethod,
  }) : _getWalletSnapshot = getWalletSnapshot,
       _addWalletMoney = addWalletMoney,
       _addPaymentMethod = addPaymentMethod,
       _setDefaultPaymentMethod = setDefaultPaymentMethod,
       _removePaymentMethod = removePaymentMethod;

  final GetWalletSnapshot _getWalletSnapshot;
  final AddWalletMoney _addWalletMoney;
  final AddWalletPaymentMethod _addPaymentMethod;
  final SetDefaultWalletPaymentMethod _setDefaultPaymentMethod;
  final RemoveWalletPaymentMethod _removePaymentMethod;

  WalletSnapshot? _snapshot;
  WalletStatus _status = WalletStatus.initial;
  String? _errorMessage;
  String? _successMessage;
  bool _isBalanceVisible = true;
  bool _isAddingMoney = false;
  bool _isUpdatingPaymentMethods = false;

  WalletSnapshot? get snapshot => _snapshot;
  WalletAccount? get account => _snapshot?.account;

  List<WalletTransaction> get transactions =>
      _snapshot?.transactions ?? const [];

  List<WalletPaymentMethod> get paymentMethods =>
      _snapshot?.paymentMethods ?? const [];

  WalletStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool get isInitial => _status == WalletStatus.initial;
  bool get isLoading => _status == WalletStatus.loading;
  bool get isLoaded => _status == WalletStatus.loaded;
  bool get hasError => _status == WalletStatus.error;
  bool get isBalanceVisible => _isBalanceVisible;
  bool get isAddingMoney => _isAddingMoney;
  bool get isUpdatingPaymentMethods => _isUpdatingPaymentMethods;

  bool get isBusy => isLoading || isAddingMoney || isUpdatingPaymentMethods;

  int get balance => account?.balance ?? 0;

  List<WalletTransaction> get recentTransactions =>
      transactions.take(4).toList(growable: false);

  WalletPaymentMethod? get defaultPaymentMethod {
    for (final method in paymentMethods) {
      if (method.isDefault) {
        return method;
      }
    }

    return paymentMethods.isEmpty ? null : paymentMethods.first;
  }

  Future<void> load({
    required String patientId,
    bool forceRefresh = false,
  }) async {
    if (_status == WalletStatus.loading) return;

    if (!forceRefresh && _status == WalletStatus.loaded) {
      return;
    }

    _status = WalletStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _reloadSnapshot(patientId);
      _status = WalletStatus.loaded;
    } on WalletException catch (error) {
      _status = WalletStatus.error;
      _errorMessage = error.message;
    } catch (error, stackTrace) {
      AppLogger.error('WalletController.load', error, stackTrace);
      _status = WalletStatus.error;
      _errorMessage = 'Could not load your wallet. Please try again.';
    }

    notifyListeners();
  }

  Future<void> refresh(String patientId) {
    return load(patientId: patientId, forceRefresh: true);
  }

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  Future<bool> addMoney({
    required String patientId,
    required int amount,
    required String paymentMethodId,
  }) async {
    if (_isAddingMoney) return false;

    _isAddingMoney = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _addWalletMoney(
        patientId: patientId,
        amount: amount,
        paymentMethodId: paymentMethodId,
        requestId: 'topup_${DateTime.now().microsecondsSinceEpoch}',
      );

      await _reloadSnapshot(patientId);

      _status = WalletStatus.loaded;
      _successMessage = 'Rs. $amount added to your wallet.';
      return true;
    } on WalletException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (error, stackTrace) {
      AppLogger.error('WalletController.addMoney', error, stackTrace);
      _errorMessage = 'Wallet top-up failed. Please try again.';
      return false;
    } finally {
      _isAddingMoney = false;
      notifyListeners();
    }
  }

  Future<bool> addPaymentMethod({
    required String patientId,
    required WalletPaymentMethodType type,
    required String displayName,
    required String maskedValue,
    bool setAsDefault = false,
  }) async {
    if (_isUpdatingPaymentMethods) return false;

    _isUpdatingPaymentMethods = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _addPaymentMethod(
        patientId: patientId,
        type: type,
        displayName: displayName,
        maskedValue: maskedValue,
        setAsDefault: setAsDefault,
      );

      await _reloadSnapshot(patientId);

      _status = WalletStatus.loaded;
      _successMessage = 'Payment method added.';
      return true;
    } on WalletException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (error, stackTrace) {
      AppLogger.error('WalletController.addPaymentMethod', error, stackTrace);
      _errorMessage = 'Could not add the payment method.';
      return false;
    } finally {
      _isUpdatingPaymentMethods = false;
      notifyListeners();
    }
  }

  Future<bool> setDefaultPaymentMethod({
    required String patientId,
    required String paymentMethodId,
  }) async {
    if (_isUpdatingPaymentMethods) return false;

    _isUpdatingPaymentMethods = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _setDefaultPaymentMethod(
        patientId: patientId,
        paymentMethodId: paymentMethodId,
      );

      await _reloadSnapshot(patientId);

      _status = WalletStatus.loaded;
      _successMessage = 'Default payment method updated.';
      return true;
    } on WalletException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (error, stackTrace) {
      AppLogger.error(
        'WalletController.setDefaultPaymentMethod',
        error,
        stackTrace,
      );
      _errorMessage = 'Could not update the default payment method.';
      return false;
    } finally {
      _isUpdatingPaymentMethods = false;
      notifyListeners();
    }
  }

  Future<bool> removePaymentMethod({
    required String patientId,
    required String paymentMethodId,
  }) async {
    if (_isUpdatingPaymentMethods) return false;

    _isUpdatingPaymentMethods = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _removePaymentMethod(
        patientId: patientId,
        paymentMethodId: paymentMethodId,
      );

      await _reloadSnapshot(patientId);

      _status = WalletStatus.loaded;
      _successMessage = 'Payment method removed.';
      return true;
    } on WalletException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (error, stackTrace) {
      AppLogger.error(
        'WalletController.removePaymentMethod',
        error,
        stackTrace,
      );
      _errorMessage = 'Could not remove the payment method.';
      return false;
    } finally {
      _isUpdatingPaymentMethods = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    if (_errorMessage == null && _successMessage == null) {
      return;
    }

    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> _reloadSnapshot(String patientId) async {
    _snapshot = await _getWalletSnapshot(patientId: patientId);
  }
}
