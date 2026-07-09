import '../entities/appointment_record.dart';
import '../repositories/appointment_repository.dart';

class GetAppointments {
  const GetAppointments(this._repository);

  final AppointmentRepository _repository;

  Future<List<AppointmentRecord>> call({required String patientId}) {
    return _repository.getAppointments(patientId: patientId);
  }
}
