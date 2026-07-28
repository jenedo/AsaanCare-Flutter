import 'package:asaancare/doctor/features/dashboard/domain/entities/doctor_dashboard_snapshot.dart';
import 'package:asaancare/doctor/screens/dashboard/widgets/doctor_home_content.dart';
import 'package:asaancare/doctor/screens/earnings/doctor_earnings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/doctor_test_harness.dart';

void main() {
  test('greeting boundaries follow local time', () {
    expect(doctorGreetingForHour(4), 'Good Night');
    expect(doctorGreetingForHour(5), 'Good Morning');
    expect(doctorGreetingForHour(12), 'Good Afternoon');
    expect(doctorGreetingForHour(17), 'Good Evening');
    expect(doctorGreetingForHour(21), 'Good Night');
  });

  testWidgets('dashboard renders across compact, tablet, and web widths', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final size in <Size>[
      const Size(320, 760),
      const Size(360, 800),
      const Size(393, 852),
      const Size(430, 932),
      const Size(768, 1024),
      const Size(1200, 900),
    ]) {
      final harness = await pumpDoctorDashboard(tester, size: size);
      expect(find.text('Dr. Sara Khan'), findsOneWidget);
      expect(find.text("Today's Overview"), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Failed at $size');
      await tester.pumpWidget(const SizedBox.shrink());
      harness.dispose();
    }
  });

  testWidgets(
    'header uses the real doctor photo and availability is interactive',
    (tester) async {
      final harness = await pumpDoctorDashboard(tester);
      addTearDown(harness.dispose);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final avatar = tester.widget<CircleAvatar>(
        find.byKey(const ValueKey('doctor-profile-image')),
      );
      expect(
        (avatar.backgroundImage! as AssetImage).assetName,
        'assets/images/doctor_sara.png',
      );
      expect(find.text('SK'), findsNothing);

      Switch availabilitySwitch() => tester.widget<Switch>(
        find.byKey(const ValueKey('doctor-availability-switch')),
      );

      expect(availabilitySwitch().value, isTrue);
      await tester.tap(
        find.byKey(const ValueKey('doctor-availability-switch')),
      );
      await tester.pumpAndSettle();
      expect(availabilitySwitch().value, isFalse);
      expect(find.text('Not Available for Consultation'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('next-consultation-card')),
        500,
        scrollable: find.byType(Scrollable).last,
      );
      expect(
        find.byKey(const ValueKey('next-consultation-card')),
        findsOneWidget,
      );
      expect(find.text('NEXT CONSULTATION'), findsOneWidget);
    },
  );

  testWidgets('all Earnings entries select the canonical index-3 screen', (
    tester,
  ) async {
    final harness = await pumpDoctorDashboard(tester);
    addTearDown(harness.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> verifyEarnings() async {
      await tester.pumpAndSettle();
      expect(find.byType(DoctorEarningsScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('doctor-earnings')), findsOneWidget);
      expect(find.text('Total earnings'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    }

    await tester.tap(find.byKey(const ValueKey('overview-earnings')));
    await verifyEarnings();

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    final quickEarnings = find.byKey(const ValueKey('quick-earnings'));
    await tester.ensureVisible(quickEarnings);
    await tester.tap(quickEarnings);
    await verifyEarnings();

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Earnings').last);
    await verifyEarnings();
  });

  testWidgets('overview metrics select the expected schedule filter', (
    tester,
  ) async {
    final harness = await pumpDoctorDashboard(tester);
    addTearDown(harness.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.tap(find.byKey(const ValueKey('overview-pending')));
    await tester.pumpAndSettle();
    expect(
      harness.dashboard.appointmentFilter,
      DoctorAppointmentFilter.pending,
    );

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('overview-completed')));
    await tester.pumpAndSettle();
    expect(
      harness.dashboard.appointmentFilter,
      DoctorAppointmentFilter.completed,
    );

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('overview-appointments')));
    await tester.pumpAndSettle();
    expect(harness.dashboard.appointmentFilter, DoctorAppointmentFilter.all);
  });

  testWidgets('notifications, dark mode, and profile stay in the shell', (
    tester,
  ) async {
    final harness = await pumpDoctorDashboard(tester);
    addTearDown(harness.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.tap(find.byTooltip('Open notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Notifications'), findsOneWidget);
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Use dark theme'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets(
    'request actions show progress and reject requires confirmation',
    (tester) async {
      final harness = await pumpDoctorDashboard(
        tester,
        actionDelay: const Duration(milliseconds: 300),
      );
      addTearDown(harness.dispose);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final initialCount = harness.dashboard.pendingRequests.length;
      final firstRequestId = harness.dashboard.pendingRequests.first.id;

      await tester.drag(
        find.byKey(const PageStorageKey('doctor-home-scroll')),
        const Offset(0, -520),
      );
      await tester.pump(const Duration(milliseconds: 300));
      final firstRequest = find.byKey(
        ValueKey('pending-request-$firstRequestId'),
      );
      final accept = find.descendant(
        of: firstRequest,
        matching: find.byType(FilledButton),
      );
      await tester.tap(accept);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(accept, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(harness.dashboard.pendingRequests.length, initialCount - 1);

      final secondRequestId = harness.dashboard.pendingRequests.first.id;
      final secondRequest = find.byKey(
        ValueKey('pending-request-$secondRequestId'),
      );
      await tester.tap(
        find.descendant(
          of: secondRequest,
          matching: find.byType(OutlinedButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Reject request?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Reject'));
      await tester.pumpAndSettle();
      expect(harness.dashboard.pendingRequests.length, initialCount - 2);
    },
  );
}
