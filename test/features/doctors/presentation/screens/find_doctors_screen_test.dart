import 'package:asaancare/core/routes/app_routes.dart';
import 'package:asaancare/core/theme/app_theme.dart';
import 'package:asaancare/features/doctors/domain/entities/doctor.dart';
import 'package:asaancare/features/doctors/domain/repositories/doctor_repository.dart';
import 'package:asaancare/features/doctors/domain/usecases/get_doctors.dart';
import 'package:asaancare/features/doctors/presentation/controllers/find_doctors_controller.dart';
import 'package:asaancare/features/doctors/presentation/screens/find_doctors_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpScreen(WidgetTester tester, Size size) async {
  await tester.pumpWidget(const SizedBox.shrink());
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  final controller = FindDoctorsController(
    getDoctors: GetDoctors(_FakeDoctorRepository()),
  );

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme(),
      home: FindDoctorsScreen(controller: controller),
      routes: {
        AppRoutes.doctorDetail: (_) =>
            const Scaffold(body: Center(child: Text('Doctor details opened'))),
      },
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('find doctor layout is responsive on patient phone widths', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in <double>[320, 360, 393, 430]) {
      await _pumpScreen(tester, Size(width, 820));
      expect(find.text('Find Doctor'), findsOneWidget);
      expect(find.text('2 Doctors found'), findsOneWidget);
      expect(find.textContaining('Slots Available'), findsWidgets);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('patient can search doctors and open a doctor profile', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pumpScreen(tester, const Size(393, 820));

    await tester.enterText(find.byType(TextField), 'dermatologist');
    await tester.pump();
    expect(find.text('1 Doctor found'), findsOneWidget);
    expect(find.text('Dr. Sara Khan'), findsOneWidget);
    expect(find.text('Dr. Ali Raza'), findsNothing);

    await tester.tap(find.text('Dr. Sara Khan'));
    await tester.pumpAndSettle();
    expect(find.text('Doctor details opened'), findsOneWidget);
  });

  testWidgets('patient can filter by specialty and choose an available day', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pumpScreen(tester, const Size(393, 820));

    await tester.tap(find.bySemanticsLabel('Filter doctors'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dermatologist').last);
    await tester.pumpAndSettle();

    expect(find.text('1 Doctor found'), findsOneWidget);
    expect(find.text('Dr. Sara Khan'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('sara-day-0')));
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel(RegExp('Selected appointment day')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

class _FakeDoctorRepository implements DoctorRepository {
  static const _doctors = [
    Doctor(
      id: 'ali',
      name: 'Dr. Ali Raza',
      qualification: 'MBBS, FCPS Cardiology',
      specialty: 'Cardiologist',
      imageAsset: '',
      rating: 4.9,
      reviewCount: 250,
      experienceYears: 9,
      consultationFee: 1000,
      patientsCount: 1200,
      about: 'Patient-focused heart care.',
      isVerified: true,
    ),
    Doctor(
      id: 'sara',
      name: 'Dr. Sara Khan',
      qualification: 'MBBS, FCPS Dermatology',
      specialty: 'Dermatologist',
      imageAsset: '',
      rating: 4.8,
      reviewCount: 180,
      experienceYears: 7,
      consultationFee: 800,
      patientsCount: 900,
      about: 'Evidence-based skin care.',
      isVerified: true,
    ),
  ];

  @override
  Future<List<Doctor>> getDoctors() async => _doctors;

  @override
  Future<Doctor> getDoctorDetail(String doctorId) async =>
      _doctors.firstWhere((doctor) => doctor.id == doctorId);
}
