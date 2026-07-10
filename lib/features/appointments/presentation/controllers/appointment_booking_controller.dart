// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/appointment_slot.dart';
import '../../domain/entities/consultation_type.dart';
import '../../domain/exceptions/appointment_exception.dart';
import '../../domain/usecases/book_appointment.dart';

class AppointmentBookingController extends ChangeNotifier {
  AppointmentBookingController({required BookAppointment bookAppointment})
    : _bookAppointment = bookAppointment;

  static const String defaultPatientId = BookAppointment.defaultMockPatientId;

  final BookAppointment _bookAppointment;

  final List<AppointmentSlot> dateSlots = const [
    AppointmentSlot(day: 'Sun', date: '18', month: 'May'),
    AppointmentSlot(day: 'Mon', date: '19', month: 'May'),
    AppointmentSlot(day: 'Tue', date: '20', month: 'May'),
    AppointmentSlot(day: 'Wed', date: '21', month: 'May'),
    AppointmentSlot(day: 'Thu', date: '22', month: 'May'),
  ];

  final List<String> timeSlots = const [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
  ];

  ConsultationType _selectedConsultationType = ConsultationType.video;
  int _selectedDateIndex = 1;
  int _selectedTimeIndex = 1;
  bool _isBooking = false;
  String? _errorMessage;

  ConsultationType get selectedConsultationType => _selectedConsultationType;

  int get selectedDateIndex => _selectedDateIndex;
  int get selectedTimeIndex => _selectedTimeIndex;
  bool get isBooking => _isBooking;
  String? get errorMessage => _errorMessage;

  AppointmentSlot get selectedDate => dateSlots[_selectedDateIndex];
  String get selectedTime => timeSlots[_selectedTimeIndex];

  void selectConsultationType(ConsultationType value) {
    _selectedConsultationType = value;
    notifyListeners();
  }

  void selectDate(int index) {
    _selectedDateIndex = index;
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

    try {
      await _bookAppointment(
        patientId: patientId,
        doctorId: doctorId,
        consultationType: _selectedConsultationType,
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
