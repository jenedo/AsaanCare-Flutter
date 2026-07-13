import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/routes/app_routes.dart';

class BookingConfirmedScreen extends StatelessWidget {
  const BookingConfirmedScreen({
    super.key,
    required this.doctorName,
    required this.speciality,
    required this.appointmentDateTime,
    required this.appointmentId,
    required this.amount,
    required this.consultationType,
  });

  final String doctorName;
  final String speciality;
  final String appointmentDateTime;
  final String appointmentId;
  final double amount;
  final String consultationType;

  static const _primary = Color(0xFF00796B);

  String get _amountLabel => amount == amount.roundToDouble()
      ? amount.toStringAsFixed(0)
      : amount.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 34, 20, 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 54,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: _primary,
                        size: 44,
                      ),
                    ).animate().scale(
                      begin: Offset.zero,
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                          'Appointment Confirmed!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: .3,
                          ),
                        )
                        .animate(delay: 300.ms)
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: .2, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      'Your consultation has been booked successfully.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .85),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ).animate(delay: 400.ms).fadeIn(duration: 300.ms),
                    const SizedBox(height: 34),
                    _DetailsCard(
                          doctorName: doctorName,
                          speciality: speciality,
                          appointmentDateTime: appointmentDateTime,
                          appointmentId: appointmentId,
                          consultationType: consultationType,
                          amountLabel: _amountLabel,
                        )
                        .animate(delay: 500.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: .15, end: 0),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.appointments,
                              (route) => false,
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Go to Appointments',
                          style: TextStyle(
                            color: _primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ).animate(delay: 700.ms).fadeIn(duration: 300.ms),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.doctorName,
    required this.speciality,
    required this.appointmentDateTime,
    required this.appointmentId,
    required this.consultationType,
    required this.amountLabel,
  });

  final String doctorName;
  final String speciality;
  final String appointmentDateTime;
  final String appointmentId;
  final String consultationType;
  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFE0F2F1),
                child: Icon(
                  Icons.person_rounded,
                  color: BookingConfirmedScreen._primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      speciality,
                      style: const TextStyle(
                        color: Color(0xFF879194),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 26, color: Color(0xFFF0F2F2)),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            text: appointmentDateTime,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                _consultationIcon(consultationType),
                size: 18,
                color: const Color(0xFF879194),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  consultationType,
                  style: const TextStyle(
                    color: Color(0xFF697578),
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                'Rs. $amountLabel',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 26, color: Color(0xFFF0F2F2)),
          const Text(
            'Appointment ID',
            style: TextStyle(
              color: Color(0xFF9AA3A5),
              fontSize: 11,
              letterSpacing: .5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            appointmentId,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 16,
                  color: BookingConfirmedScreen._primary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'We will send you a reminder before your appointment.',
                    style: TextStyle(
                      color: Color(0xFF697578),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

IconData _consultationIcon(String consultationType) {
  final value = consultationType.toLowerCase();
  if (value.contains('audio')) return Icons.call_outlined;
  if (value.contains('chat')) return Icons.chat_bubble_outline_rounded;
  if (value.contains('clinic')) return Icons.local_hospital_outlined;
  return Icons.videocam_outlined;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF879194)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF697578), fontSize: 13),
          ),
        ),
      ],
    );
  }
}
