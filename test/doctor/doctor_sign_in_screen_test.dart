import 'package:asaancare/doctor/screens/auth/doctor_sign_in_screen.dart';
import 'package:asaancare/doctor/doctor_app.dart';
import 'package:asaancare/features/auth/data/datasources/auth_mock_data_source.dart';
import 'package:asaancare/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:asaancare/features/auth/domain/usecases/get_current_user.dart';
import 'package:asaancare/features/auth/domain/usecases/login_user.dart';
import 'package:asaancare/features/auth/domain/usecases/logout_user.dart';
import 'package:asaancare/features/auth/domain/usecases/register_doctor.dart';
import 'package:asaancare/features/auth/domain/usecases/register_patient.dart';
import 'package:asaancare/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/doctor_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders the complete doctor sign-in experience', (tester) async {
    await _pumpScreen(tester, controller: _buildController());

    expect(find.text('Sign In'), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Sign in with Apple'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.byType(SwipeSignInControl), findsOneWidget);
  });

  testWidgets('shows inline validation without sending empty credentials', (
    tester,
  ) async {
    await _pumpScreen(tester, controller: _buildController());

    await _triggerSwipeComplete(tester);

    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
  });

  testWidgets('accepts a verified doctor account when swipe completes', (
    tester,
  ) async {
    final controller = _buildController();
    var authenticated = false;
    await _pumpScreen(
      tester,
      controller: controller,
      onAuthenticated: () => authenticated = true,
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      AuthMockDataSource.doctorDemoEmail,
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      AuthMockDataSource.doctorDemoPassword,
    );
    await _triggerSwipeComplete(tester);

    expect(authenticated, isTrue);
    expect(controller.currentUser?.fullName, 'Dr. Ali Raza');
  });

  testWidgets('doctor app transitions from sign-in to the dashboard', (
    tester,
  ) async {
    final harness = createDoctorTestHarness();
    addTearDown(harness.dispose);

    final controller = _buildController();
    await tester.pumpWidget(
      DoctorApp(
        authController: controller,
        dashboardController: harness.dashboard,
        financeController: harness.finance,
      ),
    );
    await tester.pump();

    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Dr. Ali Raza'), findsNothing);

    final future = controller.login(
      emailOrPhone: AuthMockDataSource.doctorDemoEmail,
      password: AuthMockDataSource.doctorDemoPassword,
    );
    await tester.pump(const Duration(milliseconds: 500));
    await future;
    await tester.pumpAndSettle();

    expect(find.text('Dr. Ali Raza'), findsWidgets);
    expect(find.text('Sign in with Google'), findsNothing);
  });

  testWidgets('rejects a patient account on the doctor sign-in page', (
    tester,
  ) async {
    final controller = _buildController();
    await _pumpScreen(tester, controller: controller);

    await tester.enterText(
      find.byType(TextFormField).first,
      AuthMockDataSource.demoEmail,
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      AuthMockDataSource.demoPassword,
    );
    await _triggerSwipeComplete(tester);

    expect(
      find.text('This sign-in page is only for verified doctor accounts.'),
      findsOneWidget,
    );
    expect(controller.isLoggedIn, isFalse);
  });

  for (final width in [320.0, 360.0, 393.0, 430.0, 768.0]) {
    testWidgets('has no layout overflow at ${width.toInt()}px', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pumpScreen(tester, controller: _buildController());

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(SwipeSignInControl), findsOneWidget);
    });
  }

  testWidgets('incomplete swipe gesture does not submit form', (tester) async {
    final controller = _buildController();
    await _pumpScreen(tester, controller: controller);

    final controlFinder = find.byType(SwipeSignInControl);
    expect(controlFinder, findsOneWidget);

    await tester.pump();

    expect(controller.isLoggedIn, isFalse);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required AuthController controller,
  VoidCallback? onAuthenticated,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: DoctorSignInScreen(
        authController: controller,
        onAuthenticated: onAuthenticated ?? () {},
        onCreateAccount: () {},
      ),
    ),
  );
  await tester.pump();
}

AuthController _buildController() {
  final repository = AuthRepositoryImpl(dataSource: AuthMockDataSource());
  return AuthController(
    getCurrentUser: GetCurrentUser(repository),
    loginUser: LoginUser(repository),
    registerPatient: RegisterPatient(repository),
    registerDoctor: RegisterDoctor(repository),
    logoutUser: LogoutUser(repository),
  );
}

Future<void> _triggerSwipeComplete(WidgetTester tester) async {
  tester.testTextInput.hide();
  final controlFinder = find.byType(SwipeSignInControl);
  await tester.ensureVisible(controlFinder);
  await tester.pump();
  final state = tester.state<SwipeSignInControlState>(controlFinder);
  final future = state.widget.onSwipeComplete();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  final authenticated = await future;
  if (authenticated) {
    state.widget.onSuccess();
  }
  await tester.pumpAndSettle();
}
