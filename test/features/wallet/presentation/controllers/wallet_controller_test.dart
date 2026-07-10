import 'dart:async';

import 'package:asaancare/features/wallet/domain/entities/wallet_account.dart';
import 'package:asaancare/features/wallet/domain/entities/wallet_payment_method.dart';
import 'package:asaancare/features/wallet/domain/entities/wallet_snapshot.dart';
import 'package:asaancare/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:asaancare/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:asaancare/features/wallet/domain/usecases/add_wallet_money.dart';
import 'package:asaancare/features/wallet/domain/usecases/get_wallet_snapshot.dart';
import 'package:asaancare/features/wallet/domain/usecases/wallet_payment_method_actions.dart';
import 'package:asaancare/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps a committed top-up when the post-commit reload fails', () async {
    final repository = _ReloadFailureWalletRepository();
    final controller = _controller(repository);
    addTearDown(controller.dispose);

    await controller.load(patientId: _patientId);

    final success = await controller.addMoney(
      patientId: _patientId,
      amount: 500,
      paymentMethodId: _paymentMethod.id,
    );

    expect(success, isTrue);
    expect(controller.balance, 1500);
    expect(controller.transactions.first.id, 'committed-topup');
    expect(controller.successMessage, contains('500'));
  });

  test('load completion is safe after the controller is disposed', () async {
    final repository = _DeferredWalletRepository();
    final controller = _controller(repository);

    final loadFuture = controller.load(patientId: _patientId);
    controller.dispose();

    repository.snapshotCompleter.complete(_snapshot());

    await expectLater(loadFuture, completes);
    expect(controller.status, WalletStatus.loaded);
  });
}

const _patientId = 'patient-test';

const _paymentMethod = WalletPaymentMethod(
  id: 'method-card',
  patientId: _patientId,
  type: WalletPaymentMethodType.card,
  displayName: 'Card',
  maskedValue: '**** 4242',
  isDefault: true,
);

WalletSnapshot _snapshot({
  int balance = 1000,
  List<WalletTransaction> transactions = const [],
}) {
  return WalletSnapshot(
    account: WalletAccount(
      id: 'wallet-test',
      patientId: _patientId,
      balance: balance,
      currencyCode: 'PKR',
      updatedAt: DateTime(2026, 7, 10),
    ),
    transactions: transactions,
    paymentMethods: const [_paymentMethod],
  );
}

WalletController _controller(WalletRepository repository) {
  return WalletController(
    getWalletSnapshot: GetWalletSnapshot(repository),
    addWalletMoney: AddWalletMoney(repository),
    addPaymentMethod: AddWalletPaymentMethod(repository),
    setDefaultPaymentMethod: SetDefaultWalletPaymentMethod(repository),
    removePaymentMethod: RemoveWalletPaymentMethod(repository),
  );
}

class _ReloadFailureWalletRepository implements WalletRepository {
  var snapshotCalls = 0;

  @override
  Future<WalletSnapshot> getWalletSnapshot({required String patientId}) async {
    snapshotCalls++;

    if (snapshotCalls == 1) {
      return _snapshot();
    }

    throw StateError('Reload failed after the committed top-up.');
  }

  @override
  Future<WalletTransaction> addMoney({
    required String patientId,
    required int amount,
    required String paymentMethodId,
    required String requestId,
  }) async {
    return WalletTransaction(
      id: 'committed-topup',
      patientId: patientId,
      type: WalletTransactionType.topUp,
      status: WalletTransactionStatus.completed,
      title: 'Wallet top-up',
      description: 'Committed top-up',
      amount: amount,
      referenceId: requestId,
      createdAt: DateTime(2026, 7, 10, 12),
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
    throw UnimplementedError();
  }

  @override
  Future<WalletTransaction> chargeWallet({
    required String patientId,
    required int amount,
    required String title,
    required String description,
    required String referenceId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<WalletTransaction> refundWallet({
    required String patientId,
    required int amount,
    required String title,
    required String description,
    required String referenceId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> removePaymentMethod({
    required String patientId,
    required String paymentMethodId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> setDefaultPaymentMethod({
    required String patientId,
    required String paymentMethodId,
  }) {
    throw UnimplementedError();
  }
}

class _DeferredWalletRepository implements WalletRepository {
  final Completer<WalletSnapshot> snapshotCompleter =
      Completer<WalletSnapshot>();

  @override
  Future<WalletSnapshot> getWalletSnapshot({required String patientId}) {
    return snapshotCompleter.future;
  }

  @override
  Future<WalletTransaction> addMoney({
    required String patientId,
    required int amount,
    required String paymentMethodId,
    required String requestId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<WalletPaymentMethod> addPaymentMethod({
    required String patientId,
    required WalletPaymentMethodType type,
    required String displayName,
    required String maskedValue,
    required bool setAsDefault,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<WalletTransaction> chargeWallet({
    required String patientId,
    required int amount,
    required String title,
    required String description,
    required String referenceId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<WalletTransaction> refundWallet({
    required String patientId,
    required int amount,
    required String title,
    required String description,
    required String referenceId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> removePaymentMethod({
    required String patientId,
    required String paymentMethodId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> setDefaultPaymentMethod({
    required String patientId,
    required String paymentMethodId,
  }) {
    throw UnimplementedError();
  }
}
