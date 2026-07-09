import 'package:asaancare/features/wallet/data/datasources/wallet_mock_data_source.dart';
import 'package:asaancare/features/wallet/domain/entities/wallet_payment_method.dart';
import 'package:asaancare/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:asaancare/features/wallet/domain/exceptions/wallet_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const patientId = 'wallet_test_patient_001';

  late WalletMockDataSource dataSource;

  setUp(() {
    dataSource = WalletMockDataSource();
  });

  group('WalletMockDataSource', () {
    test('creates a wallet with safe demo data', () async {
      final snapshot = await dataSource.getWalletSnapshot(patientId: patientId);

      expect(snapshot.account.patientId, patientId);
      expect(snapshot.account.balance, 2450);
      expect(snapshot.account.currencyCode, 'PKR');
      expect(snapshot.transactions, hasLength(4));
      expect(snapshot.paymentMethods, hasLength(4));

      expect(
        snapshot.paymentMethods.where((method) => method.isDefault),
        hasLength(1),
      );

      expect(
        snapshot.paymentMethods.every(
          (method) => method.maskedValue.contains('*'),
        ),
        isTrue,
      );
    });

    test('adds money and records one credit transaction', () async {
      final before = await dataSource.getWalletSnapshot(patientId: patientId);

      final paymentMethod = before.paymentMethods.first;

      final transaction = await dataSource.addMoney(
        patientId: patientId,
        amount: 500,
        paymentMethodId: paymentMethod.id,
        requestId: 'TOPUP-TEST-001',
      );

      final after = await dataSource.getWalletSnapshot(patientId: patientId);

      expect(transaction.type, WalletTransactionType.topUp);
      expect(transaction.status, WalletTransactionStatus.completed);
      expect(transaction.amount, 500);
      expect(transaction.isCredit, isTrue);

      expect(after.account.balance, before.account.balance + 500);

      expect(after.transactions.length, before.transactions.length + 1);

      expect(after.transactions.first.id, transaction.id);
    });

    test('does not process the same top-up request twice', () async {
      final before = await dataSource.getWalletSnapshot(patientId: patientId);

      final paymentMethod = before.paymentMethods.first;

      final first = await dataSource.addMoney(
        patientId: patientId,
        amount: 1000,
        paymentMethodId: paymentMethod.id,
        requestId: 'TOPUP-IDEMPOTENT-001',
      );

      final second = await dataSource.addMoney(
        patientId: patientId,
        amount: 1000,
        paymentMethodId: paymentMethod.id,
        requestId: 'TOPUP-IDEMPOTENT-001',
      );

      final after = await dataSource.getWalletSnapshot(patientId: patientId);

      expect(second.id, first.id);

      expect(after.account.balance, before.account.balance + 1000);

      expect(after.transactions.length, before.transactions.length + 1);
    });

    test('charges wallet once for a duplicate payment reference', () async {
      final before = await dataSource.getWalletSnapshot(patientId: patientId);

      final first = await dataSource.chargeWallet(
        patientId: patientId,
        amount: 600,
        title: 'Medicine order',
        description: 'Wallet payment test',
        referenceId: 'ORDER-TEST-001',
      );

      final second = await dataSource.chargeWallet(
        patientId: patientId,
        amount: 600,
        title: 'Medicine order',
        description: 'Wallet payment test',
        referenceId: 'ORDER-TEST-001',
      );

      final after = await dataSource.getWalletSnapshot(patientId: patientId);

      expect(first.type, WalletTransactionType.payment);
      expect(first.isCredit, isFalse);
      expect(second.id, first.id);

      expect(after.account.balance, before.account.balance - 600);

      expect(after.transactions.length, before.transactions.length + 1);
    });

    test('rejects a charge above the available balance', () async {
      final before = await dataSource.getWalletSnapshot(patientId: patientId);

      await expectLater(
        dataSource.chargeWallet(
          patientId: patientId,
          amount: before.account.balance + 1,
          title: 'Large payment',
          description: 'Insufficient balance test',
          referenceId: 'ORDER-TOO-LARGE-001',
        ),
        throwsA(
          isA<WalletException>().having(
            (error) => error.message,
            'message',
            contains('Insufficient wallet balance'),
          ),
        ),
      );

      final after = await dataSource.getWalletSnapshot(patientId: patientId);

      expect(after.account.balance, before.account.balance);
      expect(after.transactions.length, before.transactions.length);
    });

    test('processes the same refund reference only once', () async {
      final before = await dataSource.getWalletSnapshot(patientId: patientId);

      final first = await dataSource.refundWallet(
        patientId: patientId,
        amount: 300,
        title: 'Appointment refund',
        description: 'Cancelled appointment',
        referenceId: 'REFUND-TEST-001',
      );

      final second = await dataSource.refundWallet(
        patientId: patientId,
        amount: 300,
        title: 'Appointment refund',
        description: 'Cancelled appointment',
        referenceId: 'REFUND-TEST-001',
      );

      final after = await dataSource.getWalletSnapshot(patientId: patientId);

      expect(first.type, WalletTransactionType.refund);
      expect(first.isCredit, isTrue);
      expect(second.id, first.id);

      expect(after.account.balance, before.account.balance + 300);

      expect(after.transactions.length, before.transactions.length + 1);
    });

    test('rejects unmasked payment information', () async {
      await expectLater(
        dataSource.addPaymentMethod(
          patientId: patientId,
          type: WalletPaymentMethodType.easypaisa,
          displayName: 'Unsafe Easypaisa',
          maskedValue: '03001234567',
          setAsDefault: false,
        ),
        throwsA(
          isA<WalletException>().having(
            (error) => error.message,
            'message',
            contains('Only masked'),
          ),
        ),
      );
    });

    test('sets and replaces the default payment method safely', () async {
      final added = await dataSource.addPaymentMethod(
        patientId: patientId,
        type: WalletPaymentMethodType.card,
        displayName: 'Secondary card',
        maskedValue: '**** 7788',
        setAsDefault: true,
      );

      var snapshot = await dataSource.getWalletSnapshot(patientId: patientId);

      expect(
        snapshot.paymentMethods
            .singleWhere((method) => method.id == added.id)
            .isDefault,
        isTrue,
      );

      expect(
        snapshot.paymentMethods.where((method) => method.isDefault),
        hasLength(1),
      );

      await dataSource.removePaymentMethod(
        patientId: patientId,
        paymentMethodId: added.id,
      );

      snapshot = await dataSource.getWalletSnapshot(patientId: patientId);

      expect(
        snapshot.paymentMethods.any((method) => method.id == added.id),
        isFalse,
      );

      expect(
        snapshot.paymentMethods.where((method) => method.isDefault),
        hasLength(1),
      );
    });
  });
}
