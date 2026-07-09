import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class CheckoutValidationBanner extends StatelessWidget {
  const CheckoutValidationBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFFD89B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFB76A00)),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF7A4B00),
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutInformationCard extends StatelessWidget {
  const CheckoutInformationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.softTeal,
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF07132D),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF657386),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onAction, child: Text(actionText)),
        ],
      ),
    );
  }
}

class CheckoutSummaryRow extends StatelessWidget {
  const CheckoutSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final int value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final valueText = value < 0 ? '-Rs. ${value.abs()}' : 'Rs. $value';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFF536078),
                fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            valueText,
            style: TextStyle(
              color: const Color(0xFF07132D),
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutSectionTitle extends StatelessWidget {
  const CheckoutSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF07132D),
        fontSize: 19,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
