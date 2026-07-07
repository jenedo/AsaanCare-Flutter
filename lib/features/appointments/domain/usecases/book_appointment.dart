import '../entities/consultation_type.dart';
import '../repositories/appointment_repository.dart';

class BookAppointment {
  const BookAppointment(this._repository);

  final AppointmentRepository _repository;

  Future<void> call({
    required String doctorId,
    required ConsultationType consultationType,
    required String dateLabel,
    required String timeLabel,
    required int totalFee,
  }) {
    return _repository.bookAppointment(
      doctorId: doctorId,
      consultationType: consultationType,
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      totalFee: totalFee,
    );
  }
}
