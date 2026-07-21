import '../../domain/entities/doctor_dashboard_snapshot.dart';
import '../../domain/repositories/doctor_dashboard_repository.dart';
import '../datasources/doctor_dashboard_mock_data_source.dart';

class DoctorDashboardRepositoryImpl implements DoctorDashboardRepository {
  const DoctorDashboardRepositoryImpl({required this.dataSource});

  final DoctorDashboardMockDataSource dataSource;

  @override
  Future<DoctorDashboardSnapshot> getDashboard({required String doctorId}) {
    return dataSource.getDashboard(doctorId: doctorId);
  }

  @override
  Future<DoctorDashboardSnapshot> updateAppointmentStatus({
    required String doctorId,
    required String appointmentId,
    required DoctorAppointmentStatus status,
  }) {
    return dataSource.updateAppointmentStatus(
      doctorId: doctorId,
      appointmentId: appointmentId,
      status: status,
    );
  }

  @override
  Future<DoctorDashboardSnapshot> updateAvailability({
    required String doctorId,
    required bool isOnline,
  }) {
    return dataSource.updateAvailability(
      doctorId: doctorId,
      isOnline: isOnline,
    );
  }
}
