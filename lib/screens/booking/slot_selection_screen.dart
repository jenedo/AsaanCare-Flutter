import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../features/appointments/domain/entities/consultation_type.dart';
import '../../features/appointments/presentation/controllers/appointment_booking_controller.dart';
import '../../features/doctors/domain/entities/doctor.dart';
import '../../widgets/booking/step_indicator.dart';

class SlotSelectionScreen extends StatelessWidget {
  const SlotSelectionScreen({
    super.key,
    required this.doctor,
    required this.bookingController,
    required this.onContinue,
  });

  final Doctor doctor;
  final AppointmentBookingController bookingController;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: bookingController,
          builder: (context, _) {
            final bookingDates = bookingController.bookingDates;
            if (bookingDates.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            final firstDate = bookingDates.first;
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BookingStepIndicator(activeStep: 1),
                        const SizedBox(height: 25),
                        const _SectionTitle('Selected Doctor'),
                        const SizedBox(height: 10),
                        _DoctorCard(
                          doctor: doctor,
                          consultationType:
                              bookingController.selectedConsultationType,
                        ),
                        const SizedBox(height: 24),
                        const _SectionTitle('Select Date'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            IconButton(
                              onPressed:
                                  bookingController.canShowPreviousBookingWeek
                                  ? bookingController.showPreviousBookingWeek
                                  : null,
                              tooltip: 'Show previous 7 days',
                              visualDensity: VisualDensity.compact,
                              color: const Color(0xFF70848B),
                              disabledColor: const Color(0xFFC7D0D2),
                              icon: const Icon(
                                Icons.chevron_left_rounded,
                                size: 22,
                              ),
                            ),
                            Text(
                              '${_monthName(firstDate.month)} ${firstDate.year}',
                              style: const TextStyle(
                                color: Color(0xFF23363E),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: bookingController.showNextBookingWeek,
                              tooltip: 'Show next 7 days',
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF70848B),
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _DateStrip(controller: bookingController),
                        const SizedBox(height: 24),
                        const _SectionTitle('Select Time'),
                        const SizedBox(height: 12),
                        _TimeGrid(controller: bookingController),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                  child: FilledButton(
                    onPressed: onContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00796B),
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor, required this.consultationType});
  final Doctor doctor;
  final ConsultationType consultationType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5ECEC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0A5E58),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.softTeal,
            backgroundImage: AssetImage(doctor.imageAsset),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  doctor.specialty,
                  style: const TextStyle(
                    color: Color(0xFF607078),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs. ${doctor.consultationFee}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                consultationType.title,
                style: const TextStyle(
                  color: Color(0xFF00796B),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.controller});
  final AppointmentBookingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(controller.bookingDates.length, (index) {
        final date = controller.bookingDates[index];
        final selected = controller.selectedDateIndex == index;
        return Expanded(
          child: InkWell(
            onTap: () => controller.selectDate(index),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                Text(
                  _weekday(date.weekday),
                  style: const TextStyle(
                    color: Color(0xFF607078),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 34,
                  width: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF00796B) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF00796B)
                          : index == 0
                          ? const Color(0xFF00796B)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF1D3038),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _TimeGrid extends StatelessWidget {
  const _TimeGrid({required this.controller});
  final AppointmentBookingController controller;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.timeSlots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.7,
      ),
      itemBuilder: (context, index) {
        final selected = controller.selectedTimeIndex == index;
        final booked = index == 2;
        return InkWell(
          onTap: booked ? null : () => controller.selectTime(index),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: booked
                  ? const Color(0xFFF0F2F2)
                  : selected
                  ? const Color(0xFF00796B)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: booked
                    ? const Color(0xFFDDE2E2)
                    : const Color(0xFF8DCBC4),
              ),
            ),
            child: Text(
              controller.timeSlots[index],
              style: TextStyle(
                color: booked
                    ? const Color(0xFF9AA5A7)
                    : selected
                    ? Colors.white
                    : const Color(0xFF00796B),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                decoration: booked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Color(0xFF1A2E36),
      fontSize: 14,
      fontWeight: FontWeight.w800,
    ),
  );
}

String _weekday(int weekday) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[weekday - 1];
}

String _monthName(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[month - 1];
}
