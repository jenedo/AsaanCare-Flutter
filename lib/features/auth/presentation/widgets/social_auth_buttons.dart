import 'package:flutter/material.dart';

import '../../../../core/design/app_motion.dart';
import '../../../../core/theme/app_theme.dart';

enum SocialAuthProvider { google, github, linkedin, facebook }

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({
    super.key,
    required this.onProviderSelected,
    this.enabled = true,
  });

  final ValueChanged<SocialAuthProvider> onProviderSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider(color: AppTheme.border)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or continue with',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppTheme.border)),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: SocialAuthProvider.values
              .map(
                (provider) => _SocialIconButton(
                  provider: provider,
                  onPressed: enabled
                      ? () => onProviderSelected(provider)
                      : null,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _SocialIconButton extends StatefulWidget {
  const _SocialIconButton({required this.provider, required this.onPressed});

  final SocialAuthProvider provider;
  final VoidCallback? onPressed;

  @override
  State<_SocialIconButton> createState() => _SocialIconButtonState();
}

class _SocialIconButtonState extends State<_SocialIconButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final scale = !enabled ? 1.0 : (_pressed ? 0.96 : (_hovered ? 1.08 : 1.0));

    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Continue with ${_providerName(widget.provider)}',
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: enabled ? (_) => setState(() => _hovered = true) : null,
        onExit: enabled ? (_) => setState(() => _hovered = false) : null,
        child: AnimatedScale(
          scale: scale,
          duration: AppMotion.fast,
          curve: Curves.easeOutCubic,
          child: Listener(
            onPointerDown: enabled
                ? (_) => setState(() => _pressed = true)
                : null,
            onPointerUp: enabled
                ? (_) => setState(() => _pressed = false)
                : null,
            onPointerCancel: enabled
                ? (_) => setState(() => _pressed = false)
                : null,
            child: SizedBox.square(
              dimension: 48,
              child: OutlinedButton(
                onPressed: widget.onPressed,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.square(48),
                  padding: EdgeInsets.zero,
                  backgroundColor: AppTheme.surface,
                  foregroundColor: AppTheme.textDark,
                  side: const BorderSide(color: AppTheme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                ),
                child: ExcludeSemantics(
                  child: _ProviderMark(provider: widget.provider),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProviderMark extends StatelessWidget {
  const _ProviderMark({required this.provider});

  final SocialAuthProvider provider;

  @override
  Widget build(BuildContext context) {
    return switch (provider) {
      SocialAuthProvider.google => const Text(
        'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      SocialAuthProvider.github => const Icon(Icons.code_rounded, size: 23),
      SocialAuthProvider.linkedin => _letterMark(
        text: 'in',
        color: const Color(0xFF0A66C2),
      ),
      SocialAuthProvider.facebook => _letterMark(
        text: 'f',
        color: const Color(0xFF1877F2),
      ),
    };
  }

  Widget _letterMark({required String text, required Color color}) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _providerName(SocialAuthProvider provider) => switch (provider) {
  SocialAuthProvider.google => 'Google',
  SocialAuthProvider.github => 'GitHub',
  SocialAuthProvider.linkedin => 'LinkedIn',
  SocialAuthProvider.facebook => 'Facebook',
};
