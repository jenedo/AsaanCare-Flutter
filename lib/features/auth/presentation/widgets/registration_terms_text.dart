import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class RegistrationTermsText extends StatelessWidget {
  const RegistrationTermsText({super.key});

  @override
  Widget build(BuildContext context) {
    void showPendingRoute(String label) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label route is not configured yet.')),
      );
    }

    const style = TextStyle(color: AppTheme.textLight, fontSize: 14);
    final linkStyle = TextButton.styleFrom(
      foregroundColor: AppTheme.textLight,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      minimumSize: const Size(44, 44),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: const TextStyle(
        fontSize: 14,
        decoration: TextDecoration.underline,
        decorationColor: AppTheme.textLight,
      ),
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'By clicking "Next", I have read and agree with the ',
          textAlign: TextAlign.center,
          style: style,
        ),
        TextButton(
          onPressed: () => showPendingRoute('Term Sheet'),
          style: linkStyle,
          child: const Text('Term Sheet'),
        ),
        const Text(',', style: style),
        TextButton(
          onPressed: () => showPendingRoute('Privacy Policy'),
          style: linkStyle,
          child: const Text('Privacy Policy'),
        ),
      ],
    );
  }
}
