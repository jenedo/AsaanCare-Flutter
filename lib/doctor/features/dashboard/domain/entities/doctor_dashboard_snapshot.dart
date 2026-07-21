enum DoctorDashboardLoadStatus { initial, loading, ready, empty, failure }

enum DoctorAppointmentStatus {
  pending,
  confirmed,
  ready,
  inProgress,
  completed,
  cancelled,
}

enum DoctorAppointmentFilter { all, pending, completed }

enum DoctorConsultationType { video, audio, clinic }

/// Payment state for a consultation. Kept as a doctor-domain enum because no
/// shared patient/booking payment-status type exists yet; if one is later
/// introduced, both apps should converge on it rather than diverge.
enum DoctorPaymentStatus { confirmed, pending, failed }

class DoctorProfileSummary {
  const DoctorProfileSummary({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageAsset,
    required this.isOnline,
  });

  final String id;
  final String name;
  final String specialty;
  final String imageAsset;
  final bool isOnline;

  DoctorProfileSummary copyWith({bool? isOnline}) {
    return DoctorProfileSummary(
      id: id,
      name: name,
      specialty: specialty,
      imageAsset: imageAsset,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class DoctorPatientSummary {
  const DoctorPatientSummary({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.imageAsset,
    required this.condition,
    required this.visitCount,
  });

  final String id;
  final String name;
  final int age;
  final String gender;
  final String imageAsset;
  final String condition;
  final int visitCount;
}

class DoctorAppointmentRecord {
  const DoctorAppointmentRecord({
    required this.id,
    required this.patient,
    required this.type,
    required this.status,
    required this.scheduledAt,
    required this.requestedAt,
    required this.durationMinutes,
    required this.feePkr,
    required this.paymentStatus,
  });

  final String id;
  final DoctorPatientSummary patient;
  final DoctorConsultationType type;
  final DoctorAppointmentStatus status;
  final DateTime scheduledAt;
  final DateTime requestedAt;
  final int durationMinutes;
  final int feePkr;
  final DoctorPaymentStatus paymentStatus;

  DoctorAppointmentRecord copyWith({
    DoctorAppointmentStatus? status,
    DoctorPaymentStatus? paymentStatus,
  }) {
    return DoctorAppointmentRecord(
      id: id,
      patient: patient,
      type: type,
      status: status ?? this.status,
      scheduledAt: scheduledAt,
      requestedAt: requestedAt,
      durationMinutes: durationMinutes,
      feePkr: feePkr,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
}

class DoctorDashboardSnapshot {
  DoctorDashboardSnapshot({
    required this.profile,
    required List<DoctorAppointmentRecord> appointments,
    required this.unreadNotifications,
  }) : appointments = List<DoctorAppointmentRecord>.unmodifiable(appointments);

  final DoctorProfileSummary profile;
  final List<DoctorAppointmentRecord> appointments;
  final int unreadNotifications;

  DoctorDashboardSnapshot copyWith({
    DoctorProfileSummary? profile,
    List<DoctorAppointmentRecord>? appointments,
    int? unreadNotifications,
  }) {
    return DoctorDashboardSnapshot(
      profile: profile ?? this.profile,
      appointments: appointments ?? this.appointments,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
    );
  }
}

extension DoctorAppointmentStatusLabel on DoctorAppointmentStatus {
  String get label => switch (this) {
    DoctorAppointmentStatus.pending => 'Pending',
    DoctorAppointmentStatus.confirmed => 'Upcoming',
    DoctorAppointmentStatus.ready => 'Ready',
    DoctorAppointmentStatus.inProgress => 'In Progress',
    DoctorAppointmentStatus.completed => 'Completed',
    DoctorAppointmentStatus.cancelled => 'Cancelled',
  };
}

extension DoctorConsultationTypeLabel on DoctorConsultationType {
  String get label => switch (this) {
    DoctorConsultationType.video => 'Video Consultation',
    DoctorConsultationType.audio => 'Audio Consultation',
    DoctorConsultationType.clinic => 'Clinic Visit',
  };
}

extension DoctorPaymentStatusLabel on DoctorPaymentStatus {
  String get label => switch (this) {
    DoctorPaymentStatus.confirmed => 'Confirmed',
    DoctorPaymentStatus.pending => 'Pending',
    DoctorPaymentStatus.failed => 'Failed',
  };
}
