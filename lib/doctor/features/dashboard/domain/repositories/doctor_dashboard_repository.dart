import '../entities/doctor_dashboard_snapshot.dart';

abstract class DoctorDashboardRepository {
  Future<DoctorDashboardSnapshot> getDashboard({required String doctorId});

  Future<DoctorDashboardSnapshot> updateAppointmentStatus({
    required String doctorId,
    required String appointmentId,
    required DoctorAppointmentStatus status,
  });

  /// Persists the doctor's "Available for Consultation" toggle.
  /// NestJS swap point: replace the mock datasource implementation.
  Future<DoctorDashboardSnapshot> updateAvailability({
    required String doctorId,
    required bool isOnline,
  });
}
