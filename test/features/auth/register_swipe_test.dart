import 'package:asaancare/features/auth/domain/entities/auth_user.dart';
import 'package:asaancare/features/auth/domain/repositories/auth_repository.dart';
import 'package:asaancare/features/auth/domain/usecases/get_current_user.dart';
import 'package:asaancare/features/auth/domain/usecases/login_user.dart';
import 'package:asaancare/features/auth/domain/usecases/logout_user.dart';
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
              child: SwipeNextControl(
                loading: false,
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
    expect(tester.getSemantics(control).value, anyOf('0', '0 percent'));
  });

  testWidgets(
    'valid step one opens doctor verification step without exposing password',
    (tester) async {
      final repository = _FakeAuthRepository();
      await _pumpRegisterScreen(tester, repository);

      await _completeStepOne(tester);

      expect(find.text('Doctor verification'), findsOneWidget);
      expect(find.text('Enter your password'), findsNothing);
      expect(find.text('p@ssword123'), findsNothing);
    },
  );

  testWidgets('step two validates doctor fields before submitting', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await _pumpRegisterScreen(tester, repository);
    await _completeStepOne(tester);

    final submitButton = find.text('Submit verification request');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();

    expect(find.text('Enter your medical license number.'), findsOneWidget);
    expect(find.text('Enter your specialization.'), findsOneWidget);
    expect(repository.registerCount, 0);
  });

  testWidgets('step two submits saved step one data through auth controller', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await _pumpRegisterScreen(tester, repository);
    await _completeStepOne(tester);

    final stepTwoFields = find.byType(TextFormField);
    await tester.enterText(stepTwoFields.at(0), 'PMDC-12345');
    await tester.enterText(stepTwoFields.at(1), 'Cardiology');
    await tester.enterText(stepTwoFields.at(2), '9');
    await tester.enterText(stepTwoFields.at(3), 'City Care Hospital');
    final submitButton = find.text('Submit verification request');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(repository.registerCount, 1);
    expect(repository.lastFullName, 'Dr Test User');
    expect(repository.lastEmailOrPhone, 'doctor@example.com');
    expect(repository.lastPassword, 'p@ssword123');
    expect(find.text('Doctor verification request submitted.'), findsOneWidget);
  });
}

Future<void> _pumpRegisterScreen(
  WidgetTester tester,
  _FakeAuthRepository repository,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 900);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final controller = AuthController(
    getCurrentUser: GetCurrentUser(repository),
    loginUser: LoginUser(repository),
    registerPatient: RegisterPatient(repository),
    logoutUser: LogoutUser(repository),
  );

  await tester.pumpWidget(
    MaterialApp(home: RegisterScreen(authController: controller)),
  );
  await tester.pump();
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
  await tester.drag(swipeControl, const Offset(700, 0));
  await tester.pumpAndSettle();
}

class _FakeAuthRepository implements AuthRepository {
  int registerCount = 0;
  String? lastFullName;
  String? lastEmailOrPhone;
  String? lastPassword;

  @override
  Future<AuthUser?> getCurrentUser() async => null;

  @override
  Future<AuthUser> login({
    required String emailOrPhone,
    required String password,
  }) async {
    return AuthUser(
      id: 'login-user',
      fullName: 'Login User',
      emailOrPhone: emailOrPhone,
      role: UserRole.doctor,
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AuthUser> registerPatient({
    required String fullName,
    required String emailOrPhone,
    required String password,
  }) async {
    registerCount++;
    lastFullName = fullName;
    lastEmailOrPhone = emailOrPhone;
    lastPassword = password;
    return AuthUser(
      id: 'registered-user',
      fullName: fullName,
      emailOrPhone: emailOrPhone,
      role: UserRole.doctor,
    );
  }
}
