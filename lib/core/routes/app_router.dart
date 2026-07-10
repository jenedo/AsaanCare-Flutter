import 'package:flutter/material.dart';

import '../../features/appointments/presentation/controllers/appointment_booking_controller.dart';
import '../../features/appointments/presentation/controllers/appointment_list_controller.dart';
import '../../features/appointments/presentation/screens/appointments_screen.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/doctors/presentation/controllers/doctor_detail_controller.dart';
import '../../features/doctors/presentation/screens/doctor_detail_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/patient/presentation/screens/patient_home_screen.dart';
import '../../features/patient/presentation/screens/patient_profile_screen.dart';
import '../../features/pharmacy/presentation/controllers/pharmacy_controller.dart';
import '../../features/pharmacy/presentation/screens/pharmacy_screen.dart';
import '../../features/prescriptions/presentation/controllers/prescription_controller.dart';
import '../../features/prescriptions/presentation/screens/medical_records_screen.dart';
import '../../features/wallet/presentation/controllers/wallet_controller.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../di/service_locator.dart';
import 'app_routes.dart';

class AppRouter {
  const AppRouter._();

  static const Set<String> _protectedRoutes = {
    AppRoutes.patientHome,
    AppRoutes.profile,
    AppRoutes.appointments,
    AppRoutes.doctorDetail,
    AppRoutes.pharmacy,
    AppRoutes.medicalRecords,
    AppRoutes.wallet,
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final authController = sl<AuthController>();

    if (_protectedRoutes.contains(settings.name) &&
        !authController.isLoggedIn) {
      return _smoothRoute(
        settings: const RouteSettings(name: AppRoutes.login),
        child: LoginScreen(authController: authController),
      );
    }

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
          child: RegisterScreen(authController: authController),
        );

      case AppRoutes.login:
        if (authController.isLoggedIn) {
          return _smoothRoute(
            settings: const RouteSettings(name: AppRoutes.patientHome),
            child: PatientHomeScreen(authController: authController),
          );
        }

        return _smoothRoute(
          settings: settings,
          child: LoginScreen(authController: authController),
        );

      case AppRoutes.patientHome:
        return _smoothRoute(
          settings: settings,
          child: PatientHomeScreen(authController: authController),
        );

      case AppRoutes.profile:
        return _smoothRoute(
          settings: settings,
          child: PatientProfileScreen(authController: authController),
        );

      case AppRoutes.appointments:
        final patientId = _readAuthenticatedPatientId(authController);

        if (patientId == null) {
          return _missingAuthenticatedPatientRoute(settings);
        }

        return _smoothRoute(
          settings: settings,
          child: AppointmentsScreen(
            controller: sl<AppointmentListController>(),
            patientId: patientId,
          ),
        );

      case AppRoutes.doctorDetail:
        final doctorId = _readDoctorId(settings.arguments);
        final patientId = _readAuthenticatedPatientId(authController);

        if (doctorId == null) {
          return _smoothRoute(
            settings: settings,
            child: const _InvalidRouteArgumentsScreen(
              message: 'A valid doctor id is required.',
            ),
          );
        }

        if (patientId == null) {
          return _missingAuthenticatedPatientRoute(settings);
        }

        return _smoothRoute(
          settings: settings,
          child: DoctorDetailScreen(
            patientId: patientId,
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
        final patientId = _readAuthenticatedPatientId(authController);

        if (patientId == null) {
          return _missingAuthenticatedPatientRoute(settings);
        }

        return _smoothRoute(
          settings: settings,
          child: MedicalRecordsScreen(
            controller: sl<PrescriptionController>(),
            patientId: patientId,
          ),
        );

      case AppRoutes.wallet:
        final patientId = _readAuthenticatedPatientId(authController);

        if (patientId == null) {
          return _missingAuthenticatedPatientRoute(settings);
        }

        return _smoothRoute(
          settings: settings,
          child: WalletScreen(
            controller: sl<WalletController>(),
            patientId: patientId,
            disposeController: true,
          ),
        );

      default:
        return _smoothRoute(
          settings: settings,
          child: _UnknownRouteScreen(routeName: settings.name),
        );
    }
  }

  static String? _readAuthenticatedPatientId(AuthController authController) {
    final patientId = authController.currentUser?.id.trim();

    if (patientId == null || patientId.isEmpty) {
      return null;
    }

    return patientId;
  }

  static Route<dynamic> _missingAuthenticatedPatientRoute(
    RouteSettings settings,
  ) {
    return _smoothRoute(
      settings: settings,
      child: const _InvalidRouteArgumentsScreen(
        message:
            'Your authenticated patient session is unavailable. '
            'Please sign in again.',
      ),
    );
  }

  static String? _readDoctorId(Object? arguments) {
    if (arguments is String && arguments.trim().isNotEmpty) {
      return arguments.trim();
    }

    return null;
  }

  static PageRouteBuilder<dynamic> _smoothRoute({
    required RouteSettings settings,
    required Widget child,
  }) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.025, 0),
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

class _InvalidRouteArgumentsScreen extends StatelessWidget {
  const _InvalidRouteArgumentsScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
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
