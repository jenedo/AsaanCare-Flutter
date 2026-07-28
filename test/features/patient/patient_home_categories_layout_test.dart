import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asaancare/core/di/service_locator.dart';
import 'package:asaancare/core/theme/app_theme.dart';
import 'package:asaancare/features/auth/presentation/controllers/auth_controller.dart';
import 'package:asaancare/features/patient/presentation/screens/patient_home_screen.dart';

void main() {
  setUp(() async {
    await sl.reset();
    await setupServiceLocator();
  });

  tearDown(() async {
    await sl.reset();
  });

  for (final size in <Size>[
    const Size(280, 640),
    const Size(320, 568),
    const Size(360, 640),
    const Size(430, 800),
    const Size(568, 320),
  ]) {
    testWidgets('specialty images fit without overflow at '
        '${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;

      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          home: PatientHomeScreen(authController: sl<AuthController>()),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(ListView).first, const Offset(0, -220));
      await tester.pumpAndSettle();
      expect(find.text('General\nDoctor'), findsOneWidget);
      expect(find.text('Pediatrics'), findsOneWidget);
      expect(find.text('Gynecology'), findsOneWidget);
      expect(find.text('Dermatology'), findsOneWidget);

      await tester.drag(find.byType(ListView).at(1), const Offset(-260, 0));
      await tester.pumpAndSettle();
      expect(find.text('Dentistry'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
}
