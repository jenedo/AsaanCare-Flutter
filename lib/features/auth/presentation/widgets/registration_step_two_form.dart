import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'registration_ui_parts.dart';

class RegistrationStepTwoForm extends StatelessWidget {
  const RegistrationStepTwoForm({
    super.key,
    required this.formKey,
    required this.licenseController,
    required this.specializationController,
    required this.experienceController,
    required this.workplaceController,
    required this.licenseFocus,
    required this.specializationFocus,
    required this.experienceFocus,
    required this.workplaceFocus,
    required this.isLoading,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.validateLicense,
    required this.validateSpecialization,
    required this.validateExperience,
    required this.validateWorkplace,
    required this.onSubmit,
    required this.onBack,
    this.errorText,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController licenseController;
  final TextEditingController specializationController;
  final TextEditingController experienceController;
  final TextEditingController workplaceController;
  final FocusNode licenseFocus;
  final FocusNode specializationFocus;
  final FocusNode experienceFocus;
  final FocusNode workplaceFocus;
  final bool isLoading;
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final FormFieldValidator<String> validateLicense;
  final FormFieldValidator<String> validateSpecialization;
  final FormFieldValidator<String> validateExperience;
  final FormFieldValidator<String> validateWorkplace;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RegistrationHeader(step: 2),
          const SizedBox(height: 34),
          const Text(
            'Doctor verification',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add your professional details so your account can be reviewed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          SavedDetail(label: 'Full Name', value: fullName),
          SavedDetail(label: 'Email', value: email),
          SavedDetail(label: 'Phone Number', value: phone),
          SavedDetail(label: 'Gender', value: gender),
          const SizedBox(height: 12),
          RegistrationField(
            controller: licenseController,
            focusNode: licenseFocus,
            label: 'Medical License Number',
            hint: 'Enter license number',
            icon: Icons.badge_outlined,
            textInputAction: TextInputAction.next,
            validator: validateLicense,
            enabled: !isLoading,
          ),
          RegistrationField(
            controller: specializationController,
            focusNode: specializationFocus,
            label: 'Specialization',
            hint: 'Enter specialization',
            icon: Icons.medical_services_outlined,
            textInputAction: TextInputAction.next,
            validator: validateSpecialization,
            enabled: !isLoading,
          ),
          RegistrationField(
            controller: experienceController,
            focusNode: experienceFocus,
            label: 'Years of Experience',
            hint: 'Enter years of experience',
            icon: Icons.timeline_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: validateExperience,
            enabled: !isLoading,
          ),
          RegistrationField(
            controller: workplaceController,
            focusNode: workplaceFocus,
            label: 'Clinic or Hospital',
            hint: 'Enter clinic or hospital name',
            icon: Icons.local_hospital_outlined,
            textInputAction: TextInputAction.done,
            validator: validateWorkplace,
            enabled: !isLoading,
          ),
          if (errorText != null) ...[
            const SizedBox(height: 2),
            Text(
              errorText!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.danger,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
          ] else
            const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: isLoading ? null : onSubmit,
            icon: isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppTheme.textLight,
                    ),
                  )
                : const Icon(Icons.verified_user_outlined),
            label: Text(
              isLoading ? 'Submitting...' : 'Submit verification request',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: isLoading ? null : onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back to Step 1'),
          ),
        ],
      ),
    );
  }
}
