import 'package:flutter_test/flutter_test.dart';

import 'package:asaancare/features/pharmacy/data/datasources/pharmacy_mock_data_source.dart';
import 'package:asaancare/features/pharmacy/data/repositories/pharmacy_repository_impl.dart';
import 'package:asaancare/features/pharmacy/domain/entities/pharmacy_order.dart';
import 'package:asaancare/features/pharmacy/domain/usecases/get_popular_medicines.dart';
import 'package:asaancare/features/pharmacy/domain/usecases/get_recent_prescription.dart';
import 'package:asaancare/features/pharmacy/presentation/controllers/pharmacy_controller.dart';

PharmacyController _createController() {
  final dataSource = PharmacyMockDataSource(delay: Duration.zero);
  final repository = PharmacyRepositoryImpl(mockDataSource: dataSource);

  return PharmacyController(
    GetPopularMedicines(repository),
    GetRecentPrescription(repository),
  );
}

void main() {
  test(
    'logout session reset clears all user-specific pharmacy state',
    () async {
      final controller = _createController();
      addTearDown(controller.dispose);

      await controller.load();

      final medicine = controller.medicines.firstWhere(
        (item) => item.isInStock,
      );

      controller.addToCart(medicine);
      controller.toggleFavorite(medicine.id);
      controller.selectPaymentMethod(PharmacyPaymentMethod.easypaisa);
      controller.selectCity('Karachi');
      controller.updateDeliveryAddress('House 1, Karachi, Sindh, Pakistan');

      controller.clearCart(resetSession: true);

      expect(controller.isCartEmpty, isTrue);
      expect(controller.isFavorite(medicine.id), isFalse);
      expect(
        controller.selectedPaymentMethod,
        PharmacyPaymentMethod.cashOnDelivery,
      );
      expect(controller.selectedCity, 'Lahore');
      expect(controller.activeOrder, isNull);
      expect(controller.recentPrescription, isNull);
      expect(controller.status, PharmacyStatus.initial);
      expect(controller.errorMessage, isNull);
    },
  );

  test('COD and online-paid orders use different valid stage paths', () async {
    final controller = _createController();
    addTearDown(controller.dispose);

    await controller.load();

    final medicine = controller.medicines.firstWhere(
      (item) => item.isInStock && !item.prescriptionRequired,
    );

    controller.addToCart(medicine);
    controller.selectPaymentMethod(PharmacyPaymentMethod.cashOnDelivery);

    final codOrder = await controller.placeDemoOrder(patientId: 'patient-cod');

    expect(codOrder, isNotNull);
    expect(
      codOrder!.stagePath,
      isNot(contains(PharmacyOrderStage.paymentSuccessful)),
    );

    controller.addToCart(medicine);
    controller.selectPaymentMethod(PharmacyPaymentMethod.easypaisa);

    final paidOrder = await controller.placeDemoOrder(
      patientId: 'patient-paid',
    );

    expect(paidOrder, isNotNull);
    expect(paidOrder!.stagePath.first, PharmacyOrderStage.paymentSuccessful);
    expect(paidOrder.stagePath, isNot(contains(PharmacyOrderStage.confirmed)));
  });
}
