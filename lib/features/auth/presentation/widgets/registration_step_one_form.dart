import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/swipe_next_control.dart';
import 'registration_ui_parts.dart';

class RegistrationStepOneForm extends StatelessWidget {
  const RegistrationStepOneForm({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.fullNameFocus,
    required this.emailFocus,
    required this.phoneFocus,
    required this.passwordFocus,
    required this.confirmPasswordFocus,
    required this.genderFocus,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.gender,
    required this.genderError,
    required this.isLoading,
    required this.validateFullName,
    required this.validateEmail,
    required this.validatePhone,
    required this.validatePassword,
    required this.validateConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onGenderChanged,
    required this.onComplete,
    this.onSignIn,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode fullNameFocus;
  final FocusNode emailFocus;
  final FocusNode phoneFocus;
  final FocusNode passwordFocus;
  final FocusNode confirmPasswordFocus;
  final FocusNode genderFocus;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final String? gender;
  final String? genderError;
  final bool isLoading;
  final FormFieldValidator<String> validateFullName;
  final FormFieldValidator<String> validateEmail;
  final FormFieldValidator<String> validatePhone;
  final FormFieldValidator<String> validatePassword;
  final FormFieldValidator<String> validateConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final ValueChanged<String> onGenderChanged;
  final Future<bool> Function() onComplete;
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RegistrationHeader(),
          const SizedBox(height: 34),
          RegistrationField(
            controller: fullNameController,
            focusNode: fullNameFocus,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: validateFullName,
            enabled: !isLoading,
          ),
          RegistrationField(
            controller: emailController,
            focusNode: emailFocus,
            label: 'Email',
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            validator: validateEmail,
            enabled: !isLoading,
          ),
          RegistrationField(
            controller: phoneController,
            focusNode: phoneFocus,
            label: 'Phone Number',
            hint: 'Enter your phone number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumber],
            validator: validatePhone,
            enabled: !isLoading,
          ),
          RegistrationField(
            controller: passwordController,
            focusNode: passwordFocus,
            label: 'Password',
            hint: 'Enter your password',
            icon: Icons.lock_outline_rounded,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            validator: validatePassword,
            enabled: !isLoading,
            suffix: PasswordToggle(
              obscured: obscurePassword,
              enabled: !isLoading,
              onPressed: onTogglePassword,
            ),
          ),
          RegistrationField(
            controller: confirmPasswordController,
            focusNode: confirmPasswordFocus,
            label: 'Confirm Password',
            hint: 'Confirm your password',
            icon: Icons.lock_outline_rounded,
            obscureText: obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            validator: validateConfirmPassword,
            enabled: !isLoading,
            suffix: PasswordToggle(
              obscured: obscureConfirmPassword,
              enabled: !isLoading,
              onPressed: onToggleConfirmPassword,
            ),
          ),
          GenderSelector(
            focusNode: genderFocus,
            selectedGender: gender,
            errorText: genderError,
            enabled: !isLoading,
            onChanged: onGenderChanged,
          ),
          const SizedBox(height: 22),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 15),
                ),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : onSignIn ??
                            () => Navigator.of(
                              context,
                            ).pushReplacementNamed(AppRoutes.login),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SwipeNextControl(loading: isLoading, onComplete: onComplete),
        ],
      ),
    );
  }
}

class GenderSelector extends StatelessWidget {
  const GenderSelector({
    super.key,
    required this.focusNode,
    required this.selectedGender,
    required this.errorText,
    required this.enabled,
    required this.onChanged,
  });

  final FocusNode focusNode;
  final String? selectedGender;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = [
      ('Male', Icons.male_rounded),
      ('Female', Icons.female_rounded),
      ('Other', Icons.person_outline_rounded),
    ];

    return Focus(
      focusNode: focusNode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gender',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 460;
              final width = stacked
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 24) / 3;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: options.map((option) {
                  final selected = selectedGender == option.$1;
                  return SizedBox(
                    width: width,
                    child: Semantics(
                      selected: selected,
                      inMutuallyExclusiveGroup: true,
                      label: '${option.$1} gender',
                      child: InkWell(
                        onTap: enabled ? () => onChanged(option.$1) : null,
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 58,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.softTeal
                                : AppTheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: errorText != null
                                  ? AppTheme.danger
                                  : selected
                                  ? AppTheme.primary
                                  : AppTheme.border,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                option.$2,
                                color: AppTheme.primary,
                                size: 25,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                option.$1,
                                style: TextStyle(
                                  color: AppTheme.textDark,
                                  fontSize: 15,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          if (errorText != null) ...[
            const SizedBox(height: 7),
            Text(
              errorText!,
              style: const TextStyle(color: AppTheme.danger, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
