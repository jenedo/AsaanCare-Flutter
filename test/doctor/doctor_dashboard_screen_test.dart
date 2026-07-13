import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asaancare/doctor/doctor_app.dart';

Future<void> _pumpDoctorApp(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  await tester.pumpWidget(const DoctorApp());
  await tester.pump(const Duration(milliseconds: 500));
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('doctor dashboard renders without overflow on mobile widths', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in <double>[320, 360, 393, 430]) {
      await _pumpDoctorApp(tester, Size(width, 800));
    }
  });

  testWidgets('doctor dashboard request and navigation controls work', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pumpDoctorApp(tester, const Size(393, 800));

    expect(find.text('Ahmed Hassan'), findsWidgets);
    await tester.tap(find.widgetWithText(FilledButton, 'Accept').first);
    await tester.pumpAndSettle();
    expect(find.text('Pending Requests'), findsOneWidget);

    await tester.tap(find.text('Patients').last);
    await tester.pumpAndSettle();
    expect(find.text('Your recent patient records'), findsOneWidget);

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Use dark theme'));
    await tester.pumpAndSettle();
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
  });

  testWidgets('doctor opens a patient record from a home appointment card', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pumpDoctorApp(tester, const Size(393, 800));

    final patientCard = find.byKey(
      const ValueKey('home-patient-ahmed-appointment'),
    );
    await tester.scrollUntilVisible(patientCard, 220);
    await tester.tap(patientCard);
    await tester.pumpAndSettle();

    expect(find.text('Ahmed Hassan'), findsOneWidget);
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Start Consultation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('patients page uses searchable clinical patient cards', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pumpDoctorApp(tester, const Size(393, 800));

    await tester.tap(find.text('Patients').last);
    await tester.pumpAndSettle();

    expect(find.text('4 patient records'), findsOneWidget);
    expect(find.text('Next: Today, 10:30 AM'), findsOneWidget);
    expect(find.text('5 visits'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('patient-search-field')),
      'Fatima',
    );
    await tester.pump();

    expect(find.text('Fatima Ali'), findsOneWidget);
    expect(find.text('Ahmed Hassan'), findsNothing);
    expect(find.text('1 patient record'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home prescribe opens the full prescription workflow', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pumpDoctorApp(tester, const Size(393, 800));

    await tester.tap(find.text('Prescribe'));
    await tester.pumpAndSettle();

    expect(find.text('Write Prescription'), findsOneWidget);
    expect(find.text('1. Diagnosis & Chief Complaint'), findsOneWidget);
    final medicinesSection = find.text('3. Medicines');
    await tester.scrollUntilVisible(
      medicinesSection,
      280,
      scrollable: find.byType(Scrollable).last,
    );
    expect(medicinesSection, findsOneWidget);
    expect(find.text('Send Prescription'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets(
    'appointments search, filters, actions, and back navigation work',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _pumpDoctorApp(tester, const Size(393, 800));

      await tester.tap(find.text('Schedule').last);
      await tester.pumpAndSettle();
      expect(find.text('Appointments'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Fatima');
      await tester.pump();
      expect(find.text('Fatima Malik'), findsOneWidget);
      expect(find.text('Ahmed Hassan'), findsNothing);

      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Pending'));
      await tester.pumpAndSettle();
      expect(find.text('Ahmed Hassan'), findsOneWidget);

      await tester.tap(find.text('Accept').first);
      await tester.pumpAndSettle();
      expect(find.text('Ahmed Hassan'), findsNothing);

      await tester.tap(find.byTooltip('Back to doctor home'));
      await tester.pumpAndSettle();
      expect(find.text('Dr. Sara Khan'), findsOneWidget);
    },
  );
}
