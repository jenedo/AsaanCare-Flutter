import 'package:asaancare/features/wallet/data/datasources/wallet_mock_data_source.dart';
import 'package:asaancare/features/wallet/domain/entities/wallet_payment_method.dart';
import 'package:asaancare/features/wallet/domain/exceptions/wallet_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WalletMockDataSource payment methods', () {
    test('rejects unmasked or unsupported payment values', () async {
      final dataSource = WalletMockDataSource();

      await expectLater(
        dataSource.addPaymentMethod(
          patientId: 'patient-test',
          type: WalletPaymentMethodType.card,
          displayName: 'Card',
          maskedValue: '4111111111111234',
          setAsDefault: false,
        ),
        throwsA(isA<WalletException>()),
      );

      await expectLater(
        dataSource.addPaymentMethod(
          patientId: 'patient-test',
          type: WalletPaymentMethodType.easypaisa,
          displayName: 'Easypaisa',
          maskedValue: '**** 1234',
          setAsDefault: false,
        ),
        throwsA(isA<WalletException>()),
      );
    });

    test('promotes an existing duplicate when requested as default', () async {
      final dataSource = WalletMockDataSource();
      const patientId = 'patient-default-test';

      final initial = await dataSource.getWalletSnapshot(patientId: patientId);
      final easypaisa = initial.paymentMethods.firstWhere(
        (method) => method.type == WalletPaymentMethodType.easypaisa,
      );

      final promoted = await dataSource.addPaymentMethod(
        patientId: patientId,
        type: easypaisa.type,
        displayName: easypaisa.displayName,
        maskedValue: easypaisa.maskedValue,
        setAsDefault: true,
      );

      final updated = await dataSource.getWalletSnapshot(patientId: patientId);

      expect(promoted.id, easypaisa.id);
      expect(promoted.isDefault, isTrue);
      expect(
        updated.paymentMethods.where((method) => method.isDefault),
        hasLength(1),
      );
      expect(
        updated.paymentMethods.singleWhere((method) => method.isDefault).id,
        easypaisa.id,
      );
    });
  });
}
