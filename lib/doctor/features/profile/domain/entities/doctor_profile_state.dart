class DoctorProfileState {
  const DoctorProfileState({
    this.page = 0,
    this.name = 'Dr. Ali Raza',
    this.specialty = 'General Physician',
    this.qualification = 'MBBS, FCPS',
    this.clinic = 'City Care Hospital',
    this.address = 'Gulberg, Lahore',
    this.fee = 2000,
    this.days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    this.autoApprove = false,
    this.reschedule = true,
    this.video = true,
    this.recordingConsent = false,
    this.phone = '+92 300 1234567',
    this.email = 'dr.aliraza@example.com',
    this.language = 'English',
    this.appearance = 'System default',
    this.bank = 'HBL - **** 4281',
    this.push = true,
    this.sms = false,
    this.twoFactor = true,
    this.public = true,
  });

  final int page;
  final String name;
  final String specialty;
  final String qualification;
  final String clinic;
  final String address;
  final int fee;
  final List<String> days;
  final bool autoApprove;
  final bool reschedule;
  final bool video;
  final bool recordingConsent;
  final String phone;
  final String email;
  final String language;
  final String appearance;
  final String bank;
  final bool push;
  final bool sms;
  final bool twoFactor;
  final bool public;

  DoctorProfileState copyWith({
    int? page,
    String? name,
    String? specialty,
    String? qualification,
    String? clinic,
    String? address,
    int? fee,
    List<String>? days,
    bool? autoApprove,
    bool? reschedule,
    bool? video,
    bool? recordingConsent,
    String? phone,
    String? email,
    String? language,
    String? appearance,
    String? bank,
    bool? push,
    bool? sms,
    bool? twoFactor,
    bool? public,
  }) {
    return DoctorProfileState(
      page: page ?? this.page,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      qualification: qualification ?? this.qualification,
      clinic: clinic ?? this.clinic,
      address: address ?? this.address,
      fee: fee ?? this.fee,
      days: days ?? this.days,
      autoApprove: autoApprove ?? this.autoApprove,
      reschedule: reschedule ?? this.reschedule,
      video: video ?? this.video,
      recordingConsent: recordingConsent ?? this.recordingConsent,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      language: language ?? this.language,
      appearance: appearance ?? this.appearance,
      bank: bank ?? this.bank,
      push: push ?? this.push,
      sms: sms ?? this.sms,
      twoFactor: twoFactor ?? this.twoFactor,
      public: public ?? this.public,
    );
  }
}
