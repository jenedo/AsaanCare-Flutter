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
  });

  final String id;
  final DoctorPatientSummary patient;
  final DoctorConsultationType type;
  final DoctorAppointmentStatus status;
  final DateTime scheduledAt;
  final DateTime requestedAt;
  final int durationMinutes;
  final int feePkr;

  DoctorAppointmentRecord copyWith({DoctorAppointmentStatus? status}) {
    return DoctorAppointmentRecord(
      id: id,
      patient: patient,
      type: type,
      status: status ?? this.status,
      scheduledAt: scheduledAt,
      requestedAt: requestedAt,
      durationMinutes: durationMinutes,
      feePkr: feePkr,
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
    List<DoctorAppointmentRecord>? appointments,
    int? unreadNotifications,
  }) {
    return DoctorDashboardSnapshot(
      profile: profile,
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
