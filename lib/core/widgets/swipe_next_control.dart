import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/app_motion.dart';
import '../theme/app_theme.dart';

class SwipeNextControl extends StatefulWidget {
  const SwipeNextControl({
    super.key,
    required this.loading,
    required this.onComplete,
  });

  final bool loading;
  final Future<bool> Function() onComplete;

  @override
  State<SwipeNextControl> createState() => _SwipeNextControlState();
}

class _SwipeNextControlState extends State<SwipeNextControl> {
  static const _trackHeight = 72.0;
  static const _thumbSize = 62.0;
  static const _trackInset = 5.0;
  static const _completionThreshold = 0.88;

  double _thumbOffset = 0;
  bool _dragging = false;
  bool _submitting = false;

  double get _progress {
    if (_maxThumbOffset <= 0) return 0;
    return (_thumbOffset / _maxThumbOffset).clamp(0.0, 1.0);
  }

  double _maxThumbOffset = 0;

  bool get _disabled => widget.loading || _submitting;

  void _setTrackWidth(double width) {
    final nextMax = math.max(0.0, width - _thumbSize - (_trackInset * 2));
    if ((_maxThumbOffset - nextMax).abs() < 0.5) return;
    _maxThumbOffset = nextMax;
    _thumbOffset = _thumbOffset.clamp(0.0, _maxThumbOffset);
  }

  void _reset() {
    if (!mounted) return;
    setState(() {
      _thumbOffset = 0;
      _dragging = false;
      _submitting = false;
    });
  }

  void _handleDragStart(DragStartDetails details) {
    if (_disabled) return;
    setState(() => _dragging = true);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_dragging || _disabled) return;
    final delta = details.primaryDelta ?? details.delta.dx;
    setState(() {
      _thumbOffset = (_thumbOffset + delta).clamp(0.0, _maxThumbOffset);
    });
  }

  Future<void> _handleDragEnd(DragEndDetails details) async {
    if (!_dragging) return;
    setState(() => _dragging = false);

    if (_progress < _completionThreshold) {
      _reset();
      return;
    }

    await _complete();
  }

  void _handleDragCancel() {
    _reset();
  }

  Future<void> _complete() async {
    if (_disabled) return;

    setState(() {
      _thumbOffset = _maxThumbOffset;
      _submitting = true;
    });

    final success = await widget.onComplete();
    if (!mounted) return;

    if (!success) {
      _reset();
      return;
    }

    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = _dragging || reduceMotion
        ? Duration.zero
        : AppMotion.medium;
    final progressPercent = (_progress * 100).round().toString();

    return LayoutBuilder(
      builder: (context, constraints) {
        _setTrackWidth(constraints.maxWidth);

        return Semantics(
          container: true,
          button: true,
          enabled: !_disabled,
          label: 'Swipe to continue',
          value: progressPercent,
          onTap: _disabled ? null : _complete,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: _disabled ? null : _handleDragStart,
            onHorizontalDragUpdate: _disabled ? null : _handleDragUpdate,
            onHorizontalDragEnd: _disabled ? null : _handleDragEnd,
            onHorizontalDragCancel: _handleDragCancel,
            child: Container(
              height: _trackHeight,
              decoration: BoxDecoration(
                color: _disabled
                    ? AppTheme.primary.withValues(alpha: 0.65)
                    : AppTheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  AnimatedContainer(
                    duration: duration,
                    curve: AppMotion.standard,
                    width: _trackInset + _thumbSize + _thumbOffset,
                    height: _trackHeight,
                    color: AppTheme.primaryLight.withValues(alpha: 0.42),
                  ),
                  Center(
                    child: AnimatedOpacity(
                      opacity: _dragging ? 0.58 : 1,
                      duration: reduceMotion ? Duration.zero : AppMotion.fast,
                      curve: AppMotion.standard,
                      child: _disabled
                          ? const SizedBox.square(
                              dimension: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppTheme.textLight,
                              ),
                            )
                          : const Text(
                              'Next',
                              style: TextStyle(
                                color: AppTheme.textLight,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: duration,
                    curve: AppMotion.standard,
                    transform: Matrix4.translationValues(_thumbOffset, 0, 0),
                    margin: const EdgeInsets.only(left: _trackInset),
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: const BoxDecoration(
                      color: AppTheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppTheme.primary,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
