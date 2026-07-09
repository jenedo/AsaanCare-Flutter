import 'dart:ui';

import 'package:flutter/material.dart';

import '../routes/app_router.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    PointerDeviceKind.mouse,
  };
}

class AsaanCareApp extends StatelessWidget {
  const AsaanCareApp({super.key, this.initialRoute = AppRoutes.welcome});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AsaanCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
      scrollBehavior: const AppScrollBehavior(),
    );
  }
}
