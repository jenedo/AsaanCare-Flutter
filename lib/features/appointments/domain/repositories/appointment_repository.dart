import '../entities/appointment_record.dart';
import '../entities/consultation_type.dart';

abstract class AppointmentRepository {
  Future<AppointmentRecord> bookAppointment({
    required String patientId,
    required String doctorId,
    required ConsultationType consultationType,
    required String dateLabel,
    required String timeLabel,
    required int totalFee,
  });

  Future<List<AppointmentRecord>> getAppointments({required String patientId});
}
