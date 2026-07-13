enum ConsultationType { video, audio, chat, clinic }

extension ConsultationTypeX on ConsultationType {
  String get title {
    switch (this) {
      case ConsultationType.video:
        return 'Video Call';
      case ConsultationType.audio:
        return 'Audio Call';
      case ConsultationType.chat:
        return 'Chat Session';
      case ConsultationType.clinic:
        return 'Clinic Visit';
    }
  }

  String get subtitle {
    switch (this) {
      case ConsultationType.video:
        return 'Talk face to face';
      case ConsultationType.audio:
        return 'Talk over audio';
      case ConsultationType.chat:
        return 'Message the doctor';
      case ConsultationType.clinic:
        return 'Visit at the clinic';
    }
  }
}
