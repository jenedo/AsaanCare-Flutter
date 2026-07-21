import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Authentication operation successful hone ke baad animated tick show karta hai.
///
/// Yeh account creation ya login success confirm karta hai.
/// Isko doctor ki manual PMDC approval claim karne ke liye use na karein.
class AuthVerificationOverlay extends StatefulWidget {
  const AuthVerificationOverlay({
    super.key,
    required this.visible,
    required this.title,
    required this.message,
    this.progressDuration = const Duration(milliseconds: 1700),
  });

  final bool visible;
  final String title;
  final String message;
  final Duration progressDuration;

  @override
  State<AuthVerificationOverlay> createState() =>
      _AuthVerificationOverlayState();
}

class _AuthVerificationOverlayState extends State<AuthVerificationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _progressController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: widget.progressDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.72, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );

    _checkAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 1, curve: Curves.easeOutBack),
    );

    if (widget.visible) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(covariant AuthVerificationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.progressDuration != oldWidget.progressDuration) {
      _progressController.duration = widget.progressDuration;
    }

    if (widget.visible && !oldWidget.visible) {
      _startAnimation();
    } else if (!widget.visible && oldWidget.visible) {
      _entranceController.reset();
      _progressController.reset();
    }
  }

  void _startAnimation() {
    _entranceController
      ..reset()
      ..forward();

    _progressController
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return IgnorePointer(
      ignoring: !widget.visible,
      child: AnimatedOpacity(
        opacity: widget.visible ? 1 : 0,
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 260),
        child: Semantics(
          liveRegion: true,
          container: true,
          label: widget.visible ? '${widget.title}. ${widget.message}' : null,
          child: ColoredBox(
            color: AppTheme.textDark.withValues(alpha: 0.88),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: reduceMotion
                          ? const AlwaysStoppedAnimation<double>(1)
                          : _scaleAnimation,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 390),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(28, 34, 28, 30),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: AppTheme.textLight.withValues(alpha: 0.20),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x52000000),
                                blurRadius: 42,
                                offset: Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _SuccessMark(
                                animation: reduceMotion
                                    ? const AlwaysStoppedAnimation<double>(1)
                                    : _checkAnimation,
                              ),
                              const SizedBox(height: 26),
                              Text(
                                widget.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppTheme.textDark,
                                  fontSize: 25,
                                  height: 1.15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                widget.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 15,
                                  height: 1.48,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 28),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  height: 6,
                                  color: AppTheme.border,
                                  alignment: Alignment.centerLeft,
                                  child: AnimatedBuilder(
                                    animation: _progressController,
                                    builder: (context, _) {
                                      final progress = reduceMotion
                                          ? 1.0
                                          : Curves.easeInOutCubic.transform(
                                              _progressController.value,
                                            );

                                      return FractionallySizedBox(
                                        widthFactor: progress,
                                        child: const DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppTheme.success,
                                                AppTheme.primaryLight,
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessMark extends StatelessWidget {
  const _SuccessMark({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 112,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          ..._buildBurstDots(),
          ScaleTransition(
            scale: animation,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppTheme.softGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.success.withValues(alpha: 0.34),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 66,
                height: 66,
                decoration: const BoxDecoration(
                  color: AppTheme.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x4021A67A),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ScaleTransition(
                  scale: animation,
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppTheme.textLight,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBurstDots() {
    const dots = <({Alignment alignment, double size})>[
      (alignment: Alignment(0.95, -0.38), size: 8),
      (alignment: Alignment(-0.92, -0.52), size: 7),
      (alignment: Alignment(0.28, -1), size: 6),
      (alignment: Alignment(-0.42, 0.96), size: 8),
      (alignment: Alignment(0.90, 0.70), size: 7),
    ];

    return dots
        .map((dot) {
          return Align(
            alignment: dot.alignment,
            child: FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation,
                child: Container(
                  width: dot.size,
                  height: dot.size,
                  decoration: const BoxDecoration(
                    color: AppTheme.success,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        })
        .toList(growable: false);
  }
}
