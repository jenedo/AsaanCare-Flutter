import 'package:flutter/material.dart';

class BookingStepIndicator extends StatelessWidget {
  const BookingStepIndicator({super.key, required this.activeStep});

  final int activeStep;

  static const _steps = [
    (Icons.person_rounded, 'Doctor'),
    (Icons.calendar_month_rounded, 'Slot'),
    (Icons.payments_rounded, 'Payment'),
    (Icons.check_rounded, 'Confirmed'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final completed = index ~/ 2 < activeStep;
          return Expanded(
            child: Container(
              height: 1.5,
              margin: const EdgeInsets.only(top: 17),
              color: completed
                  ? const Color(0xFF00796B)
                  : const Color(0xFFDCE5E5),
            ),
          );
        }
        final step = index ~/ 2;
        final active = step == activeStep;
        final completed = step < activeStep;
        return SizedBox(
          width: 55,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: active || completed
                      ? const Color(0xFF00796B)
                      : const Color(0xFFEAF0F0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _steps[step].$1,
                  size: 17,
                  color: active || completed
                      ? Colors.white
                      : const Color(0xFF90A1A5),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _steps[step].$2,
                style: TextStyle(
                  color: active
                      ? const Color(0xFF00796B)
                      : const Color(0xFF607178),
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
