import 'package:flutter/material.dart';

import '../routes/app_router.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

class AsaanCareApp extends StatelessWidget {
  const AsaanCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AsaanCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      initialRoute: AppRoutes.welcome,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
