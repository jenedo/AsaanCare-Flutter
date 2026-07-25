import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../features/auth/domain/entities/auth_user.dart';
import '../../../features/auth/presentation/controllers/auth_controller.dart';

class DoctorSignInScreen extends StatefulWidget {
  const DoctorSignInScreen({
    super.key,
    required this.authController,
    required this.onAuthenticated,
    required this.onCreateAccount,
  });

  final AuthController? authController;
  final VoidCallback onAuthenticated;
  final VoidCallback onCreateAccount;

  @override
  State<DoctorSignInScreen> createState() => _DoctorSignInScreenState();
}

class _DoctorSignInScreenState extends State<DoctorSignInScreen> {
  static const _teal = Color(0xFF087F82);
  static const _deepTeal = Color(0xFF00565D);
  static const _ink = Color(0xFF092B33);
  static const _muted = Color(0xFF62696D);
  static const _fieldBorder = Color(0xFFD0D5D5);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  String? _serverError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<bool> _handleSwipeComplete() async {
    FocusScope.of(context).unfocus();
    setState(() => _serverError = null);

    if (!(_formKey.currentState?.validate() ?? false)) return false;

    final authController = widget.authController;
    if (authController == null) {
      setState(() {
        _serverError = 'Authentication service is unavailable.';
      });
      return false;
    }

    final success = await authController.login(
      emailOrPhone: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return false;

    if (!success) {
      setState(() {
        _serverError =
            authController.errorMessage ??
            'Sign in failed. Check your details and try again.';
      });
      return false;
    }

    if (authController.currentUser?.role != UserRole.doctor) {
      await authController.logout();
      if (!mounted) return false;
      setState(() {
        _serverError =
            'This sign-in page is only for verified doctor accounts.';
      });
      return false;
    }

    TextInput.finishAutofillContext();
    return true;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password.';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }

  void _showUnavailable(String title, String message) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(color: _muted, height: 1.45),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = widget.authController;
    if (authController == null) {
      return _buildScaffold(isLoading: false);
    }

    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        return _buildScaffold(isLoading: authController.isLoading);
      },
    );
  }

  Widget _buildScaffold({required bool isLoading}) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final horizontalPadding = width < 360
        ? 12.0
        : width < 600
        ? 20.0
        : 32.0;

    return Scaffold(
      backgroundColor: _deepTeal,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF006970), Color(0xFF00474E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              18,
              horizontalPadding,
              20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: [
                    _buildSignInCard(isLoading, width),
                    const SizedBox(height: 20),
                    _buildTermsText(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInCard(bool isLoading, double screenWidth) {
    final compact = screenWidth < 360;
    final cardPadding = compact
        ? 20.0
        : screenWidth < 600
        ? 28.0
        : 56.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(cardPadding, 36, cardPadding, 32),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFEFE),
        borderRadius: BorderRadius.circular(compact ? 40 : 54),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33001D22),
            blurRadius: 36,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(compact),
              SizedBox(height: compact ? 32 : 44),
              _buildLabel('Email'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                enabled: !isLoading,
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                autocorrect: false,
                enableSuggestions: false,
                onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                decoration: _inputDecoration(
                  hint: 'Enter your email',
                  prefixIcon: Icons.mail_outline_rounded,
                ),
              ),
              const SizedBox(height: 22),
              _buildLabel('Password'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                enabled: !isLoading,
                validator: _validatePassword,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                decoration: _inputDecoration(
                  hint: 'Enter your password',
                  prefixIcon: Icons.lock_outline_rounded,
                  suffix: IconButton(
                    tooltip: _obscurePassword
                        ? 'Show password'
                        : 'Hide password',
                    onPressed: isLoading
                        ? null
                        : () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _deepTeal,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () => _showUnavailable(
                          'Forgot password?',
                          'Password recovery will be enabled when the verified email or OTP recovery service is connected.',
                        ),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: _teal,
                    ),
                  ),
                ),
              ),
              if (_serverError != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDEC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFC7C2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFB42318),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _serverError!,
                          style: const TextStyle(
                            color: Color(0xFF8A1C13),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SwipeSignInControl(
                enabled: !isLoading && widget.authController != null,
                onSwipeComplete: _handleSwipeComplete,
                onSuccess: widget.onAuthenticated,
              ),
              const SizedBox(height: 28),
              _buildDivider(),
              const SizedBox(height: 22),
              _buildSocialButton(
                label: 'Sign in with Google',
                mark: const Text(
                  'G',
                  style: TextStyle(
                    color: Color(0xFF4285F4),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : () => _showUnavailable(
                        'Google sign in',
                        'Google authentication is not enabled for doctor accounts yet.',
                      ),
              ),
              const SizedBox(height: 12),
              _buildSocialButton(
                label: 'Sign in with Apple',
                mark: const Icon(Icons.apple, color: Colors.black, size: 29),
                onPressed: isLoading
                    ? null
                    : () => _showUnavailable(
                        'Apple sign in',
                        'Apple authentication is not enabled for doctor accounts yet.',
                      ),
              ),
              const SizedBox(height: 24),
              DoctorCreateAccountPrompt(
                onPressed: isLoading ? null : widget.onCreateAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool compact) {
    return Column(
      children: [
        Container(
          width: compact ? 70 : 82,
          height: compact ? 70 : 82,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_teal, _deepTeal],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2600565D),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.emergency_rounded,
            color: Colors.white,
            size: 52,
            semanticLabel: 'AsaanCare doctor',
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Sign In',
          style: TextStyle(
            color: _ink,
            fontSize: compact ? 34 : 40,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'To sign in to your doctor account,\nenter your email and password',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _ink,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: _fieldBorder, width: 1.2),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9A9EA1), fontSize: 16),
      prefixIcon: Icon(prefixIcon, color: _teal, size: 25),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      enabledBorder: border,
      disabledBorder: border,
      border: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: _teal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Color(0xFFB42318)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Color(0xFFB42318), width: 2),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFB9BDBD))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text('or', style: TextStyle(color: _muted, fontSize: 16)),
        ),
        Expanded(child: Divider(color: Color(0xFFB9BDBD))),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Widget mark,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 58,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _ink,
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE0E2E2)),
          shape: const StadiumBorder(),
          elevation: 2,
          shadowColor: const Color(0x26000000),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: Row(
          children: [
            SizedBox(width: 42, child: Center(child: mark)),
            Expanded(child: Text(label, textAlign: TextAlign.center)),
            const SizedBox(width: 42),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'By clicking “Sign In”, I agree to the ',
          style: TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
        ),
        _termsButton('Terms', 'Terms of service'),
        const Text(
          ' and ',
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
        _termsButton('Privacy Policy', 'Privacy policy'),
      ],
    );
  }

  Widget _termsButton(String label, String title) {
    return InkWell(
      onTap: () => _showUnavailable(
        title,
        'The latest legal document will be displayed here when the policy service is connected.',
      ),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

class DoctorCreateAccountPrompt extends StatelessWidget {
  const DoctorCreateAccountPrompt({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          "Don't have an account yet?",
          style: TextStyle(color: _DoctorSignInScreenState._ink, fontSize: 15),
        ),
        TextButton(onPressed: onPressed, child: const Text('Create Account')),
      ],
    );
  }
}

enum SwipeSignInState { idle, dragging, loading, success, error }

class SwipeSignInControl extends StatefulWidget {
  const SwipeSignInControl({
    super.key,
    required this.onSwipeComplete,
    required this.onSuccess,
    this.enabled = true,
  });

  final Future<bool> Function() onSwipeComplete;
  final VoidCallback onSuccess;
  final bool enabled;

  @override
  State<SwipeSignInControl> createState() => SwipeSignInControlState();
}

class SwipeSignInControlState extends State<SwipeSignInControl>
    with SingleTickerProviderStateMixin {
  static const _trackColor = Color(0xFF087F82);
  static const _deepTeal = Color(0xFF00565D);
  static const _handleSize = 50.0;
  static const _trackInset = 6.0;
  static const _completionThreshold = 0.88;

  late final AnimationController _animationController;
  final FocusNode _handleFocusNode = FocusNode(debugLabel: 'Swipe to sign in');
  Timer? _minimumLoadingTimer;
  Completer<void>? _minimumLoadingCompleter;

  SwipeSignInState _swipeState = SwipeSignInState.idle;
  double _dragOffset = 0;
  double _maxDrag = 0;
  double _animationStart = 0;
  double _animationEnd = 0;
  String? _statusMessage;
  int _operationToken = 0;

  bool get _isInteractive =>
      widget.enabled &&
      (_swipeState == SwipeSignInState.idle ||
          _swipeState == SwipeSignInState.dragging ||
          _swipeState == SwipeSignInState.error);

  double get _progress =>
      _maxDrag <= 0 ? 0 : (_dragOffset / _maxDrag).clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this)
      ..addListener(() {
        final curved = Curves.easeOutCubic.transform(
          _animationController.value,
        );
        if (!mounted) return;
        setState(() {
          _dragOffset =
              _animationStart + ((_animationEnd - _animationStart) * curved);
        });
      });
  }

  @override
  void dispose() {
    _operationToken++;
    _minimumLoadingTimer?.cancel();
    final minimumLoadingCompleter = _minimumLoadingCompleter;
    if (minimumLoadingCompleter != null &&
        !minimumLoadingCompleter.isCompleted) {
      minimumLoadingCompleter.complete();
    }
    _minimumLoadingTimer = null;
    _minimumLoadingCompleter = null;
    _animationController.dispose();
    _handleFocusNode.dispose();
    super.dispose();
  }

  void resetSwipe() {
    _operationToken++;
    _animationController.stop();
    if (!mounted) return;
    setState(() {
      _dragOffset = 0;
      _swipeState = SwipeSignInState.idle;
      _statusMessage = null;
    });
  }

  void _startDrag(DragStartDetails details) {
    if (!_isInteractive) return;
    _animationController.stop();
    _handleFocusNode.requestFocus();
    setState(() {
      _swipeState = SwipeSignInState.dragging;
      _statusMessage = null;
    });
  }

  void _updateDrag(DragUpdateDetails details) {
    if (_swipeState != SwipeSignInState.dragging) return;
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dx).clamp(0.0, _maxDrag);
    });
  }

  void _endDrag(DragEndDetails details) {
    if (_swipeState != SwipeSignInState.dragging) return;
    if (_progress >= _completionThreshold) {
      _completeSwipe();
      return;
    }
    _rejectSwipe();
  }

  void _cancelDrag() {
    if (_swipeState == SwipeSignInState.dragging) _rejectSwipe();
  }

  Future<void> _rejectSwipe() async {
    final token = ++_operationToken;
    setState(() {
      _swipeState = SwipeSignInState.error;
      _statusMessage = 'Drag the handle all the way to the right';
    });
    await _animateTo(0, const Duration(milliseconds: 280));
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted || token != _operationToken) return;
    setState(() {
      _swipeState = SwipeSignInState.idle;
      _statusMessage = null;
    });
  }

  Future<void> _completeSwipe() async {
    if (_swipeState == SwipeSignInState.loading ||
        _swipeState == SwipeSignInState.success) {
      return;
    }

    final token = ++_operationToken;
    _animationController.stop();
    setState(() {
      _dragOffset = _maxDrag;
      _swipeState = SwipeSignInState.loading;
      _statusMessage = 'Verifying credentials…';
    });

    var authenticated = false;
    final minimumLoadingDelay = Completer<void>();
    _minimumLoadingCompleter = minimumLoadingDelay;
    _minimumLoadingTimer = Timer(
      const Duration(milliseconds: 1400),
      minimumLoadingDelay.complete,
    );
    try {
      final results = await Future.wait<dynamic>([
        widget.onSwipeComplete(),
        minimumLoadingDelay.future,
      ]);
      authenticated = results.first == true;
    } catch (_) {
      authenticated = false;
    } finally {
      _minimumLoadingTimer?.cancel();
      _minimumLoadingTimer = null;
      _minimumLoadingCompleter = null;
    }

    if (!mounted || token != _operationToken) return;
    if (!authenticated) {
      resetSwipe();
      return;
    }

    setState(() {
      _swipeState = SwipeSignInState.success;
      _statusMessage = 'Signed in successfully';
    });

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    await Future<void>.delayed(Duration(milliseconds: reduceMotion ? 80 : 650));
    if (!mounted || token != _operationToken) return;
    widget.onSuccess();
  }

  Future<void> _animateTo(double target, Duration duration) async {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _animationStart = _dragOffset;
    _animationEnd = target.clamp(0.0, _maxDrag);
    _animationController.duration = reduceMotion
        ? const Duration(milliseconds: 1)
        : duration;
    await _animationController.forward(from: 0);
  }

  Future<void> _keyboardComplete() async {
    if (!_isInteractive) return;
    _operationToken++;
    setState(() {
      _swipeState = SwipeSignInState.dragging;
      _statusMessage = null;
    });
    await _animateTo(_maxDrag, const Duration(milliseconds: 650));
    if (!mounted || _swipeState != SwipeSignInState.dragging) return;
    await _completeSwipe();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      resetSwipe();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      _keyboardComplete();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final nextMaxDrag =
            (constraints.maxWidth - _handleSize - (_trackInset * 2)).clamp(
              0.0,
              double.infinity,
            );
        if (_swipeState == SwipeSignInState.success ||
            _swipeState == SwipeSignInState.loading) {
          _dragOffset = nextMaxDrag;
        } else {
          _dragOffset = _dragOffset.clamp(0.0, nextMaxDrag);
        }
        _maxDrag = nextMaxDrag;

        final progress = _progress;
        final labelOpacity = (1 - (progress / 0.55)).clamp(0.0, 1.0);

        return SizedBox(
          height: 62,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: _trackColor,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress,
                        heightFactor: 1,
                        child: const ColoredBox(color: Color(0x3300E1D5)),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Opacity(
                      opacity:
                          _swipeState == SwipeSignInState.loading ||
                              _swipeState == SwipeSignInState.success
                          ? 0
                          : labelOpacity,
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _trackInset,
                top: _trackInset,
                child: Transform.translate(
                  offset: Offset(_dragOffset, 0),
                  child: Semantics(
                    slider: true,
                    enabled: _isInteractive,
                    label: 'Swipe to sign in',
                    value: '${(progress * 100).round()} percent',
                    increasedValue: '100 percent',
                    decreasedValue: '0 percent',
                    child: Focus(
                      focusNode: _handleFocusNode,
                      onKeyEvent: _handleKeyEvent,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _isInteractive
                            ? _handleFocusNode.requestFocus
                            : null,
                        onHorizontalDragStart: _isInteractive
                            ? _startDrag
                            : null,
                        onHorizontalDragUpdate: _isInteractive
                            ? _updateDrag
                            : null,
                        onHorizontalDragEnd: _isInteractive ? _endDrag : null,
                        onHorizontalDragCancel: _isInteractive
                            ? _cancelDrag
                            : null,
                        child: AnimatedContainer(
                          duration: _swipeState == SwipeSignInState.dragging
                              ? Duration.zero
                              : const Duration(milliseconds: 180),
                          width: _handleSize,
                          height: _handleSize,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x4000181C),
                                blurRadius:
                                    _swipeState == SwipeSignInState.dragging
                                    ? 14
                                    : 7,
                                offset: Offset(
                                  0,
                                  _swipeState == SwipeSignInState.dragging
                                      ? 6
                                      : 3,
                                ),
                              ),
                            ],
                          ),
                          child: _buildHandleContent(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 66,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _statusMessage == null
                        ? const SizedBox.shrink()
                        : Text(
                            _statusMessage!,
                            key: ValueKey(_statusMessage),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _swipeState == SwipeSignInState.error
                                  ? const Color(0xFFB42318)
                                  : _deepTeal,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandleContent() {
    return switch (_swipeState) {
      SwipeSignInState.loading => const SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: _trackColor),
      ),
      SwipeSignInState.success => const _AnimatedSuccessCheckmark(
        color: _trackColor,
      ),
      _ => const Icon(Icons.arrow_forward_rounded, color: _deepTeal, size: 32),
    };
  }
}

class _AnimatedSuccessCheckmark extends StatefulWidget {
  const _AnimatedSuccessCheckmark({required this.color});

  final Color color;

  @override
  State<_AnimatedSuccessCheckmark> createState() =>
      _AnimatedSuccessCheckmarkState();
}

class _AnimatedSuccessCheckmarkState extends State<_AnimatedSuccessCheckmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) _controller.value = 1;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        size: const Size.square(27),
        painter: _CheckmarkPainter(
          color: widget.color,
          progress: Curves.easeOutCubic.transform(_controller.value),
        ),
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  const _CheckmarkPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height * 0.78)
      ..lineTo(size.width * 0.86, size.height * 0.24);
    final metrics = path.computeMetrics().first;
    final visiblePath = metrics.extractPath(0, metrics.length * progress);
    canvas.drawPath(
      visiblePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
