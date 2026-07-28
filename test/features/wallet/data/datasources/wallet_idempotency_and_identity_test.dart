import 'package:asaancare/features/wallet/data/datasources/wallet_mock_data_source.dart';
import 'package:asaancare/features/wallet/domain/entities/wallet_payment_method.dart';
import 'package:asaancare/features/wallet/domain/exceptions/wallet_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WalletMockDataSource idempotency payload validation', () {
    test('replays an identical top-up but rejects a changed payload', () async {
      final dataSource = WalletMockDataSource();
      const patientId = 'wallet-idempotency-topup';
      final snapshot = await dataSource.getWalletSnapshot(patientId: patientId);
      final paymentMethod = snapshot.paymentMethods.first;

      final first = await dataSource.addMoney(
        patientId: patientId,
        amount: 500,
        paymentMethodId: paymentMethod.id,
        requestId: 'topup-key-001',
      );
      final replay = await dataSource.addMoney(
        patientId: patientId,
        amount: 500,
        paymentMethodId: paymentMethod.id,
        requestId: 'topup-key-001',
      );

      expect(replay.id, first.id);

      await expectLater(
        dataSource.addMoney(
          patientId: patientId,
          amount: 900,
          paymentMethodId: paymentMethod.id,
          requestId: 'topup-key-001',
        ),
        throwsA(_idempotencyMismatch()),
      );
    });

    test(
      'rejects changed charge and refund payloads for reused keys',
      () async {
        final dataSource = WalletMockDataSource();
        const patientId = 'wallet-idempotency-ledger';

        await dataSource.getWalletSnapshot(patientId: patientId);

        await dataSource.chargeWallet(
          patientId: patientId,
          amount: 300,
          title: 'Medicine order',
          description: 'Order A',
          referenceId: 'charge-key-001',
        );

        await expectLater(
          dataSource.chargeWallet(
            patientId: patientId,
            amount: 300,
            title: 'Medicine order',
            description: 'Order B',
            referenceId: 'charge-key-001',
          ),
          throwsA(_idempotencyMismatch()),
        );

        await dataSource.refundWallet(
          patientId: patientId,
          amount: 200,
          title: 'Appointment refund',
          description: 'Refund A',
          referenceId: 'refund-key-001',
        );

        await expectLater(
          dataSource.refundWallet(
            patientId: patientId,
            amount: 250,
            title: 'Appointment refund',
            description: 'Refund A',
            referenceId: 'refund-key-001',
          ),
          throwsA(_idempotencyMismatch()),
        );
      },
    );
  });

  test(
    'generated wallet transaction and payment method ids are unique',
    () async {
      final dataSource = WalletMockDataSource();
      const patientId = 'wallet-identity';
      final snapshot = await dataSource.getWalletSnapshot(patientId: patientId);
      final paymentMethod = snapshot.paymentMethods.first;

      final firstTransaction = await dataSource.addMoney(
        patientId: patientId,
        amount: 500,
        paymentMethodId: paymentMethod.id,
        requestId: 'identity-topup-001',
      );
      final secondTransaction = await dataSource.addMoney(
        patientId: patientId,
        amount: 500,
        paymentMethodId: paymentMethod.id,
        requestId: 'identity-topup-002',
      );

      final firstMethod = await dataSource.addPaymentMethod(
        patientId: patientId,
        type: WalletPaymentMethodType.card,
        displayName: 'Card one',
        maskedValue: '**** 1111',
        setAsDefault: false,
      );
      final secondMethod = await dataSource.addPaymentMethod(
        patientId: patientId,
        type: WalletPaymentMethodType.card,
        displayName: 'Card two',
        maskedValue: '**** 2222',
        setAsDefault: false,
      );
      expect(firstTransaction.id, '${patientId}_wallet_tx_00000001');
      expect(secondTransaction.id, '${patientId}_wallet_tx_00000002');
      expect(firstMethod.id, '${patientId}_wallet_method_00000001');
      expect(secondMethod.id, '${patientId}_wallet_method_00000002');
    },
  );
}

Matcher _idempotencyMismatch() {
  return isA<WalletException>().having(
    (error) => error.message,
    'message',
    contains('different request details'),
  );
}
