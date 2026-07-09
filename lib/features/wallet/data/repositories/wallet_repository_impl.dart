// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals

import '../../domain/entities/wallet_payment_method.dart';
import '../../domain/entities/wallet_snapshot.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_mock_data_source.dart';

class WalletRepositoryImpl implements WalletRepository {
  const WalletRepositoryImpl({required WalletMockDataSource mockDataSource})
    : _mockDataSource = mockDataSource;

  final WalletMockDataSource _mockDataSource;

  @override
  Future<WalletSnapshot> getWalletSnapshot({required String patientId}) {
    return _mockDataSource.getWalletSnapshot(patientId: patientId);
  }

  @override
  Future<WalletTransaction> addMoney({
    required String patientId,
    required int amount,
    required String paymentMethodId,
    required String requestId,
  }) {
    return _mockDataSource.addMoney(
      patientId: patientId,
      amount: amount,
      paymentMethodId: paymentMethodId,
      requestId: requestId,
    );
  }

  @override
  Future<WalletTransaction> chargeWallet({
    required String patientId,
    required int amount,
    required String title,
    required String description,
    required String referenceId,
  }) {
    return _mockDataSource.chargeWallet(
      patientId: patientId,
      amount: amount,
      title: title,
      description: description,
      referenceId: referenceId,
    );
  }

  @override
  Future<WalletTransaction> refundWallet({
    required String patientId,
    required int amount,
    required String title,
    required String description,
    required String referenceId,
  }) {
    return _mockDataSource.refundWallet(
      patientId: patientId,
      amount: amount,
      title: title,
      description: description,
      referenceId: referenceId,
    );
  }

  @override
  Future<WalletPaymentMethod> addPaymentMethod({
    required String patientId,
    required WalletPaymentMethodType type,
    required String displayName,
    required String maskedValue,
    required bool setAsDefault,
  }) {
    return _mockDataSource.addPaymentMethod(
      patientId: patientId,
      type: type,
      displayName: displayName,
      maskedValue: maskedValue,
      setAsDefault: setAsDefault,
    );
  }

  @override
  Future<void> setDefaultPaymentMethod({
    required String patientId,
    required String paymentMethodId,
  }) {
    return _mockDataSource.setDefaultPaymentMethod(
      patientId: patientId,
      paymentMethodId: paymentMethodId,
    );
  }

  @override
  Future<void> removePaymentMethod({
    required String patientId,
    required String paymentMethodId,
  }) {
    return _mockDataSource.removePaymentMethod(
      patientId: patientId,
      paymentMethodId: paymentMethodId,
    );
  }
}
