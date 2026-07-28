import 'package:asaancare/features/auth/data/datasources/auth_mock_data_source.dart';
import 'package:asaancare/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:asaancare/features/auth/domain/usecases/get_current_user.dart';
import 'package:asaancare/features/auth/domain/usecases/login_user.dart';
import 'package:asaancare/features/auth/domain/usecases/logout_user.dart';
import 'package:asaancare/features/auth/domain/usecases/register_doctor.dart';
import 'package:asaancare/features/auth/domain/usecases/register_patient.dart';
import 'package:asaancare/features/auth/presentation/controllers/auth_controller.dart';
import 'package:asaancare/features/auth/presentation/screens/login_screen.dart';
import 'package:asaancare/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

Future<void> _pumpAt(
  WidgetTester tester, {
  required Size size,
  required Widget home,
  double keyboardInset = 0,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.view.viewInsets = FakeViewPadding(bottom: keyboardInset);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewInsets);

  await tester.pumpWidget(MaterialApp(home: home));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Login and Register have zero RenderFlex overflow at short/normal/tablet sizes',
    (tester) async {
      final cases = <(Size, double)>[
        (const Size(320, 569), 280),
        (const Size(390, 844), 0),
        (const Size(768, 1024), 0),
      ];

      for (final (size, keyboard) in cases) {
        final loginController = _buildController();
        await _pumpAt(
          tester,
          size: size,
          keyboardInset: keyboard,
          home: LoginScreen(authController: loginController),
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'Login overflow at $size keyboard=$keyboard',
        );
        expect(find.text('Welcome back'), findsOneWidget);
        expect(find.byType(SingleChildScrollView), findsWidgets);

        final registerController = _buildController();
        await _pumpAt(
          tester,
          size: size,
          keyboardInset: keyboard,
          home: RegisterScreen(authController: registerController),
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'Register overflow at $size keyboard=$keyboard',
        );
        expect(find.text('Create Account'), findsWidgets);
        expect(find.byType(SingleChildScrollView), findsWidgets);

        await tester.pumpWidget(const SizedBox.shrink());
      }
    },
  );

  testWidgets(
    'Login at 390x844 with keyboard closed still shows the same core fields',
    (tester) async {
      final controller = _buildController();
      await _pumpAt(
        tester,
        size: const Size(390, 844),
        home: LoginScreen(authController: controller),
      );

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email or phone'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
