import '../entities/doctor_dashboard_snapshot.dart';

abstract class DoctorDashboardRepository {
  Future<DoctorDashboardSnapshot> getDashboard({required String doctorId});

  Future<DoctorDashboardSnapshot> updateAppointmentStatus({
    required String doctorId,
    required String appointmentId,
    required DoctorAppointmentStatus status,
  });
}
