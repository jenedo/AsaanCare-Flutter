import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asaancare/doctor/doctor_app.dart';
import 'package:asaancare/doctor/screens/patients/doctor_patient_profile_screen.dart';

Future<void> _pumpProfile(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  await tester.pumpWidget(
    const MaterialApp(
      home: DoctorPatientProfileScreen(
        patientName: 'Ahmed Hassan',
        patientAge: 32,
        patientGender: 'Male',
        appointmentId: 'AC-250512-001',
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('doctor opens a patient record from the patients list', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 800);

    await tester.pumpWidget(const DoctorApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patients').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ahmed Hassan'));
    await tester.pumpAndSettle();

    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Allergies & Conditions'), findsOneWidget);
    expect(find.text('Start Consultation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('patient profile is overflow-free at supported phone widths', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in <double>[320, 360, 393, 430]) {
      await _pumpProfile(tester, Size(width, 800));
      expect(find.text('Ahmed Hassan'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsWidgets);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('doctor can inspect every clinical record tab', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pumpProfile(tester, const Size(393, 800));

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('Visit History'), findsOneWidget);

    await tester.tap(find.widgetWithText(InkWell, 'Prescriptions'));
    await tester.pumpAndSettle();
    expect(find.text('Amoxicillin, Paracetamol'), findsOneWidget);

    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(find.text('HbA1c - 6.8%'), findsOneWidget);

    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();
    expect(find.text('Clinical Notes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('doctor can add a clinical note', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pumpProfile(tester, const Size(393, 800));

    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'Review blood pressure in 7 days.',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save Note'));
    await tester.pumpAndSettle();

    expect(find.text('Review blood pressure in 7 days.'), findsOneWidget);
    expect(find.text('Clinical note saved.'), findsOneWidget);
  });
}
