import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asaancare/core/theme/app_theme.dart';
import 'package:asaancare/features/pharmacy/data/datasources/pharmacy_mock_data_source.dart';
import 'package:asaancare/features/pharmacy/data/repositories/pharmacy_repository_impl.dart';
import 'package:asaancare/features/pharmacy/domain/usecases/get_popular_medicines.dart';
import 'package:asaancare/features/pharmacy/domain/usecases/get_recent_prescription.dart';
import 'package:asaancare/features/pharmacy/presentation/controllers/pharmacy_controller.dart';
import 'package:asaancare/features/pharmacy/presentation/screens/cart_screen.dart';
import 'package:asaancare/features/pharmacy/presentation/screens/checkout_screen.dart';
import 'package:asaancare/features/pharmacy/presentation/screens/medicine_detail_screen.dart';
import 'package:asaancare/features/pharmacy/presentation/screens/medicine_search_screen.dart';
import 'package:asaancare/features/pharmacy/presentation/screens/pharmacy_screen.dart';

PharmacyController _createController() {
  final dataSource = PharmacyMockDataSource(delay: Duration.zero);
  final repository = PharmacyRepositoryImpl(mockDataSource: dataSource);

  return PharmacyController(
    GetPopularMedicines(repository),
    GetRecentPrescription(repository),
  );
}

Future<void> _pumpAtSize(
  WidgetTester tester, {
  required Size size,
  required Widget home,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;

  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      home: home,
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));

  final exception = tester.takeException();

  expect(
    exception,
    isNull,
    reason: 'Overflow while rendering ${home.runtimeType} at ${size.width}px',
  );
}

void main() {
  testWidgets('pharmacy landing screen has no overflow at mobile widths', (
    tester,
  ) async {
    final controller = _createController();
    await tester.runAsync(controller.load);

    addTearDown(controller.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in <double>[320, 360, 393, 430]) {
      await _pumpAtSize(
        tester,
        size: Size(width, 800),
        home: PharmacyScreen(controller: controller),
      );
    }
  });

  testWidgets('search and medicine details render at 320px', (tester) async {
    final controller = _createController();
    await tester.runAsync(controller.load);
    final medicine = controller.medicines.firstWhere((item) => item.isInStock);

    addTearDown(controller.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpAtSize(
      tester,
      size: const Size(320, 800),
      home: MedicineSearchScreen(controller: controller),
    );

    expect(find.text('100 results found'), findsOneWidget);

    for (final width in <double>[320, 360, 393, 430]) {
      await _pumpAtSize(
        tester,
        size: Size(width, 800),
        home: MedicineDetailScreen(controller: controller, medicine: medicine),
      );
    }
  });

  testWidgets('cart and checkout render at 320px', (tester) async {
    final controller = _createController();
    await tester.runAsync(controller.load);
    final medicine = controller.medicines.firstWhere(
      (item) => item.isInStock && !item.prescriptionRequired,
    );

    controller.addToCart(medicine);

    addTearDown(controller.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in <double>[320, 360, 393, 430]) {
      await _pumpAtSize(
        tester,
        size: Size(width, 800),
        home: CartScreen(controller: controller),
      );

      await _pumpAtSize(
        tester,
        size: Size(width, 800),
        home: CheckoutScreen(controller: controller),
      );
    }
  });
}
