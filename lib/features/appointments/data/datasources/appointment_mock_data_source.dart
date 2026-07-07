import '../../domain/entities/consultation_type.dart';

class AppointmentMockDataSource {
  Future<void> bookAppointment({
    required String doctorId,
    required ConsultationType consultationType,
    required String dateLabel,
    required String timeLabel,
    required int totalFee,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    if (doctorId.trim().isEmpty) {
      throw const AppointmentDataException('Doctor is required.');
    }

    if (dateLabel.trim().isEmpty || timeLabel.trim().isEmpty) {
      throw const AppointmentDataException('Date and time are required.');
    }
  }
}

class AppointmentDataException implements Exception {
  const AppointmentDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
