import 'package:asaancare/doctor/screens/auth/doctor_sign_in_screen.dart';
import 'package:asaancare/doctor/doctor_app.dart';
import 'package:asaancare/features/auth/data/datasources/auth_mock_data_source.dart';
import 'package:asaancare/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:asaancare/features/auth/domain/usecases/get_current_user.dart';
import 'package:asaancare/features/auth/domain/usecases/login_user.dart';
import 'package:asaancare/features/auth/domain/usecases/logout_user.dart';
import 'package:asaancare/features/auth/domain/usecases/register_patient.dart';
import 'package:asaancare/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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
  });

  testWidgets('shows inline validation without sending empty credentials', (
    tester,
  ) async {
    await _pumpScreen(tester, controller: _buildController());

    await _completeSwipe(tester);
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
  });

  testWidgets('accepts a verified doctor account', (tester) async {
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
    await _completeSwipe(tester);
    await tester.pumpAndSettle();

    expect(authenticated, isTrue);
    expect(controller.currentUser?.fullName, 'Dr. Ali Raza');
  });

  testWidgets('doctor app transitions from sign-in to the dashboard', (
    tester,
  ) async {
    final controller = _buildController();
    await tester.pumpWidget(DoctorApp(authController: controller));
    await tester.pump();

    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Ahmed Hassan'), findsNothing);

    await controller.login(
      emailOrPhone: AuthMockDataSource.doctorDemoEmail,
      password: AuthMockDataSource.doctorDemoPassword,
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Ahmed Hassan'), findsWidgets);
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
    await _completeSwipe(tester);
    await tester.pumpAndSettle();

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
    });
  }

  testWidgets('supports keyboard completion and exposes slider semantics', (
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

    tester.testTextInput.hide();
    final handle = find.byIcon(Icons.arrow_forward_rounded);
    await tester.ensureVisible(handle);
    await tester.tap(handle);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(authenticated, isTrue);
    expect(find.bySemanticsLabel(RegExp('Swipe to sign in')), findsOneWidget);
  });

  testWidgets('an incomplete swipe returns to start and shows guidance', (
    tester,
  ) async {
    await _pumpScreen(tester, controller: _buildController());
    final handle = find.byIcon(Icons.arrow_forward_rounded);
    await tester.ensureVisible(handle);

    await tester.drag(handle, const Offset(40, 0));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Drag the handle all the way to the right'),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 1900));
    expect(find.text('Drag the handle all the way to the right'), findsNothing);
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
    logoutUser: LogoutUser(repository),
  );
}

Future<void> _completeSwipe(WidgetTester tester) async {
  tester.testTextInput.hide();
  final handle = find.byIcon(Icons.arrow_forward_rounded);
  await tester.ensureVisible(handle);
  await tester.pump();
  await tester.drag(handle, const Offset(700, 0));
}
