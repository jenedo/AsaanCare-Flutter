import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_invisible_scroll_behavior.dart';
import '../widgets/auth_verification_overlay.dart';
import '../widgets/swipe_to_sign_in_control.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _showSuccessOverlay = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> _login() async {
    if (widget.authController.isLoading || _showSuccessOverlay) return false;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showError('Please enter your email address.');
      return false;
    }

    if (password.isEmpty) {
      _showError('Please enter your password.');
      return false;
    }

    final success = await widget.authController.login(
      emailOrPhone: email,
      password: password,
    );

    if (!mounted) return false;

    if (!success) {
      _showError(
        widget.authController.errorMessage ??
            'Login failed. Please check your credentials.',
      );
      return false;
    }

    setState(() => _showSuccessOverlay = true);

    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return true;

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.patientHome, (route) => false);
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.danger,
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.authController,
      builder: (context, _) {
        final isLoading = widget.authController.isLoading;
        final isBusy = isLoading || _showSuccessOverlay;

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF044B56), Color(0xFF012C33)],
              ),
            ),
            child: Stack(
              children: [
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ScrollConfiguration(
                        behavior: const AuthInvisibleScrollBehavior(),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 24,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight - 48,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 440,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(36),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x24000000),
                                        blurRadius: 30,
                                        offset: Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(28),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Top Logo
                                      const Center(child: _AsaanCareLogo()),
                                      const SizedBox(height: 16),

                                      // Title & Subtitle
                                      const Text(
                                        'Sign In',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF101828),
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'To sign in to an account in the application,\nenter your email and password',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.35,
                                          color: Color(0xFF667085),
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Email Label & Input
                                      const Text(
                                        'Email',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF101828),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      _CustomInputField(
                                        controller: _emailController,
                                        enabled: !isBusy,
                                        hintText: 'Enter your email address',
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        prefixIcon:
                                            Icons.person_outline_rounded,
                                      ),
                                      const SizedBox(height: 16),

                                      // Password Label & Input
                                      const Text(
                                        'Password',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF101828),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      _CustomInputField(
                                        controller: _passwordController,
                                        enabled: !isBusy,
                                        hintText: 'Enter your password',
                                        obscureText: _obscurePassword,
                                        textInputAction: TextInputAction.done,
                                        prefixIcon: Icons.lock_outline_rounded,
                                        suffixIcon: IconButton(
                                          onPressed: isBusy
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _obscurePassword =
                                                        !_obscurePassword;
                                                  });
                                                },
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: const Color(0xFF101828),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Forgot Password Link
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: isBusy ? null : () {},
                                          child: const Text(
                                            'Forgot password?',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF1570EF),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Swipe to Sign In Control
                                      SwipeToSignInControl(
                                        loading: isBusy,
                                        label: 'Swipe to Sign In',
                                        onComplete: _login,
                                      ),
                                      const SizedBox(height: 20),

                                      // Or Divider
                                      const Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: Color(0xFFEAECF0),
                                              thickness: 1,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Text(
                                              'or',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF667085),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: Color(0xFFEAECF0),
                                              thickness: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),

                                      // Social Buttons Row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _SocialButton(
                                              label: 'Sign in with Google',
                                              icon: _GoogleIcon(),
                                              onPressed: isBusy ? null : () {},
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _SocialButton(
                                              label: 'Sign in with Apple',
                                              icon: const Icon(
                                                Icons.apple,
                                                size: 20,
                                                color: Colors.black,
                                              ),
                                              onPressed: isBusy ? null : () {},
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),

                                      // Create Account Footer Link
                                      Center(
                                        child: GestureDetector(
                                          onTap: isBusy
                                              ? null
                                              : () {
                                                  Navigator.of(
                                                    context,
                                                  ).pushReplacementNamed(
                                                    AppRoutes.register,
                                                  );
                                                },
                                          child: RichText(
                                            text: const TextSpan(
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF475467),
                                              ),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      "Don't have an account yet? ",
                                                ),
                                                TextSpan(
                                                  text: 'Create Account',
                                                  style: TextStyle(
                                                    color: Color(0xFF1570EF),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),

                                      // Terms & Privacy Policy
                                      Center(
                                        child: Text.rich(
                                          TextSpan(
                                            style: const TextStyle(
                                              fontSize: 11,
                                              height: 1.3,
                                              color: Color(0xFF667085),
                                            ),
                                            children: [
                                              const TextSpan(
                                                text:
                                                    'By clicking "Sign In", I have read and agree\nwith the ',
                                              ),
                                              TextSpan(
                                                text: 'Terms & Privacy Policy',
                                                style: const TextStyle(
                                                  color: Color(0xFF1570EF),
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: AuthVerificationOverlay(
                    visible: _showSuccessOverlay,
                    title: 'Sign-in verified',
                    message:
                        'Your session is secure. Redirecting you to AsaanCare.',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AsaanCareLogo extends StatelessWidget {
  const _AsaanCareLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Stylized 'A' ribbon shape
              Icon(
                Icons.change_history_rounded,
                size: 52,
                color: const Color(0xFF0072C6),
              ),
              Positioned(
                bottom: 8,
                child: Icon(
                  Icons.favorite_rounded,
                  size: 18,
                  color: const Color(0xFF00A896),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            children: [
              TextSpan(
                text: 'Asaan',
                style: TextStyle(color: Color(0xFF004D56)),
              ),
              TextSpan(
                text: 'Care',
                style: TextStyle(color: Color(0xFF00A896)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CustomInputField extends StatelessWidget {
  const _CustomInputField({
    required this.controller,
    required this.enabled,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final bool enabled;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE4E7EC), width: 1),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: const TextStyle(fontSize: 14, color: Color(0xFF101828)),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
          icon: Icon(prefixIcon, color: const Color(0xFF667085), size: 20),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        side: const BorderSide(color: Color(0xFFE4E7EC)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF344054),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintRed = Paint()..color = const Color(0xFFEA4335);
    final paintBlue = Paint()..color = const Color(0xFF4285F4);
    final paintGreen = Paint()..color = const Color(0xFF34A853);
    final paintYellow = Paint()..color = const Color(0xFFFBBC05);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.5,
      1.5,
      true,
      paintRed,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.0,
      1.2,
      true,
      paintYellow,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.2,
      1.2,
      true,
      paintGreen,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.4,
      1.2,
      true,
      paintBlue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
