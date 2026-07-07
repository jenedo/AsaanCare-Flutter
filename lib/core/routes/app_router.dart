import 'package:flutter/material.dart';

import '../../features/appointments/presentation/controllers/appointment_booking_controller.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/doctors/presentation/controllers/doctor_detail_controller.dart';
import '../../features/doctors/presentation/screens/doctor_detail_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/patient/presentation/screens/patient_home_screen.dart';
import '../../features/pharmacy/presentation/controllers/pharmacy_controller.dart';
import '../../features/pharmacy/presentation/screens/pharmacy_screen.dart';
import '../../features/prescriptions/presentation/controllers/prescription_controller.dart';
import '../../features/prescriptions/presentation/screens/medical_records_screen.dart';
import '../di/service_locator.dart';
import 'app_routes.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.welcome:
        return _smoothRoute(settings: settings, child: const WelcomeScreen());

      case AppRoutes.onboarding:
        return _smoothRoute(
          settings: settings,
          child: const OnboardingScreen(),
        );

      case AppRoutes.register:
        return _smoothRoute(
          settings: settings,
          child: RegisterScreen(authController: sl<AuthController>()),
        );

      case AppRoutes.login:
        return _smoothRoute(
          settings: settings,
          child: LoginScreen(authController: sl<AuthController>()),
        );

      case AppRoutes.patientHome:
        return _smoothRoute(
          settings: settings,
          child: PatientHomeScreen(authController: sl<AuthController>()),
        );

      case AppRoutes.doctorDetail:
        final doctorId = _readDoctorId(settings.arguments);

        return _smoothRoute(
          settings: settings,
          child: DoctorDetailScreen(
            doctorId: doctorId,
            doctorDetailController: sl<DoctorDetailController>(),
            bookingController: sl<AppointmentBookingController>(),
          ),
        );

      case AppRoutes.pharmacy:
        return _smoothRoute(
          settings: settings,
          child: PharmacyScreen(controller: sl<PharmacyController>()),
        );

      case AppRoutes.medicalRecords:
        return _smoothRoute(
          settings: settings,
          child: MedicalRecordsScreen(controller: sl<PrescriptionController>()),
        );

      default:
        return _smoothRoute(
          settings: settings,
          child: _UnknownRouteScreen(routeName: settings.name),
        );
    }
  }

  static String _readDoctorId(Object? arguments) {
    if (arguments is String && arguments.trim().isNotEmpty) {
      return arguments.trim();
    }

    return 'doctor_ali';
  }

  static PageRouteBuilder<dynamic> _smoothRoute({
    required RouteSettings settings,
    required Widget child,
  }) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(curvedAnimation);

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
    );
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen({required this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Route not found: ${routeName ?? 'unknown'}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
