import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/di/service_locator.dart';
import 'doctor/doctor_app.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  await setupServiceLocator();

  final authController = sl<AuthController>();
  await authController.loadCurrentUser();

  runApp(DoctorApp(authController: authController));
}
