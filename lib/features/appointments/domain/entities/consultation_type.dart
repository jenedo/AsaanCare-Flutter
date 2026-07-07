enum ConsultationType { video, audio }

extension ConsultationTypeX on ConsultationType {
  String get title {
    switch (this) {
      case ConsultationType.video:
        return 'Video Call';
      case ConsultationType.audio:
        return 'Audio Call';
    }
  }

  String get subtitle {
    switch (this) {
      case ConsultationType.video:
        return 'Talk face to face';
      case ConsultationType.audio:
        return 'Talk over audio';
    }
  }
}
