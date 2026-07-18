import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/doctor_test_harness.dart';

Future<DoctorTestHarness> _openEarnings(WidgetTester tester, Size size) async {
  final harness = await pumpDoctorDashboard(tester, size: size);
  await tester.tap(find.text('Earnings').last);
  await tester.pump(const Duration(milliseconds: 300));
  return harness;
}

void main() {
  testWidgets('earnings overview is responsive and exposes core metrics', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final size in <Size>[
      const Size(320, 760),
      const Size(360, 760),
      const Size(393, 852),
      const Size(412, 915),
      const Size(430, 932),
      const Size(768, 1024),
    ]) {
      final harness = await _openEarnings(tester, size);

      expect(find.text('Total earnings'), findsOneWidget);
      expect(find.text('PKR 28,500'), findsWidgets);
      expect(find.text('Open wallet'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (size == const Size(768, 1024)) {
        expect(find.text('Earnings summary'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Recent transactions'),
          500,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Recent transactions'), findsOneWidget);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      harness.dispose();
    }
  });

  testWidgets('earnings tabs switch to a lazy transaction history', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final harness = await _openEarnings(tester, const Size(393, 852));
    addTearDown(harness.dispose);

    await tester.tap(find.text('Transactions').first);
    await tester.pumpAndSettle();

    expect(find.text('Transaction history'), findsOneWidget);
    expect(find.textContaining('Ahmed Hassan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'wallet navigation and period controls provide working feedback',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final harness = await _openEarnings(tester, const Size(393, 852));
      addTearDown(harness.dispose);

      await tester.tap(find.text('Open wallet'));
      await tester.pumpAndSettle();
      expect(find.text('Wallet'), findsOneWidget);
      expect(find.text('Available balance'), findsWidgets);
      expect(find.text('PKR 19,150'), findsWidgets);
      await tester.tap(find.byTooltip('Back to earnings'));
      await tester.pumpAndSettle();
      expect(find.text('Total earnings'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('earnings-period-control')));
      await tester.pumpAndSettle();
      expect(find.text('Choose earnings period'), findsOneWidget);
      await tester.tap(find.text('Last 3 months'));
      await tester.pumpAndSettle();
      expect(find.text('Last 3 months'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}
