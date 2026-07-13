import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'booking_confirmed_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.doctorName,
    required this.speciality,
    required this.dateTime,
    required this.consultationType,
    required this.amount,
    required this.onConfirmBooking,
    required this.confirmedAppointmentId,
  });

  final String doctorName;
  final String speciality;
  final String dateTime;
  final String consultationType;
  final double amount;
  final Future<String?> Function() onConfirmBooking;
  final String Function() confirmedAppointmentId;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const _primary = Color(0xFF00796B);
  String _selectedMethod = 'jazzcash';
  bool _isConfirming = false;

  static const _methods = [
    _PaymentOption(
      id: 'jazzcash',
      name: 'JazzCash',
      subtitle: '0300 1234567',
      icon: Icons.account_balance_wallet_rounded,
      iconColor: Color(0xFFE91E63),
    ),
    _PaymentOption(
      id: 'easypaisa',
      name: 'Easypaisa',
      subtitle: '0300 1234567',
      icon: Icons.currency_rupee_rounded,
      iconColor: Color(0xFF4CAF50),
    ),
    _PaymentOption(
      id: 'card',
      name: 'Credit / Debit Card',
      subtitle: '**** **** **** 1234',
      icon: Icons.credit_card_rounded,
      iconColor: Color(0xFF1565C0),
    ),
    _PaymentOption(
      id: 'bank',
      name: 'Bank Transfer',
      icon: Icons.account_balance_rounded,
      iconColor: Color(0xFF607D8B),
    ),
  ];

  String get _amountLabel {
    if (widget.amount == widget.amount.roundToDouble()) {
      return widget.amount.toStringAsFixed(0);
    }
    return widget.amount.toStringAsFixed(2);
  }

  Future<void> _pay() async {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);
    final errorMessage = await widget.onConfirmBooking();
    if (!mounted) return;
    setState(() => _isConfirming = false);
    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => BookingConfirmedScreen(
          doctorName: widget.doctorName,
          speciality: widget.speciality,
          appointmentDateTime: widget.dateTime,
          appointmentId: widget.confirmedAppointmentId(),
          amount: widget.amount,
          consultationType: widget.consultationType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Color(0xFF162A32),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'More payment options',
            icon: const Icon(Icons.more_horiz_rounded, color: Colors.black),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE6ECEC)),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ConsultationSummary(
                          doctorName: widget.doctorName,
                          speciality: widget.speciality,
                          dateTime: widget.dateTime,
                          consultationType: widget.consultationType,
                          amountLabel: _amountLabel,
                        )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: -0.1, end: 0),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 6, 16, 8),
                      child: Text(
                        'Payment Methods',
                        style: TextStyle(
                          color: Color(0xFF162A32),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    ...List.generate(_methods.length, (index) {
                      final method = _methods[index];
                      return _PaymentMethodCard(
                            method: method,
                            selected: _selectedMethod == method.id,
                            onTap: () =>
                                setState(() => _selectedMethod = method.id),
                          )
                          .animate(delay: (index * 80).ms)
                          .fadeIn(duration: 250.ms)
                          .slideX(begin: 0.05, end: 0);
                    }),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 14,
                            color: Color(0xFF849195),
                          ),
                          SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Your payment is secured with 256-bit SSL encryption.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF849195),
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isConfirming ? null : _pay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isConfirming
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.4,
                          ),
                        )
                      : Text(
                          'Pay Rs. $_amountLabel',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ).animate(delay: 400.ms).fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}

class _ConsultationSummary extends StatelessWidget {
  const _ConsultationSummary({
    required this.doctorName,
    required this.speciality,
    required this.dateTime,
    required this.consultationType,
    required this.amountLabel,
  });

  final String doctorName;
  final String speciality;
  final String dateTime;
  final String consultationType;
  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFE0F2F1),
            child: Icon(Icons.person, color: Color(0xFF00796B), size: 28),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  speciality,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  dateTime,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  consultationType,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Rs. $amountLabel',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final _PaymentOption method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE0F2F1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? const Color(0xFF00796B)
                    : const Color(0xFFE4E9E9),
                width: selected ? 1.5 : 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: method.iconColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(method.icon, color: Colors.white, size: 23),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (method.subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          method.subtitle!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 22,
                  width: 22,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF00796B)
                          : const Color(0xFFB8C5C7),
                      width: selected ? 2 : 1.5,
                    ),
                  ),
                  child: selected
                      ? const DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFF00796B),
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentOption {
  const _PaymentOption({
    required this.id,
    required this.name,
    this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  final String id;
  final String name;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
}
