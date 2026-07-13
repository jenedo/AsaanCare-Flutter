import 'package:flutter/material.dart';

import '../../../appointments/domain/entities/consultation_type.dart';
import '../../../appointments/presentation/controllers/appointment_booking_controller.dart';
import '../../../../screens/booking/slot_selection_screen.dart';
import '../../../../screens/booking/payment_screen.dart';
import '../../domain/entities/doctor.dart';
import '../controllers/doctor_detail_controller.dart';
import '../widgets/doctor_detail_widgets.dart';

class DoctorDetailScreen extends StatefulWidget {
  const DoctorDetailScreen({
    super.key,
    this.patientId = AppointmentBookingController.defaultPatientId,
    required this.doctorId,
    required this.doctorDetailController,
    required this.bookingController,
  });

  final String patientId;
  final String doctorId;
  final DoctorDetailController doctorDetailController;
  final AppointmentBookingController bookingController;

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    widget.doctorDetailController.addListener(_refresh);
    widget.bookingController.addListener(_refresh);
    widget.doctorDetailController.loadDoctor(widget.doctorId);
  }

  @override
  void dispose() {
    widget.doctorDetailController.removeListener(_refresh);
    widget.bookingController.removeListener(_refresh);
    widget.doctorDetailController.dispose();
    widget.bookingController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _openBooking(Doctor doctor) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SlotSelectionScreen(
          doctor: doctor,
          bookingController: widget.bookingController,
          onContinue: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => PaymentScreen(
                  doctorName: doctor.name,
                  speciality: doctor.specialty,
                  dateTime:
                      '${widget.bookingController.selectedDate.label}, '
                      '${widget.bookingController.selectedTime}',
                  consultationType:
                      widget.bookingController.selectedConsultationType.title,
                  amount: doctor.consultationFee.toDouble(),
                  onConfirmBooking: () async {
                    final success = await widget.bookingController.book(
                      patientId: widget.patientId,
                      doctorId: doctor.id,
                      totalFee: doctor.consultationFee,
                    );
                    return success
                        ? null
                        : widget.bookingController.errorMessage ??
                              'Booking failed. Try again.';
                  },
                  confirmedAppointmentId: () =>
                      widget.bookingController.lastBookedAppointment?.id ??
                      'Appointment confirmed',
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.doctorDetailController;
    final doctor = controller.doctor;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F8),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: controller.isLoading && doctor == null
                ? const Center(child: CircularProgressIndicator())
                : doctor == null
                ? DoctorDetailErrorState(
                    message: controller.errorMessage ?? 'Doctor not found.',
                    onRetry: () => controller.loadDoctor(widget.doctorId),
                  )
                : DoctorProfileBody(
                    doctor: doctor,
                    isFavorite: controller.isFavorite,
                    selectedTab: _selectedTab,
                    selectedMode:
                        widget.bookingController.selectedConsultationType,
                    isBooking: widget.bookingController.isBooking,
                    onBack: () => Navigator.of(context).pop(),
                    onFavorite: controller.toggleFavorite,
                    onShare: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile link copied.')),
                    ),
                    onTabSelected: (index) =>
                        setState(() => _selectedTab = index),
                    onModeSelected:
                        widget.bookingController.selectConsultationType,
                    onBook: () => _openBooking(doctor),
                  ),
          ),
        ),
      ),
    );
  }
}
