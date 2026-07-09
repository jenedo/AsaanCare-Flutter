import 'package:flutter_test/flutter_test.dart';

import 'package:asaancare/features/pharmacy/data/datasources/pharmacy_mock_data_source.dart';
import 'package:asaancare/features/pharmacy/data/repositories/pharmacy_repository_impl.dart';
import 'package:asaancare/features/pharmacy/domain/entities/medicine.dart';
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
  late PharmacyController controller;

  setUp(() async {
    controller = _createController();
    await controller.load();
  });

  tearDown(() {
    controller.dispose();
  });

  test('catalog contains exactly 100 valid and unique medicine SKUs', () {
    expect(controller.medicines, hasLength(100));
    expect(
      controller.medicines.map((medicine) => medicine.id).toSet(),
      hasLength(100),
    );

    for (final medicine in controller.medicines) {
      expect(medicine.brandName.trim(), isNotEmpty);
      expect(medicine.genericName.trim(), isNotEmpty);
      expect(medicine.productCode.trim(), isNotEmpty);
      expect(medicine.price, greaterThan(0));
      expect(medicine.originalPrice, greaterThanOrEqualTo(medicine.price));
      expect(medicine.rating, inInclusiveRange(0, 5));
      expect(medicine.stockQuantity, greaterThanOrEqualTo(0));
    }
  });

  test('search supports brand, generic name and category filters', () {
    final brandResults = controller.searchMedicines(query: 'Panadol');
    final genericResults = controller.searchMedicines(query: 'Paracetamol');
    final diabetesResults = controller.searchMedicines(
      category: MedicineCategory.diabetesCare,
    );

    expect(brandResults, isNotEmpty);
    expect(
      brandResults.every(
        (medicine) => medicine.brandName.toLowerCase().contains('panadol'),
      ),
      isTrue,
    );
    expect(genericResults, isNotEmpty);
    expect(
      genericResults.every(
        (medicine) => medicine.searchableText.contains('paracetamol'),
      ),
      isTrue,
    );
    expect(diabetesResults, isNotEmpty);
    expect(
      diabetesResults.every(
        (medicine) => medicine.category == MedicineCategory.diabetesCare,
      ),
      isTrue,
    );
  });

  test('cart rejects out-of-stock products and caps quantity safely', () {
    final outOfStock = controller.medicines.firstWhere(
      (medicine) => !medicine.isInStock,
    );
    final inStock = controller.medicines.firstWhere(
      (medicine) => medicine.isInStock,
    );

    controller.addToCart(outOfStock);
    expect(controller.quantityFor(outOfStock.id), 0);

    controller.addToCart(inStock, quantity: 999);

    final expectedMaximum =
        inStock.stockQuantity < PharmacyController.maxQuantityPerMedicine
        ? inStock.stockQuantity
        : PharmacyController.maxQuantityPerMedicine;

    expect(controller.quantityFor(inStock.id), expectedMaximum);
  });

  test('subtotal, delivery, discount and payable total remain consistent', () {
    final medicine = controller.medicines.firstWhere(
      (item) => item.isInStock && !item.prescriptionRequired,
    );

    controller.addToCart(medicine, quantity: 2);

    final expectedSubtotal =
        medicine.price * controller.quantityFor(medicine.id);
    final expectedDelivery = expectedSubtotal >= 1000 || expectedSubtotal == 0
        ? 0
        : 150;
    final expectedDiscount = expectedSubtotal >= 500 ? 70 : 0;

    expect(controller.subtotal, expectedSubtotal);
    expect(controller.deliveryFee, expectedDelivery);
    expect(controller.discount, expectedDiscount);
    expect(
      controller.payableTotal,
      expectedSubtotal + expectedDelivery - expectedDiscount,
    );
  });

  test('wallet checkout is blocked when demo balance is insufficient', () {
    final expensiveMedicine = controller.medicines.firstWhere(
      (medicine) => medicine.isInStock && medicine.price > 850,
    );

    controller.addToCart(expensiveMedicine);
    controller.selectPaymentMethod(PharmacyPaymentMethod.asaancareWallet);

    expect(
      controller.checkoutValidationError,
      contains('wallet balance is insufficient'),
    );
    expect(controller.canCheckout, isFalse);
  });

  test('valid demo order is created and cart is cleared', () async {
    final medicine = controller.medicines.firstWhere(
      (item) => item.isInStock && !item.prescriptionRequired,
    );

    controller.addToCart(medicine);
    controller.selectPaymentMethod(PharmacyPaymentMethod.cashOnDelivery);

    final order = await controller.placeDemoOrder(
      patientId: 'mock_patient_001',
    );

    expect(order, isNotNull);
    expect(order!.items, isNotEmpty);
    expect(order.stage, PharmacyOrderStage.confirmed);
    expect(controller.isCartEmpty, isTrue);
    expect(controller.activeOrder?.id, order.id);
  });

  test(
    'demo order status advances without skipping the state machine',
    () async {
      final medicine = controller.medicines.firstWhere(
        (item) => item.isInStock && !item.prescriptionRequired,
      );

      controller.addToCart(medicine);

      final order = await controller.placeDemoOrder(
        patientId: 'mock_patient_001',
      );
      expect(order, isNotNull);

      final initialStage = controller.activeOrder!.stage;
      controller.advanceDemoOrder();

      expect(controller.activeOrder!.stage, isNot(initialStage));
    },
  );
}
