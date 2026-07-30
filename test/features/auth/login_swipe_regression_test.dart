import 'dart:async';

import 'package:asaancare/core/routes/app_routes.dart';
import 'package:asaancare/features/auth/data/datasources/auth_mock_data_source.dart';
import 'package:asaancare/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:asaancare/features/auth/domain/usecases/get_current_user.dart';
import 'package:asaancare/features/auth/domain/usecases/login_user.dart';
import 'package:asaancare/features/auth/domain/usecases/logout_user.dart';
import 'package:asaancare/features/auth/domain/usecases/register_doctor.dart';
import 'package:asaancare/features/auth/domain/usecases/register_patient.dart';
import 'package:asaancare/features/auth/presentation/controllers/auth_controller.dart';
import 'package:asaancare/features/auth/presentation/screens/login_screen.dart';
import 'package:asaancare/features/auth/presentation/widgets/swipe_to_sign_in_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'login copy uses an apostrophe and stays busy during the success overlay',
    (tester) async {
      final controller = _buildController();

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            AppRoutes.patientHome: (_) =>
                const Scaffold(body: Text('Patient Home')),
          },
          home: LoginScreen(authController: controller),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains("Don't have an account yet? "),
        ),
        findsOneWidget,
      );

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), AuthMockDataSource.demoEmail);
      await tester.enterText(fields.at(1), AuthMockDataSource.demoPassword);

      await _completeSwipe(tester);
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        tester
            .widget<SwipeToSignInControl>(find.byType(SwipeToSignInControl))
            .loading,
        isTrue,
      );

      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pumpAndSettle();

      expect(find.text('Patient Home'), findsOneWidget);
    },
  );

  testWidgets('thrown completion resets the swipe control for retry', (
    tester,
  ) async {
    var attempts = 0;
    final failure = StateError('sign-in failed');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              child: SwipeToSignInControl(
                loading: false,
                onComplete: () async {
                  attempts++;
                  if (attempts == 1) throw failure;
                  return false;
                },
              ),
            ),
          ),
        ),
      ),
    );

    Object? surfacedError;
    await runZonedGuarded(
      () async {
        await _completeSwipe(tester);
        await tester.pump();
      },
      (error, _) {
        surfacedError = error;
      },
    );

    expect(surfacedError, same(failure));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Swipe to Sign In'), findsOneWidget);

    await _completeSwipe(tester);

    await tester.pump(const Duration(milliseconds: 250));
    expect(attempts, 2);
    expect(find.text('Swipe to Sign In'), findsOneWidget);
  });
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

Future<void> _completeSwipe(WidgetTester tester) async {
  final control = find.byType(SwipeToSignInControl);
  final gesture = await tester.startGesture(tester.getCenter(control));
  await gesture.moveBy(const Offset(380, 0));
  await gesture.up();
  await tester.pump();
}
