// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals

import '../../domain/entities/appointment_record.dart';
import '../../domain/entities/consultation_type.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_mock_data_source.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  const AppointmentRepositoryImpl({
    required AppointmentMockDataSource mockDataSource,
  }) : _mockDataSource = mockDataSource;

  final AppointmentMockDataSource _mockDataSource;

  @override
  Future<AppointmentRecord> bookAppointment({
    required String patientId,
    required String doctorId,
    required ConsultationType consultationType,
    required DateTime appointmentDate,
    required String dateLabel,
    required String timeLabel,
    required int totalFee,
  }) {
    return _mockDataSource.bookAppointment(
      patientId: patientId,
      doctorId: doctorId,
      consultationType: consultationType,
      appointmentDate: appointmentDate,
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      totalFee: totalFee,
    );
  }

  @override
  Future<List<AppointmentRecord>> getAppointments({required String patientId}) {
    return _mockDataSource.getAppointments(patientId: patientId);
  }
}
