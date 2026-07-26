import 'dart:typed_data';

import 'package:asaancare/core/routes/app_routes.dart';
import 'package:asaancare/features/auth/domain/entities/auth_user.dart';
import 'package:asaancare/features/auth/domain/entities/doctor_registration_payload.dart';
import 'package:asaancare/features/auth/domain/repositories/auth_repository.dart';
import 'package:asaancare/features/auth/domain/usecases/get_current_user.dart';
import 'package:asaancare/features/auth/domain/usecases/login_user.dart';
import 'package:asaancare/features/auth/domain/usecases/logout_user.dart';
import 'package:asaancare/features/auth/domain/usecases/register_doctor.dart';
import 'package:asaancare/features/auth/domain/usecases/register_patient.dart';
import 'package:asaancare/features/auth/presentation/controllers/auth_controller.dart';
import 'package:asaancare/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cancelled swipe resets without completing', (tester) async {
    var completionCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 100,
              child: SwipeNextControl(
                loading: false,
                label: 'Swipe to test',
                onComplete: () async {
                  completionCount++;
                  return true;
                },
              ),
            ),
          ),
        ),
      ),
    );

    final control = find.byType(SwipeNextControl);
    final gesture = await tester.startGesture(tester.getCenter(control));
    await gesture.moveBy(const Offset(380, 0));
    await gesture.cancel();
    await tester.pumpAndSettle();

    expect(completionCount, 0);
  });

  testWidgets('patient registration navigates to /patient-home', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await _pumpRegisterScreen(tester, repository, isDoctor: false);

    await _completeStepOne(tester);

    expect(find.text('Patient Home Page'), findsOneWidget);
    expect(repository.registerPatientCount, 1);
  });

  testWidgets(
    'valid step one opens doctor verification step without exposing password',
    (tester) async {
      final repository = _FakeAuthRepository();
      await _pumpRegisterScreen(tester, repository, isDoctor: true);

      await _completeStepOne(tester);

      expect(find.text('Professional Details'), findsOneWidget);
      expect(find.text('Enter your password'), findsNothing);
      expect(find.text('p@ssword123'), findsNothing);
    },
  );

  testWidgets('step two validates doctor fields before submitting', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await _pumpRegisterScreen(tester, repository, isDoctor: true);
    await _completeStepOne(tester);

    final swipeControl = find.byType(SwipeNextControl);
    await tester.ensureVisible(swipeControl);
    final state = tester.state(swipeControl);
    final dynamic widget = state.widget;
    await widget.onComplete();
    await tester.pump();

    expect(
      find.text('Upload the medical license and both sides of your ID.'),
      findsOneWidget,
    );
    expect(
      find.text('Accept the verification terms to continue.'),
      findsOneWidget,
    );
    expect(repository.registerCount, 0);
  });

  testWidgets('step two submits saved step one data through auth controller', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await _pumpRegisterScreen(tester, repository, isDoctor: true);
    await _completeStepOne(tester);

    final RegisterScreenState state = tester.state(find.byType(RegisterScreen));
    state.setStepTwoDataForTesting(
      specialty: 'Cardiologist',
      pmdc: 'PMDC-12345',
      experience: '9',
      clinic: 'City Care Hospital',
      fee: '1500',
      medicalLicense: RegistrationUpload(
        name: 'license.pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
        extension: 'pdf',
      ),
      idFront: RegistrationUpload(
        name: 'front.png',
        bytes: Uint8List.fromList([1, 2, 3]),
        extension: 'png',
      ),
      idBack: RegistrationUpload(
        name: 'back.png',
        bytes: Uint8List.fromList([1, 2, 3]),
        extension: 'png',
      ),
      agreed: true,
    );
    await tester.pump();

    final swipeControl = find.byType(SwipeNextControl);
    await tester.ensureVisible(swipeControl);
    final swipeState = tester.state(swipeControl);
    final dynamic swipeWidget = swipeState.widget;
    final future = swipeWidget.onComplete();
    await tester.pump(const Duration(seconds: 3));
    await future;

    expect(repository.registerCount, 1);
    expect(repository.lastFullName, 'Dr Test User');
    expect(repository.lastEmailOrPhone, 'doctor@example.com');
  });
}

Future<void> _pumpRegisterScreen(
  WidgetTester tester,
  _FakeAuthRepository repository, {
  bool isDoctor = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 900);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final controller = AuthController(
    getCurrentUser: GetCurrentUser(repository),
    loginUser: LoginUser(repository),
    registerPatient: RegisterPatient(repository),
    registerDoctor: RegisterDoctor(repository),
    logoutUser: LogoutUser(repository),
  );

  await tester.pumpWidget(
    MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => RegisterScreen(
                    authController: controller,
                    onRegisterDoctor: isDoctor
                        ? (payload) => controller.registerDoctor(payload)
                        : null,
                  ),
                ),
              ),
              child: const Text('Open Register'),
            ),
          ),
        ),
        AppRoutes.patientHome: (context) =>
            const Scaffold(body: Text('Patient Home Page')),
      },
    ),
  );
  await tester.tap(find.text('Open Register'));
  await tester.pumpAndSettle();
}

Future<void> _completeStepOne(WidgetTester tester) async {
  final stepOneFields = find.byType(TextFormField);
  await tester.enterText(stepOneFields.at(0), 'Dr Test User');
  await tester.enterText(stepOneFields.at(1), 'doctor@example.com');
  await tester.enterText(stepOneFields.at(2), '+923001234567');
  await tester.enterText(stepOneFields.at(3), 'p@ssword123');
  await tester.enterText(stepOneFields.at(4), 'p@ssword123');
  final gender = find.text('Male');
  await tester.ensureVisible(gender);
  await tester.tap(gender);
  await tester.pump();
  final swipeControl = find.byType(SwipeNextControl);
  tester.testTextInput.hide();
  await tester.ensureVisible(swipeControl);
  final state = tester.state(swipeControl);
  final dynamic widget = state.widget;
  await widget.onComplete();
  await tester.pumpAndSettle();
}

class _FakeAuthRepository implements AuthRepository {
  int registerCount = 0;
  int registerPatientCount = 0;
  String? lastFullName;
  String? lastEmailOrPhone;
  String? lastPassword;

  @override
  Future<AuthUser?> getCurrentUser() async => null;

  @override
  Future<AuthUser> registerDoctor(DoctorRegistrationPayload payload) async {
    registerCount++;
    lastFullName = payload.fullName;
    lastEmailOrPhone = payload.email;
    lastPassword = payload.password;
    return AuthUser(
      id: 'doc-1',
      fullName: payload.fullName,
      emailOrPhone: payload.email,
      role: UserRole.doctor,
    );
  }

  @override
  Future<AuthUser> login({
    required String emailOrPhone,
    required String password,
  }) async {
    return const AuthUser(
      id: 'doc-1',
      fullName: 'Dr Test User',
      emailOrPhone: 'doctor@example.com',
      role: UserRole.doctor,
    );
  }

  @override
  Future<AuthUser> registerPatient({
    required String fullName,
    required String emailOrPhone,
    required String password,
  }) async {
    registerPatientCount++;
    return AuthUser(
      id: 'patient-1',
      fullName: fullName,
      emailOrPhone: emailOrPhone,
      role: UserRole.patient,
    );
  }

  @override
  Future<void> logout() async {}
}
