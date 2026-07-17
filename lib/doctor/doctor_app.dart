import 'package:flutter/material.dart';

import '../core/di/service_locator.dart';
import '../features/auth/domain/entities/auth_user.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import 'features/dashboard/presentation/controllers/doctor_dashboard_controller.dart';
import 'features/finance/presentation/controllers/doctor_finance_controller.dart';
import 'screens/auth/doctor_sign_in_screen.dart';
import 'screens/dashboard/doctor_dashboard_screen.dart';

class DoctorApp extends StatefulWidget {
  const DoctorApp({
    super.key,
    this.authController,
    this.dashboardController,
    this.financeController,
  });

  final AuthController? authController;
  final DoctorDashboardController? dashboardController;
  final DoctorFinanceController? financeController;

  @override
  State<DoctorApp> createState() => _DoctorAppState();
}

class _DoctorAppState extends State<DoctorApp> {
  ThemeMode _themeMode = ThemeMode.light;
  DoctorDashboardController? _dashboardController;
  DoctorFinanceController? _financeController;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  void dispose() {
    if (widget.dashboardController == null) _dashboardController?.dispose();
    if (widget.financeController == null) _financeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF078D83);

    Widget buildMaterialApp() {
      return MaterialApp(
        title: 'AsaanCare Doctor',
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: _theme(Brightness.light, seed),
        darkTheme: _theme(Brightness.dark, seed),
        home: _buildHome(),
      );
    }

    final authController = widget.authController;

    // Tests may construct DoctorApp without a controller.
    // Missing controller must show login, never the dashboard.
    if (authController == null) {
      return buildMaterialApp();
    }

    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) => buildMaterialApp(),
    );
  }

  Widget _buildHome() {
    final authController = widget.authController;
    final currentUser = authController?.currentUser;

    final isAuthenticatedDoctor =
        authController != null &&
        authController.isLoggedIn &&
        currentUser != null &&
        currentUser.role == UserRole.doctor;

    if (isAuthenticatedDoctor) {
      final dashboardController = _dashboardController ??=
          widget.dashboardController ?? sl<DoctorDashboardController>();
      final financeController = _financeController ??=
          widget.financeController ?? sl<DoctorFinanceController>();
      return DoctorDashboardScreen(
        doctorId: currentUser.id,
        doctorName: currentUser.fullName,
        dashboardController: dashboardController,
        financeController: financeController,
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeToggle: _toggleTheme,
      );
    }

    return Builder(
      builder: (context) {
        return DoctorSignInScreen(
          authController: authController,
          onAuthenticated: () {
            if (!mounted) {
              return;
            }

            setState(() {});
          },
          onCreateAccount: () {
            final availableAuthController = authController;
            if (availableAuthController == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Authentication service is unavailable.'),
                ),
              );
              return;
            }

            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (registrationContext) {
                  return RegisterScreen(
                    authController: availableAuthController,
                    onSignIn: () {
                      Navigator.of(registrationContext).pop();
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  ThemeData _theme(Brightness brightness, Color seed) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF9FBFB)
          : const Color(0xFF0E1719),
      fontFamily: 'Roboto',
      visualDensity: VisualDensity.standard,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
