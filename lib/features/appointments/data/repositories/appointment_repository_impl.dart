import '../../domain/entities/consultation_type.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_mock_data_source.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  const AppointmentRepositoryImpl({
    required this._mockDataSource,
  });

  final AppointmentMockDataSource _mockDataSource;

  @override
  Future<void> bookAppointment({
    required String doctorId,
    required ConsultationType consultationType,
    required String dateLabel,
    required String timeLabel,
    required int totalFee,
  }) {
    return _mockDataSource.bookAppointment(
      doctorId: doctorId,
      consultationType: consultationType,
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      totalFee: totalFee,
    );
  }
}
