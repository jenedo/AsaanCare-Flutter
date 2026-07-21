import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app/app.dart';
import 'core/di/service_locator.dart';
import 'core/logging/app_logger.dart';
import 'core/routes/app_routes.dart';
import 'doctor/doctor_app.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/domain/entities/auth_user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  try {
    await setupServiceLocator();

    final authController = sl<AuthController>();
    await authController.loadCurrentUser();

    const appMode = String.fromEnvironment('APP_MODE', defaultValue: 'patient');
    if (appMode == 'doctor') {
      if (authController.isLoggedIn &&
          authController.currentUser?.role != UserRole.doctor) {
        await authController.logout();
      }
      runApp(DoctorApp(authController: authController));
      return;
    }

    runApp(
      AsaanCareApp(
        initialRoute: authController.isLoggedIn
            ? AppRoutes.patientHome
            : AppRoutes.welcome,
      ),
    );
  } catch (error, stackTrace) {
    AppLogger.error('main.startup', error, stackTrace);
    runApp(const _StartupFailureApp());
  }
}

class _StartupFailureApp extends StatelessWidget {
  const _StartupFailureApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'AsaanCare could not start. Check the app configuration and try again.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
