import '../../domain/entities/appointment_record.dart';
import '../../domain/entities/consultation_type.dart';
import '../../domain/exceptions/appointment_exception.dart';

class AppointmentMockDataSource {
  AppointmentMockDataSource()
    : _appointments = [
        ..._joinableTestAppointments(),
        AppointmentRecord(
          id: 'appointment_upcoming_001',
          patientId: mockPatientId,
          doctorId: 'doctor_sara',
          doctorName: 'Dr. Sara Khan',
          doctorSpecialty: 'General Physician',
          doctorImageAsset: 'assets/images/doctor_sara.png',
          consultationType: ConsultationType.video,
          appointmentDate: DateTime(2026, 7, 11),
          dateLabel: 'Sat 11 Jul',
          timeLabel: '10:00 AM',
          totalFee: 800,
          status: AppointmentStatus.confirmed,
          createdAt: DateTime(2026, 7, 8, 10),
        ),
        AppointmentRecord(
          id: 'appointment_completed_001',
          patientId: mockPatientId,
          doctorId: 'doctor_ali',
          doctorName: 'Dr. Ali Raza',
          doctorSpecialty: 'Cardiologist',
          doctorImageAsset: 'assets/images/doctor_ali.png',
          consultationType: ConsultationType.video,
          appointmentDate: DateTime(2026, 6, 29),
          dateLabel: 'Mon 29 Jun',
          timeLabel: '04:00 PM',
          totalFee: 800,
          status: AppointmentStatus.completed,
          createdAt: DateTime(2026, 6, 29, 16),
        ),
        AppointmentRecord(
          id: 'appointment_cancelled_001',
          patientId: mockPatientId,
          doctorId: 'doctor_maheen',
          doctorName: 'Dr. Maheen Fatima',
          doctorSpecialty: 'Gynecologist',
          doctorImageAsset: 'assets/images/doctor_maheen.png',
          consultationType: ConsultationType.audio,
          appointmentDate: DateTime(2026, 6, 16),
          dateLabel: 'Tue 16 Jun',
          timeLabel: '01:00 PM',
          totalFee: 800,
          status: AppointmentStatus.cancelled,
          createdAt: DateTime(2026, 6, 16, 13),
        ),
      ];

  static const String mockPatientId = 'mock_patient_001';

  static const Map<String, _MockDoctorSummary> _doctors = {
    'doctor_ali': _MockDoctorSummary(
      name: 'Dr. Ali Raza',
      specialty: 'Cardiologist',
      imageAsset: 'assets/images/doctor_ali.png',
    ),
    'doctor_sara': _MockDoctorSummary(
      name: 'Dr. Sara Khan',
      specialty: 'General Physician',
      imageAsset: 'assets/images/doctor_sara.png',
    ),
    'doctor_maheen': _MockDoctorSummary(
      name: 'Dr. Maheen Fatima',
      specialty: 'Gynecologist',
      imageAsset: 'assets/images/doctor_maheen.png',
    ),
  };

  final List<AppointmentRecord> _appointments;

  Future<AppointmentRecord> bookAppointment({
    required String patientId,
    required String doctorId,
    required ConsultationType consultationType,
    required DateTime appointmentDate,
    required String dateLabel,
    required String timeLabel,
    required int totalFee,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    final cleanPatientId = patientId.trim();
    final cleanDoctorId = doctorId.trim();

    if (cleanPatientId.isEmpty) {
      throw const AppointmentException('Patient session is required.');
    }

    if (cleanDoctorId.isEmpty) {
      throw const AppointmentException('Doctor is required.');
    }

    if (dateLabel.trim().isEmpty || timeLabel.trim().isEmpty) {
      throw const AppointmentException('Date and time are required.');
    }

    if (totalFee <= 0) {
      throw const AppointmentException('A valid consultation fee is required.');
    }

    final doctor =
        _doctors[cleanDoctorId] ??
        const _MockDoctorSummary(
          name: 'AsaanCare Doctor',
          specialty: 'Medical Specialist',
          imageAsset: 'assets/images/doctor_appointment.png',
        );

    final createdAt = DateTime.now();
    final appointment = AppointmentRecord(
      id: _appointmentId(appointmentDate, createdAt),
      patientId: cleanPatientId,
      doctorId: cleanDoctorId,
      doctorName: doctor.name,
      doctorSpecialty: doctor.specialty,
      doctorImageAsset: doctor.imageAsset,
      consultationType: consultationType,
      appointmentDate: appointmentDate,
      dateLabel: dateLabel.trim(),
      timeLabel: timeLabel.trim(),
      totalFee: totalFee,
      status: AppointmentStatus.confirmed,
      createdAt: createdAt,
    );

    _appointments.insert(0, appointment);
    return appointment;
  }

  Future<List<AppointmentRecord>> getAppointments({
    required String patientId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final cleanPatientId = patientId.trim();

    if (cleanPatientId.isEmpty) {
      throw const AppointmentException('Patient session is required.');
    }

    final result =
        _appointments
            .where((appointment) => appointment.patientId == cleanPatientId)
            .toList(growable: false)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return List<AppointmentRecord>.unmodifiable(result);
  }
}

List<AppointmentRecord> _joinableTestAppointments() {
  final now = DateTime.now();
  final appointmentDate = DateTime(now.year, now.month, now.day);
  final timeLabel = _timeLabel(now);
  final dateLabel = _dateLabel(appointmentDate);

  return [
    AppointmentRecord(
      id: 'AC-TEST-VIDEO',
      patientId: AppointmentMockDataSource.mockPatientId,
      doctorId: 'doctor_sara',
      doctorName: 'Dr. Sara Khan',
      doctorSpecialty: 'General Physician',
      doctorImageAsset: 'assets/images/doctor_sara.png',
      consultationType: ConsultationType.video,
      appointmentDate: appointmentDate,
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      totalFee: 800,
      status: AppointmentStatus.confirmed,
      createdAt: now,
    ),
    AppointmentRecord(
      id: 'AC-TEST-AUDIO',
      patientId: AppointmentMockDataSource.mockPatientId,
      doctorId: 'doctor_ali',
      doctorName: 'Dr. Ali Raza',
      doctorSpecialty: 'Cardiologist',
      doctorImageAsset: 'assets/images/doctor_ali.png',
      consultationType: ConsultationType.audio,
      appointmentDate: appointmentDate,
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      totalFee: 1000,
      status: AppointmentStatus.confirmed,
      createdAt: now.subtract(const Duration(seconds: 1)),
    ),
    AppointmentRecord(
      id: 'AC-TEST-CHAT',
      patientId: AppointmentMockDataSource.mockPatientId,
      doctorId: 'doctor_maheen',
      doctorName: 'Dr. Maheen Fatima',
      doctorSpecialty: 'Gynecologist',
      doctorImageAsset: 'assets/images/doctor_maheen.png',
      consultationType: ConsultationType.chat,
      appointmentDate: appointmentDate,
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      totalFee: 900,
      status: AppointmentStatus.confirmed,
      createdAt: now.subtract(const Duration(seconds: 2)),
    ),
  ];
}

String _timeLabel(DateTime dateTime) {
  final hour = dateTime.hour == 0
      ? 12
      : dateTime.hour > 12
      ? dateTime.hour - 12
      : dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

String _dateLabel(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _appointmentId(DateTime appointmentDate, DateTime createdAt) {
  final year = (appointmentDate.year % 100).toString().padLeft(2, '0');
  final month = appointmentDate.month.toString().padLeft(2, '0');
  final day = appointmentDate.day.toString().padLeft(2, '0');
  final sequence = (createdAt.microsecondsSinceEpoch % 10000)
      .toString()
      .padLeft(4, '0');
  return 'AC-$year$month$day-$sequence';
}

class _MockDoctorSummary {
  const _MockDoctorSummary({
    required this.name,
    required this.specialty,
    required this.imageAsset,
  });

  final String name;
  final String specialty;
  final String imageAsset;
}
