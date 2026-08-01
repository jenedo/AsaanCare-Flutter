import 'dart:math' as math;
import 'package:flutter/material.dart';

class SwipeToSignInControl extends StatefulWidget {
  const SwipeToSignInControl({
    super.key,
    required this.loading,
    required this.onComplete,
    this.label = 'Swipe to Sign In',
  });

  final bool loading;
  final Future<bool> Function() onComplete;
  final String label;

  @override
  State<SwipeToSignInControl> createState() => _SwipeToSignInControlState();
}

class _SwipeToSignInControlState extends State<SwipeToSignInControl> {
  static const _trackHeight = 64.0;
  static const _thumbSize = 54.0;
  static const _trackInset = 5.0;
  static const _completionThreshold = 0.82;

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

    late final bool success;
    try {
      success = await widget.onComplete();
    } catch (_) {
      _reset();
      rethrow;
    }

    if (!mounted) return;

    if (!success) {
      _reset();
      return;
    }

    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    const darkTeal = Color(0xFF004D56);
    const accentBorder = Color(0xFF4DE0EC);

    return LayoutBuilder(
      builder: (context, constraints) {
        _setTrackWidth(constraints.maxWidth);

        return Semantics(
          container: true,
          button: true,
          enabled: !_disabled,
          label: widget.label,
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
                color: darkTeal,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: accentBorder.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Animated progress fill background
                  AnimatedContainer(
                    duration: _dragging
                        ? Duration.zero
                        : const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: _trackInset + _thumbSize + _thumbOffset,
                    height: _trackHeight,
                    decoration: BoxDecoration(
                      color: accentBorder.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),

                  // Center Label & Right Chevrons
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const SizedBox(width: _thumbSize),
                          Expanded(
                            child: Center(
                              child: _disabled
                                  ? const SizedBox.square(
                                      dimension: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        widget.label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          Text(
                            '>>>',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ),

                  // Sliding Thumb
                  AnimatedContainer(
                    duration: _dragging
                        ? Duration.zero
                        : const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    transform: Matrix4.translationValues(_thumbOffset, 0, 0),
                    margin: const EdgeInsets.only(left: _trackInset),
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x2E000000),
                          blurRadius: 6,
                          offset: Offset(1, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: darkTeal,
                      size: 26,
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
