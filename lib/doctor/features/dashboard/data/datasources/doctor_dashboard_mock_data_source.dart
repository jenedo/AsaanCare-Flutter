import '../../domain/entities/doctor_dashboard_snapshot.dart';

class DoctorDashboardMockDataSource {
  DoctorDashboardMockDataSource({
    this.loadDelay = const Duration(milliseconds: 180),
    this.actionDelay = const Duration(milliseconds: 260),
  });

  final Duration loadDelay;
  final Duration actionDelay;
  final Map<String, DoctorDashboardSnapshot> _snapshots = {};

  Future<DoctorDashboardSnapshot> getDashboard({
    required String doctorId,
  }) async {
    _validateDoctorId(doctorId);
    if (loadDelay > Duration.zero) {
      await Future<void>.delayed(loadDelay);
    }
    return _snapshots.putIfAbsent(doctorId, () => _seed(doctorId));
  }

  Future<DoctorDashboardSnapshot> updateAppointmentStatus({
    required String doctorId,
    required String appointmentId,
    required DoctorAppointmentStatus status,
  }) async {
    _validateDoctorId(doctorId);
    if (appointmentId.trim().isEmpty) {
      throw ArgumentError.value(appointmentId, 'appointmentId');
    }
    if (actionDelay > Duration.zero) {
      await Future<void>.delayed(actionDelay);
    }
    final current = _snapshots.putIfAbsent(doctorId, () => _seed(doctorId));
    var found = false;
    final updated = current.appointments
        .map((appointment) {
          if (appointment.id != appointmentId) return appointment;
          found = true;
          return appointment.copyWith(status: status);
        })
        .toList(growable: false);
    if (!found) throw StateError('Appointment was not found.');
    final snapshot = current.copyWith(appointments: updated);
    _snapshots[doctorId] = snapshot;
    return snapshot;
  }

  Future<DoctorDashboardSnapshot> updateAvailability({
    required String doctorId,
    required bool isOnline,
  }) async {
    _validateDoctorId(doctorId);
    if (actionDelay > Duration.zero) {
      await Future<void>.delayed(actionDelay);
    }
    final current = _snapshots.putIfAbsent(doctorId, () => _seed(doctorId));
    final snapshot = current.copyWith(
      profile: current.profile.copyWith(isOnline: isOnline),
    );
    _snapshots[doctorId] = snapshot;
    return snapshot;
  }

  void _validateDoctorId(String doctorId) {
    if (doctorId.trim().isEmpty) {
      throw ArgumentError.value(doctorId, 'doctorId');
    }
  }

  DoctorDashboardSnapshot _seed(String doctorId) {
    final now = DateTime.now();
    DateTime todayAt(int hour, int minute) =>
        DateTime(now.year, now.month, now.day, hour, minute);
    const ahmed = DoctorPatientSummary(
      id: 'patient-ahmed',
      name: 'Ahmed Hassan',
      age: 32,
      gender: 'Male',
      imageAsset: 'assets/images/doctor_ali.png',
      condition: 'Respiratory follow-up',
      visitCount: 5,
    );
    const fatima = DoctorPatientSummary(
      id: 'patient-fatima',
      name: 'Fatima Ali',
      age: 28,
      gender: 'Female',
      imageAsset: 'assets/images/doctor_sara.png',
      condition: 'General consultation',
      visitCount: 2,
    );
    const sara = DoctorPatientSummary(
      id: 'patient-sara',
      name: 'Sara Bibi',
      age: 39,
      gender: 'Female',
      imageAsset: 'assets/images/user_avatar.png',
      condition: 'In-clinic consultation',
      visitCount: 3,
    );
    const kamran = DoctorPatientSummary(
      id: 'patient-kamran',
      name: 'Kamran Zia',
      age: 45,
      gender: 'Male',
      imageAsset: 'assets/images/user_avatar.png',
      condition: 'Diabetes care plan',
      visitCount: 8,
    );

    return DoctorDashboardSnapshot(
      profile: DoctorProfileSummary(
        id: doctorId,
        name: 'Dr. Ali Raza',
        specialty: 'General Physician',
        imageAsset: 'assets/images/doctor_sara.png',
        isOnline: true,
      ),
      unreadNotifications: 3,
      appointments: [
        DoctorAppointmentRecord(
          id: 'request-ahmed',
          patient: ahmed,
          type: DoctorConsultationType.video,
          status: DoctorAppointmentStatus.pending,
          scheduledAt: todayAt(16, 0),
          requestedAt: now.subtract(const Duration(minutes: 10)),
          durationMinutes: 30,
          feePkr: 1500,
          paymentStatus: DoctorPaymentStatus.pending,
        ),
        DoctorAppointmentRecord(
          id: 'request-fatima',
          patient: fatima,
          type: DoctorConsultationType.audio,
          status: DoctorAppointmentStatus.pending,
          scheduledAt: todayAt(16, 30),
          requestedAt: now.subtract(const Duration(minutes: 25)),
          durationMinutes: 20,
          feePkr: 1000,
          paymentStatus: DoctorPaymentStatus.pending,
        ),
        DoctorAppointmentRecord(
          id: 'appointment-ahmed',
          patient: ahmed,
          type: DoctorConsultationType.video,
          status: DoctorAppointmentStatus.ready,
          scheduledAt: todayAt(10, 30),
          requestedAt: now.subtract(const Duration(days: 2)),
          durationMinutes: 30,
          feePkr: 1500,
          paymentStatus: DoctorPaymentStatus.confirmed,
        ),
        DoctorAppointmentRecord(
          id: 'appointment-sara',
          patient: sara,
          type: DoctorConsultationType.clinic,
          status: DoctorAppointmentStatus.inProgress,
          scheduledAt: todayAt(12, 0),
          requestedAt: now.subtract(const Duration(days: 3)),
          durationMinutes: 30,
          feePkr: 2000,
          paymentStatus: DoctorPaymentStatus.confirmed,
        ),
        DoctorAppointmentRecord(
          id: 'appointment-kamran',
          patient: kamran,
          type: DoctorConsultationType.video,
          status: DoctorAppointmentStatus.confirmed,
          scheduledAt: todayAt(14, 30),
          requestedAt: now.subtract(const Duration(days: 1)),
          durationMinutes: 30,
          feePkr: 1500,
          paymentStatus: DoctorPaymentStatus.failed,
        ),
        DoctorAppointmentRecord(
          id: 'appointment-completed',
          patient: fatima,
          type: DoctorConsultationType.video,
          status: DoctorAppointmentStatus.completed,
          scheduledAt: todayAt(9, 0),
          requestedAt: now.subtract(const Duration(days: 5)),
          durationMinutes: 20,
          feePkr: 1200,
          paymentStatus: DoctorPaymentStatus.confirmed,
        ),
      ],
    );
  }
}
