// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/appointment_record.dart';
import '../../domain/entities/appointment_slot.dart';
import '../../domain/entities/consultation_type.dart';
import '../../domain/exceptions/appointment_exception.dart';
import '../../domain/usecases/book_appointment.dart';

class AppointmentBookingController extends ChangeNotifier {
  factory AppointmentBookingController({
    required BookAppointment bookAppointment,
  }) {
    final now = DateTime.now();
    final bookingDates = _upcomingDates(now);
    return AppointmentBookingController._(bookAppointment, bookingDates);
  }

  AppointmentBookingController._(
    this._bookAppointment,
    List<DateTime> bookingDates,
  ) : _bookingDates = bookingDates,
      _dateSlots = bookingDates
          .map(_appointmentSlotFor)
          .toList(growable: false);

  static const String defaultPatientId = BookAppointment.defaultMockPatientId;

  final BookAppointment _bookAppointment;

  List<DateTime>? _bookingDates = const [];
  List<AppointmentSlot>? _dateSlots = const [];

  final List<String> timeSlots = const [
    '10:30 AM',
    '12:00 PM',
    '03:00 PM',
    '04:30 PM',
    '06:00 PM',
    '08:30 PM',
  ];

  ConsultationType _selectedConsultationType = ConsultationType.video;
  int _selectedDateIndex = 1;
  int _selectedTimeIndex = 1;
  bool _isBooking = false;
  String? _errorMessage;
  AppointmentRecord? _lastBookedAppointment;

  ConsultationType get selectedConsultationType => _selectedConsultationType;

  List<DateTime> get bookingDates {
    final dates = _bookingDates;
    if (dates == null || dates.isEmpty) {
      return _bookingDates = _upcomingDates(DateTime.now());
    }
    return dates;
  }

  List<AppointmentSlot> get dateSlots {
    final slots = _dateSlots;
    if (slots == null || slots.isEmpty) {
      return _dateSlots = bookingDates
          .map(_appointmentSlotFor)
          .toList(growable: false);
    }
    return slots;
  }

  int get selectedDateIndex => _selectedDateIndex;
  int get selectedTimeIndex => _selectedTimeIndex;
  bool get isBooking => _isBooking;
  String? get errorMessage => _errorMessage;
  AppointmentRecord? get lastBookedAppointment => _lastBookedAppointment;

  AppointmentSlot get selectedDate => dateSlots[_selectedDateIndex];
  DateTime get selectedBookingDate => bookingDates[_selectedDateIndex];
  String get selectedTime => timeSlots[_selectedTimeIndex];

  void selectConsultationType(ConsultationType value) {
    _selectedConsultationType = value;
    notifyListeners();
  }

  void selectDate(int index) {
    _selectedDateIndex = index;
    notifyListeners();
  }

  void showNextBookingWeek() {
    final nextWeekStart = bookingDates.first.add(const Duration(days: 7));
    _showBookingWeekStarting(nextWeekStart);
  }

  bool get canShowPreviousBookingWeek {
    final today = DateTime.now();
    final currentDay = DateTime(today.year, today.month, today.day);
    return bookingDates.first.isAfter(currentDay);
  }

  void showPreviousBookingWeek() {
    if (!canShowPreviousBookingWeek) return;
    final previousWeekStart = bookingDates.first.subtract(
      const Duration(days: 7),
    );
    _showBookingWeekStarting(previousWeekStart);
  }

  void _showBookingWeekStarting(DateTime startDate) {
    _bookingDates = _upcomingDates(startDate);
    _dateSlots = bookingDates.map(_appointmentSlotFor).toList(growable: false);
    _selectedDateIndex = 0;
    notifyListeners();
  }

  void selectTime(int index) {
    _selectedTimeIndex = index;
    notifyListeners();
  }

  Future<bool> book({
    String patientId = defaultPatientId,
    required String doctorId,
    required int totalFee,
  }) async {
    _setBooking(true);
    _lastBookedAppointment = null;

    try {
      _lastBookedAppointment = await _bookAppointment(
        patientId: patientId,
        doctorId: doctorId,
        consultationType: _selectedConsultationType,
        appointmentDate: selectedBookingDate,
        dateLabel: selectedDate.label,
        timeLabel: selectedTime,
        totalFee: totalFee,
      );

      _errorMessage = null;
      return true;
    } on AppointmentException catch (error, stackTrace) {
      AppLogger.error('AppointmentBookingController.book', error, stackTrace);
      _errorMessage = error.message;
      return false;
    } catch (error, stackTrace) {
      AppLogger.error('AppointmentBookingController.book', error, stackTrace);
      _errorMessage = 'Booking failed. Try again.';
      return false;
    } finally {
      _setBooking(false);
    }
  }

  void _setBooking(bool value) {
    _isBooking = value;
    notifyListeners();
  }
}

List<DateTime> _upcomingDates(DateTime now) {
  return List.generate(
    7,
    (index) => DateTime(now.year, now.month, now.day + index),
    growable: false,
  );
}

AppointmentSlot _appointmentSlotFor(DateTime date) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
  return AppointmentSlot(
    day: weekdays[date.weekday - 1],
    date: date.day.toString(),
    month: months[date.month - 1],
  );
}
