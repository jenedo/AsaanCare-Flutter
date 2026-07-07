class AppointmentSlot {
  const AppointmentSlot({
    required this.day,
    required this.date,
    required this.month,
  });

  final String day;
  final String date;
  final String month;

  String get label => '$day $date $month';
}
