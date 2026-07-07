import '../entities/consultation_type.dart';

abstract class AppointmentRepository {
  Future<void> bookAppointment({
    required String doctorId,
    required ConsultationType consultationType,
    required String dateLabel,
    required String timeLabel,
    required int totalFee,
  });
}
