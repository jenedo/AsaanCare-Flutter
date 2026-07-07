import 'package:flutter/foundation.dart';

import '../../data/datasources/appointment_mock_data_source.dart';
import '../../domain/entities/appointment_slot.dart';
import '../../domain/entities/consultation_type.dart';
import '../../domain/usecases/book_appointment.dart';

class AppointmentBookingController extends ChangeNotifier {
  AppointmentBookingController({required this._bookAppointment});

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

  Future<bool> book({required String doctorId, required int totalFee}) async {
    _setBooking(true);

    try {
      await _bookAppointment(
        doctorId: doctorId,
        consultationType: _selectedConsultationType,
        dateLabel: selectedDate.label,
        timeLabel: selectedTime,
        totalFee: totalFee,
      );

      _errorMessage = null;
      return true;
    } on AppointmentDataException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
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
