import '../entities/doctor_dashboard_snapshot.dart';
import '../repositories/doctor_dashboard_repository.dart';

class GetDoctorDashboard {
  const GetDoctorDashboard(this._repository);

  final DoctorDashboardRepository _repository;

  Future<DoctorDashboardSnapshot> call({required String doctorId}) {
    return _repository.getDashboard(doctorId: doctorId);
  }
}

class UpdateDoctorAppointmentStatus {
  const UpdateDoctorAppointmentStatus(this._repository);

  final DoctorDashboardRepository _repository;

  Future<DoctorDashboardSnapshot> call({
    required String doctorId,
    required String appointmentId,
    required DoctorAppointmentStatus status,
  }) {
    return _repository.updateAppointmentStatus(
      doctorId: doctorId,
      appointmentId: appointmentId,
      status: status,
    );
  }
}

class UpdateDoctorAvailability {
  const UpdateDoctorAvailability(this._repository);

  final DoctorDashboardRepository _repository;

  Future<DoctorDashboardSnapshot> call({
    required String doctorId,
    required bool isOnline,
  }) {
    return _repository.updateAvailability(
      doctorId: doctorId,
      isOnline: isOnline,
    );
  }
}
