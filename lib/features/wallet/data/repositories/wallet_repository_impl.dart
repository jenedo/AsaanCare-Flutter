// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals

import '../../../../core/config/app_config.dart';
import '../../domain/entities/wallet_account.dart';
import '../../domain/entities/wallet_payment_method.dart';
import '../../domain/entities/wallet_snapshot.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/payment_remote_data_source.dart';
import '../datasources/wallet_mock_data_source.dart';
import '../datasources/wallet_remote_data_source.dart';
import '../models/wallet_transaction_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  const WalletRepositoryImpl({
    required WalletMockDataSource mockDataSource,
    WalletRemoteDataSource? remoteDataSource,
    PaymentRemoteDataSource? paymentRemoteDataSource,
  }) : _mockDataSource = mockDataSource,
       _remoteDataSource = remoteDataSource,
       _paymentRemoteDataSource = paymentRemoteDataSource;

  final WalletMockDataSource _mockDataSource;
  final WalletRemoteDataSource? _remoteDataSource;
  final PaymentRemoteDataSource? _paymentRemoteDataSource;

  PaymentRemoteDataSource? get paymentRemoteDataSource =>
      _paymentRemoteDataSource;

  @override
  Future<WalletSnapshot> getWalletSnapshot({required String patientId}) async {
    if (!AppConfig.useMockApi && _remoteDataSource != null) {
      try {
        final model = await _remoteDataSource.getWallet();
        final txRes = await _remoteDataSource.getTransactions(
          page: 1,
          limit: 20,
        );
        final rawTxList = txRes['data'] as List? ?? [];
        final txs = rawTxList.map((e) {
          final m = WalletTransactionModel.fromJson(e as Map<String, dynamic>);
          return WalletTransaction(
            id: m.id,
            patientId: model.userId.isNotEmpty ? model.userId : patientId,
            type: m.type == 'CREDIT'
                ? WalletTransactionType.topUp
                : WalletTransactionType.payment,
            status: WalletTransactionStatus.completed,
            title: m.description,
            description: m.description,
            amount: (m.amountMinor / 100).round(),
            referenceId: m.referenceId ?? '',
            createdAt: m.createdAt,
          );
        }).toList();

        return WalletSnapshot(
          account: WalletAccount(
            id: model.id,
            patientId: model.userId.isNotEmpty ? model.userId : patientId,
            balance: (model.balanceMinor / 100).round(),
            currencyCode: model.currency,
            updatedAt: DateTime.now(),
          ),
          transactions: txs,
          paymentMethods: const [],
        );
      } catch (_) {
        return _mockDataSource.getWalletSnapshot(patientId: patientId);
      }
    }
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
