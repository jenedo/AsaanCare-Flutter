import '../entities/appointment_record.dart';
import '../entities/consultation_type.dart';
import '../repositories/appointment_repository.dart';

class BookAppointment {
  const BookAppointment(this._repository);

  final AppointmentRepository _repository;

  Future<AppointmentRecord> call({
    required String patientId,
    required String doctorId,
    required ConsultationType consultationType,
    required DateTime appointmentDate,
    required String dateLabel,
    required String timeLabel,
    required int totalFee,
  }) {
    return _repository.bookAppointment(
      patientId: patientId,
      doctorId: doctorId,
      consultationType: consultationType,
      appointmentDate: appointmentDate,
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      totalFee: totalFee,
    );
  }
}
