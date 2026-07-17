import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/doctor_test_harness.dart';

Future<DoctorTestHarness> _openWallet(WidgetTester tester, Size size) async {
  final harness = await pumpDoctorDashboard(tester, size: size);
  await tester.tap(find.text('Earnings').last);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.text('Open wallet'));
  await tester.pump(const Duration(milliseconds: 300));
  return harness;
}

void main() {
  testWidgets('doctor wallet renders core financial details without overflow', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final size in <Size>[
      const Size(320, 760),
      const Size(393, 852),
      const Size(768, 1024),
    ]) {
      final harness = await _openWallet(tester, size);

      expect(find.text('Available balance'), findsWidgets);
      expect(find.text('PKR 19,150'), findsWidgets);
      expect(find.text('Withdraw'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
      expect(find.text('Balance details'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('Recent wallet activity'),
        500,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Recent wallet activity'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('Next payout:'),
        400,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('Next payout:'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      harness.dispose();
    }
  });

  testWidgets('withdraw and transfer actions remain safe without payout API', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final harness = await _openWallet(tester, const Size(393, 852));
    addTearDown(harness.dispose);

    await tester.tap(find.text('Withdraw'));
    await tester.pumpAndSettle();
    expect(find.text('Withdraw funds'), findsOneWidget);
    expect(find.text('Backend verification required'), findsOneWidget);
    await tester.tap(find.byTooltip('Close withdraw'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();
    expect(find.text('Transfer funds'), findsOneWidget);
    expect(
      find.text('Transfers are not enabled in demo mode.'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Close transfer'));
    await tester.pumpAndSettle();
  });

  testWidgets('wallet filters and payment method management work', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final harness = await _openWallet(tester, const Size(393, 852));
    addTearDown(harness.dispose);

    await tester.tap(find.byTooltip('Filter wallet activity'));
    await tester.pumpAndSettle();
    expect(find.text('Filter wallet activity'), findsOneWidget);
    await tester.tap(find.text('Credits only'));
    await tester.pumpAndSettle();
    expect(find.text('Credits only'), findsOneWidget);

    await tester.tap(find.text('Payment methods').first);
    await tester.pumpAndSettle();
    expect(find.text('Manage payment methods'), findsOneWidget);
    expect(find.textContaining('HBL Bank'), findsWidgets);
    expect(find.text('Add payment method'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
