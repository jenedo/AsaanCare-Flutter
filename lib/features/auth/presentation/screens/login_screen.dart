import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_invisible_scroll_behavior.dart';
import '../widgets/auth_verification_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _showSuccessOverlay = false;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (widget.authController.isLoading || _showSuccessOverlay) return;

    final success = await widget.authController.login(
      emailOrPhone: _emailOrPhoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (!success) {
      _showError(widget.authController.errorMessage ?? 'Login failed.');
      return;
    }

    setState(() => _showSuccessOverlay = true);

    await Future<void>.delayed(const Duration(milliseconds: 1900));
    if (!mounted) return;

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.patientHome, (route) => false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppTheme.danger, content: Text(message)),
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
          backgroundColor: AppTheme.background,
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              Positioned.fill(
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ScrollConfiguration(
                        behavior: const AuthInvisibleScrollBehavior(),
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 460,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: AppTheme.surface,
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: const [
                                        BoxShadow(
                                          blurRadius: 30,
                                          offset: Offset(0, 14),
                                          color: Color(0x14000000),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const AuthHeader(
                                            title: 'Welcome back',
                                            subtitle:
                                                'Login to manage appointments, consultations, prescriptions, and medical records.',
                                          ),
                                          const SizedBox(height: 28),
                                          TextField(
                                            controller: _emailOrPhoneController,
                                            enabled: !isBusy,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            textInputAction:
                                                TextInputAction.next,
                                            autofillHints: const [
                                              AutofillHints.email,
                                              AutofillHints.telephoneNumber,
                                            ],
                                            decoration: const InputDecoration(
                                              labelText: 'Email or phone',
                                              prefixIcon: Icon(
                                                Icons.person_outline,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          TextField(
                                            controller: _passwordController,
                                            enabled: !isBusy,
                                            obscureText: _obscurePassword,
                                            textInputAction:
                                                TextInputAction.done,
                                            autofillHints: const [
                                              AutofillHints.password,
                                            ],
                                            onSubmitted: (_) => _login(),
                                            decoration: InputDecoration(
                                              labelText: 'Password',
                                              prefixIcon: const Icon(
                                                Icons.lock_outline,
                                              ),
                                              suffixIcon: IconButton(
                                                onPressed: isBusy
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          _obscurePassword =
                                                              !_obscurePassword;
                                                        });
                                                      },
                                                tooltip: _obscurePassword
                                                    ? 'Show password'
                                                    : 'Hide password',
                                                icon: Icon(
                                                  _obscurePassword
                                                      ? Icons
                                                            .visibility_outlined
                                                      : Icons
                                                            .visibility_off_outlined,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              onPressed: isBusy ? null : () {},
                                              child: const Text(
                                                'Forgot password?',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ElevatedButton(
                                            onPressed: isBusy ? null : _login,
                                            child: isLoading
                                                ? const SizedBox.square(
                                                    dimension: 22,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2.5,
                                                          color: AppTheme
                                                              .textLight,
                                                        ),
                                                  )
                                                : const Text('Login'),
                                          ),
                                          const SizedBox(height: 18),
                                          Center(
                                            child: TextButton(
                                              onPressed: isBusy
                                                  ? null
                                                  : () {
                                                      Navigator.of(
                                                        context,
                                                      ).pushReplacementNamed(
                                                        AppRoutes.register,
                                                      );
                                                    },
                                              child: const Text(
                                                'Do not have an account? Create account',
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
                      );
                    },
                  ),
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
        );
      },
    );
  }
}
