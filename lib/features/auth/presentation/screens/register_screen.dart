import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/doctor_registration_payload.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_invisible_scroll_behavior.dart';
import '../widgets/auth_verification_overlay.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.authController,
    this.onSignIn,
    this.onRegisterDoctor,
  });

  final AuthController authController;
  final VoidCallback? onSignIn;
  final DoctorRegistrationSubmitter? onRegisterDoctor;

  @override
  State<RegisterScreen> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _professionalFormKey = GlobalKey<FormState>();
  final _pmdcController = TextEditingController();
  final _experienceController = TextEditingController();
  final _clinicController = TextEditingController();
  final _feeController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _scrollController = ScrollController();

  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _genderFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 1;
  String? _gender = 'Male';
  String? _genderError;
  String? _specialty;
  String? _documentsError;
  String? _agreementError;
  RegistrationUpload? _medicalLicense;
  RegistrationUpload? _idFront;
  RegistrationUpload? _idBack;
  bool _agreedToVerificationTerms = false;
  bool _isSubmittingProfessional = false;
  bool _showSuccessOverlay = false;
  _RegistrationStepOneData? _stepOneData;

  bool get _isLoading =>
      widget.authController.isLoading || _isSubmittingProfessional;

  @visibleForTesting
  void setStepTwoDataForTesting({
    String? specialty,
    String? pmdc,
    String? experience,
    String? clinic,
    String? fee,
    RegistrationUpload? medicalLicense,
    RegistrationUpload? idFront,
    RegistrationUpload? idBack,
    bool agreed = true,
  }) {
    setState(() {
      if (specialty != null) _specialty = specialty;
      if (pmdc != null) _pmdcController.text = pmdc;
      if (experience != null) _experienceController.text = experience;
      if (clinic != null) _clinicController.text = clinic;
      if (fee != null) _feeController.text = fee;
      if (medicalLicense != null) _medicalLicense = medicalLicense;
      if (idFront != null) _idFront = idFront;
      if (idBack != null) _idBack = idBack;
      _agreedToVerificationTerms = agreed;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pmdcController.dispose();
    _experienceController.dispose();
    _clinicController.dispose();
    _feeController.dispose();
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _genderFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter your full name.';
    if (name.length < 2) return 'Full name must be at least 2 characters.';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Enter your phone number.';
    if (!RegExp(r'^\+?[0-9\s().-]+$').hasMatch(phone)) {
      return 'Enter a valid phone number.';
    }
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || digits.length > 15) {
      return 'Phone number must contain 7 to 15 digits.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password.';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirm your password.';
    if (value != _passwordController.text) return 'Passwords do not match.';
    return null;
  }

  FocusNode? _firstInvalidFocus() {
    if (_validateFullName(_fullNameController.text) != null) {
      return _fullNameFocus;
    }
    if (_validateEmail(_emailController.text) != null) return _emailFocus;
    if (_validatePhone(_phoneController.text) != null) return _phoneFocus;
    if (_validatePassword(_passwordController.text) != null) {
      return _passwordFocus;
    }
    if (_validateConfirmPassword(_confirmPasswordController.text) != null) {
      return _confirmPasswordFocus;
    }
    if (_gender == null) return _genderFocus;
    return null;
  }

  bool _validateForm() {
    final fieldsValid = _formKey.currentState?.validate() ?? false;
    final genderValid = _gender != null;
    setState(() {
      _genderError = genderValid ? null : 'Select your gender.';
    });

    if (!fieldsValid || !genderValid) {
      _firstInvalidFocus()?.requestFocus();
      return false;
    }
    return true;
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  // STEP 1 CALLBACK: patient flow registers immediately; doctor flow advances to
  // Step 2 when onRegisterDoctor is wired by DoctorApp.
  Future<bool> handleNextStep() async {
    if (_isLoading || !_validateForm()) return false;

    FocusScope.of(context).unfocus();

    if (widget.onRegisterDoctor != null) {
      setState(() {
        _stepOneData = _RegistrationStepOneData(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          gender: _gender!,
        );
        _currentStep = 2;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTop());
      return true;
    }

    final success = await widget.authController.registerPatient(
      fullName: _fullNameController.text.trim(),
      emailOrPhone: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return success;
    if (!success) {
      final message =
          widget.authController.errorMessage ??
          'Registration failed. Check your information and try again.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return false;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.patientHome, (route) => false);
    return true;
  }

  String? _validateRequiredProfessionalField(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Enter $label.';
    return null;
  }

  String? _validateExperience(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter years of experience.';
    final years = int.tryParse(text);
    if (years == null) return 'Enter a valid number.';
    if (years < 0 || years > 70) {
      return 'Experience must be between 0 and 70 years.';
    }
    return null;
  }

  String? _validateFee(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter consultation fee.';
    final fee = int.tryParse(text);
    if (fee == null) return 'Enter a valid amount.';
    if (fee < 0 || fee > 1000000) {
      return 'Enter a fee between PKR 0 and 1,000,000.';
    }
    return null;
  }

  bool _validateProfessionalForm() {
    final fieldsValid = _professionalFormKey.currentState?.validate() ?? false;
    final documentsValid =
        _medicalLicense != null && _idFront != null && _idBack != null;
    final agreementValid = _agreedToVerificationTerms;

    setState(() {
      _documentsError = documentsValid
          ? null
          : 'Upload the medical license and both sides of your ID.';
      _agreementError = agreementValid
          ? null
          : 'Accept the verification terms to continue.';
    });

    return fieldsValid && documentsValid && agreementValid;
  }

  Future<void> _showDocumentSourceSheet(_DocumentTarget target) async {
    if (_isLoading) return;

    final source = await showModalBottomSheet<_UploadSource>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final mediaQuery = MediaQuery.of(sheetContext);

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.90),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              24 + mediaQuery.viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Upload ${target.label}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose camera, gallery, or a document from your device.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted, height: 1.4),
                ),
                const SizedBox(height: 20),
                _SourceOption(
                  icon: Icons.camera_alt_outlined,
                  title: 'Take photo',
                  subtitle: 'Use the camera now',
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_UploadSource.camera),
                ),
                const SizedBox(height: 10),
                _SourceOption(
                  icon: Icons.photo_library_outlined,
                  title: 'Choose from gallery',
                  subtitle: 'Select an existing image',
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_UploadSource.gallery),
                ),
                const SizedBox(height: 10),
                _SourceOption(
                  icon: Icons.folder_open_outlined,
                  title: 'Browse media or files',
                  subtitle: target == _DocumentTarget.medicalLicense
                      ? 'JPG, PNG, or PDF up to 5 MB'
                      : 'JPG or PNG up to 5 MB',
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_UploadSource.files),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null || !mounted) return;

    try {
      final upload = switch (source) {
        _UploadSource.camera => await _pickImage(ImageSource.camera),
        _UploadSource.gallery => await _pickImage(ImageSource.gallery),
        _UploadSource.files => await _pickFile(target),
      };

      if (upload == null || !mounted) return;
      setState(() {
        switch (target) {
          case _DocumentTarget.medicalLicense:
            _medicalLicense = upload;
            break;
          case _DocumentTarget.idFront:
            _idFront = upload;
            break;
          case _DocumentTarget.idBack:
            _idBack = upload;
            break;
        }
        _documentsError = null;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not upload the document: $error')),
      );
    }
  }

  Future<RegistrationUpload?> _pickImage(ImageSource source) async {
    final file = await _imagePicker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 2200,
      requestFullMetadata: false,
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    return _validateAndCreateUpload(
      name: file.name.isEmpty ? 'captured_document.jpg' : file.name,
      bytes: bytes,
    );
  }

  Future<RegistrationUpload?> _pickFile(_DocumentTarget target) async {
    final allowPdf = target == _DocumentTarget.medicalLicense;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowPdf
          ? const ['jpg', 'jpeg', 'png', 'pdf']
          : const ['jpg', 'jpeg', 'png'],
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      throw const FormatException('The selected file could not be read.');
    }
    return _validateAndCreateUpload(
      name: file.name,
      bytes: bytes,
      allowPdf: allowPdf,
    );
  }

  RegistrationUpload _validateAndCreateUpload({
    required String name,
    required Uint8List bytes,
    bool allowPdf = false,
  }) {
    const maxBytes = 5 * 1024 * 1024;
    if (bytes.isEmpty) {
      throw const FormatException('The selected file is empty.');
    }
    if (bytes.length > maxBytes) {
      throw const FormatException('File size must be 5 MB or less.');
    }

    final extension = name.contains('.')
        ? name.split('.').last.toLowerCase()
        : 'jpg';
    final normalizedExtension = extension == 'jpeg' ? 'jpg' : extension;
    final allowed = allowPdf
        ? const {'jpg', 'png', 'pdf'}
        : const {'jpg', 'png'};
    if (!allowed.contains(normalizedExtension)) {
      throw FormatException(
        allowPdf
            ? 'Only JPG, PNG, and PDF files are allowed.'
            : 'Only JPG and PNG images are allowed.',
      );
    }

    if (!_matchesFileSignature(bytes, normalizedExtension)) {
      throw const FormatException(
        'The file content does not match its extension.',
      );
    }

    final safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9._ -]'), '_').trim();
    return RegistrationUpload(
      name: safeName.isEmpty
          ? 'verification_document.$normalizedExtension'
          : safeName,
      bytes: bytes,
      extension: normalizedExtension,
    );
  }

  bool _matchesFileSignature(Uint8List bytes, String extension) {
    bool startsWith(List<int> signature) {
      if (bytes.length < signature.length) return false;
      for (var index = 0; index < signature.length; index++) {
        if (bytes[index] != signature[index]) return false;
      }
      return true;
    }

    return switch (extension) {
      'jpg' => startsWith(const [0xFF, 0xD8, 0xFF]),
      'png' => startsWith(const [
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
      ]),
      'pdf' => startsWith(const [0x25, 0x50, 0x44, 0x46]),
      _ => false,
    };
  }

  Future<void> _showIdSideSheet() async {
    if (_isLoading) return;

    final target = await showModalBottomSheet<_DocumentTarget>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ID / Certificate',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Both front and back images are required.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted),
              ),
              const SizedBox(height: 20),
              _DocumentSideOption(
                title: 'Front side',
                upload: _idFront,
                onTap: () =>
                    Navigator.of(sheetContext).pop(_DocumentTarget.idFront),
              ),
              const SizedBox(height: 10),
              _DocumentSideOption(
                title: 'Back side',
                upload: _idBack,
                onTap: () =>
                    Navigator.of(sheetContext).pop(_DocumentTarget.idBack),
              ),
            ],
          ),
        );
      },
    );

    if (target == null || !mounted) return;
    await _showDocumentSourceSheet(target);
  }

  Future<bool> _submitProfessionalRegistration() async {
    if (_isLoading || !_validateProfessionalForm()) return false;

    final stepOne = _stepOneData;
    if (stepOne == null) return false;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmittingProfessional = true);

    try {
      final payload = DoctorRegistrationPayload(
        fullName: stepOne.fullName,
        email: stepOne.email,
        phone: stepOne.phone,
        password: stepOne.password,
        gender: stepOne.gender,
        specialty: _specialty!,
        pmdcOrLicenseNumber: _pmdcController.text.trim(),
        yearsOfExperience: int.parse(_experienceController.text.trim()),
        hospitalOrClinicName: _clinicController.text.trim(),
        consultationFeePkr: int.parse(_feeController.text.trim()),
        medicalLicense: _medicalLicense!,
        idFront: _idFront!,
        idBack: _idBack!,
      );

      final submitter = widget.onRegisterDoctor;
      final success = submitter != null
          ? await submitter(payload)
          : await widget.authController.registerPatient(
              fullName: payload.fullName,
              emailOrPhone: payload.email,
              password: payload.password,
            );

      if (!mounted) return success;
      if (!success) {
        final message =
            widget.authController.errorMessage ??
            'Registration failed. Check your information and try again.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        return false;
      }

      setState(() => _showSuccessOverlay = true);

      // Keep the success state visible long enough to be understood, then
      // clear the registration route from the navigation stack.
      await Future<void>.delayed(const Duration(milliseconds: 1900));
      if (!mounted) return true;

      if (widget.onRegisterDoctor != null) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
      return true;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration failed: $error')));
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSubmittingProfessional = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.authController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF006A70),
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF064E55),
                        Color(0xFF00848A),
                        Color(0xFF00636A),
                      ],
                      stops: [0.0, 0.52, 1.0],
                    ),
                  ),
                  child: SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return ScrollConfiguration(
                          behavior: const AuthInvisibleScrollBehavior(),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  16,
                                  28,
                                  16,
                                  24 + MediaQuery.paddingOf(context).bottom,
                                ),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 860,
                                    ),
                                    child: Column(
                                      children: [
                                        _buildCard(context),
                                        const SizedBox(height: 18),
                                        _TermsText(
                                          actionLabel: _currentStep == 1
                                              ? 'Next'
                                              : 'Create Account',
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
                ),
              ),
              Positioned.fill(
                child: AuthVerificationOverlay(
                  visible: _showSuccessOverlay,
                  title: 'Account created',
                  message:
                      'Your professional documents were submitted for review. '
                      'Redirecting you to sign in.',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth >= 700
        ? 72.0
        : screenWidth >= 480
        ? 40.0
        : 22.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(screenWidth < 480 ? 42 : 68),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26002F33),
            blurRadius: 42,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          screenWidth < 480 ? 40 : 68,
          horizontalPadding,
          screenWidth < 480 ? 36 : 58,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.025, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: _currentStep == 1
              ? KeyedSubtree(
                  key: const ValueKey<int>(1),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _RegistrationHeader(),
                        const SizedBox(height: 34),
                        _RegistrationField(
                          controller: _fullNameController,
                          focusNode: _fullNameFocus,
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          icon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                          validator: _validateFullName,
                          enabled: !_isLoading,
                        ),
                        _RegistrationField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          label: 'Email',
                          hint: 'Enter your email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          validator: _validateEmail,
                          enabled: !_isLoading,
                        ),
                        _RegistrationField(
                          controller: _phoneController,
                          focusNode: _phoneFocus,
                          label: 'Phone Number',
                          hint: 'Enter your phone number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          validator: _validatePhone,
                          enabled: !_isLoading,
                        ),
                        _RegistrationField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          label: 'Password',
                          hint: 'Enter your password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          validator: _validatePassword,
                          enabled: !_isLoading,
                          suffix: _PasswordToggle(
                            obscured: _obscurePassword,
                            enabled: !_isLoading,
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                        ),
                        _RegistrationField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocus,
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          validator: _validateConfirmPassword,
                          enabled: !_isLoading,
                          suffix: _PasswordToggle(
                            obscured: _obscureConfirmPassword,
                            enabled: !_isLoading,
                            onPressed: () {
                              setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                              );
                            },
                          ),
                        ),
                        _GenderDropdown(
                          value: _gender,
                          focusNode: _genderFocus,
                          enabled: !_isLoading,
                          errorText: _genderError,
                          onChanged: (value) => setState(() {
                            _gender = value;
                            _genderError = null;
                          }),
                        ),
                        const SizedBox(height: 22),
                        Center(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            alignment: WrapAlignment.center,
                            children: [
                              const Text(
                                'Already have an account?',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 15,
                                ),
                              ),
                              TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : widget.onSignIn ??
                                          () => Navigator.of(context)
                                              .pushReplacementNamed(
                                                AppRoutes.login,
                                              ),
                                child: const Text('Sign In'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        SwipeNextControl(
                          loading: _isLoading,
                          onComplete: handleNextStep,
                        ),
                      ],
                    ),
                  ),
                )
              : KeyedSubtree(
                  key: const ValueKey<int>(2),
                  child: _buildStepTwo(),
                ),
        ),
      ),
    );
  }

  Widget _buildStepTwo() {
    return Form(
      key: _professionalFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ProfessionalHeader(),
          const SizedBox(height: 34),
          _ProfessionalDropdown(
            value: _specialty,
            enabled: !_isLoading,
            onChanged: (value) => setState(() => _specialty = value),
          ),
          _RegistrationField(
            controller: _pmdcController,
            label: 'PMDC / License Number',
            hint: 'Enter your PMDC / License number',
            icon: Icons.badge_outlined,
            textInputAction: TextInputAction.next,
            validator: (value) => _validateRequiredProfessionalField(
              value,
              'PMDC / license number',
            ),
            enabled: !_isLoading,
          ),
          _RegistrationField(
            controller: _experienceController,
            label: 'Years of Experience',
            hint: 'Enter years of experience',
            icon: Icons.work_outline_rounded,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: _validateExperience,
            enabled: !_isLoading,
          ),
          _RegistrationField(
            controller: _clinicController,
            label: 'Hospital / Clinic Name',
            hint: 'Enter hospital or clinic name',
            icon: Icons.local_hospital_outlined,
            textInputAction: TextInputAction.next,
            validator: (value) => _validateRequiredProfessionalField(
              value,
              'hospital or clinic name',
            ),
            enabled: !_isLoading,
          ),
          _RegistrationField(
            controller: _feeController,
            label: 'Consultation Fee (PKR)',
            hint: 'Enter consultation fee',
            icon: Icons.currency_rupee_rounded,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: _validateFee,
            enabled: !_isLoading,
          ),
          const Text(
            'Upload Documents',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 330;
              final tileWidth = stacked
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 14) / 2;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  SizedBox(
                    width: tileWidth,
                    child: _DocumentUploadTile(
                      title: 'Medical License',
                      emptySubtitle: 'Upload your license',
                      uploadedSubtitle: _medicalLicense?.name,
                      completed: _medicalLicense != null,
                      onTap: _isLoading
                          ? null
                          : () => _showDocumentSourceSheet(
                              _DocumentTarget.medicalLicense,
                            ),
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _DocumentUploadTile(
                      title: 'ID / Certificate',
                      emptySubtitle: 'Upload front and back',
                      uploadedSubtitle: _idFront != null && _idBack != null
                          ? 'Front and back uploaded'
                          : _idFront != null
                          ? 'Front uploaded • back required'
                          : _idBack != null
                          ? 'Back uploaded • front required'
                          : null,
                      completed: _idFront != null && _idBack != null,
                      onTap: _isLoading ? null : _showIdSideSheet,
                    ),
                  ),
                ],
              );
            },
          ),
          if (_documentsError != null) ...[
            const SizedBox(height: 8),
            Text(
              _documentsError!,
              style: const TextStyle(color: AppTheme.danger, fontSize: 12),
            ),
          ],
          const SizedBox(height: 22),
          InkWell(
            onTap: _isLoading
                ? null
                : () => setState(() {
                    _agreedToVerificationTerms = !_agreedToVerificationTerms;
                    _agreementError = null;
                  }),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _agreedToVerificationTerms,
                    onChanged: _isLoading
                        ? null
                        : (value) => setState(() {
                            _agreedToVerificationTerms = value ?? false;
                            _agreementError = null;
                          }),
                    activeColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'I agree to the ',
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 15,
                        ),
                        children: [
                          TextSpan(
                            text: 'verification terms',
                            style: TextStyle(
                              color: AppTheme.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_agreementError != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 2),
              child: Text(
                _agreementError!,
                style: const TextStyle(color: AppTheme.danger, fontSize: 12),
              ),
            ),
          const SizedBox(height: 24),
          SwipeNextControl(
            loading: _isLoading,
            label: 'Create Account',
            semanticLabel: 'Swipe to create your doctor account',
            onComplete: _submitProfessionalRegistration,
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      FocusScope.of(context).unfocus();
                      setState(() => _currentStep = 1);
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _scrollToTop(),
                      );
                    },
              style: TextButton.styleFrom(
                textStyle: const TextStyle(
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                ),
              ),
              child: const Text('Back'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A9998), Color(0xFF00656B)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22005B5F),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.emergency_rounded,
        color: AppTheme.textLight,
        size: 54,
      ),
    );
  }
}

class _GenderDropdown extends StatelessWidget {
  const _GenderDropdown({
    required this.value,
    required this.focusNode,
    required this.enabled,
    required this.errorText,
    required this.onChanged,
  });

  final String? value;
  final FocusNode focusNode;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    const genders = ['Male', 'Female', 'Other'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
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
          DropdownButtonFormField<String>(
            initialValue: value,
            focusNode: focusNode,
            isExpanded: true,
            borderRadius: BorderRadius.circular(18),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.textDark,
              size: 30,
            ),
            hint: const Text('Select your gender'),
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              errorText: errorText,
              contentPadding: const EdgeInsets.fromLTRB(18, 19, 16, 19),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: AppTheme.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppTheme.danger),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: AppTheme.danger,
                  width: 1.5,
                ),
              ),
            ),
            items: genders
                .map(
                  (gender) => DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  ),
                )
                .toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

class _RegistrationHeader extends StatelessWidget {
  const _RegistrationHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _BrandMark(),
        const SizedBox(height: 28),
        Text(
          'Create Account',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: math.min(MediaQuery.sizeOf(context).width * 0.075, 38),
            height: 1.1,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: const Text(
            'Create your patient account to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 17,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 9),
          decoration: BoxDecoration(
            color: AppTheme.softTeal,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Step 1 of 2',
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfessionalHeader extends StatelessWidget {
  const _ProfessionalHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _BrandMark(),
        const SizedBox(height: 28),
        Text(
          'Professional Details',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: math.min(MediaQuery.sizeOf(context).width * 0.075, 38),
            height: 1.1,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Complete your profile for verification.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 17,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 9),
          decoration: BoxDecoration(
            color: AppTheme.softTeal,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'Step 2 of 2',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfessionalDropdown extends StatelessWidget {
  const _ProfessionalDropdown({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  static const _specialties = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Gynecologist',
    'Pediatrician',
    'Dentist',
    'Neurologist',
    'Orthopedic Surgeon',
    'Psychiatrist',
    'ENT Specialist',
    'Ophthalmologist',
    'Urologist',
    'Endocrinologist',
    'Pulmonologist',
    'Gastroenterologist',
  ];

  final String? value;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Specialty',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.primaryDark,
            ),
            hint: const Text('Select your specialty'),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.medical_services_outlined,
                color: AppTheme.primary,
                size: 25,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 19,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: AppTheme.primary,
                  width: 1.5,
                ),
              ),
            ),
            items: _specialties
                .map(
                  (specialty) => DropdownMenuItem<String>(
                    value: specialty,
                    child: Text(specialty),
                  ),
                )
                .toList(),
            onChanged: enabled ? onChanged : null,
            validator: (selected) =>
                selected == null ? 'Select your specialty.' : null,
          ),
        ],
      ),
    );
  }
}

class _RegistrationField extends StatelessWidget {
  const _RegistrationField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    required this.enabled,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String hint;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            inputFormatters: inputFormatters,
            obscureText: obscureText,
            validator: validator,
            style: const TextStyle(color: AppTheme.textDark, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 16,
              ),
              prefixIcon: Icon(icon, color: AppTheme.primary, size: 25),
              suffixIcon: suffix,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 19,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: AppTheme.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppTheme.danger),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: AppTheme.danger,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordToggle extends StatelessWidget {
  const _PasswordToggle({
    required this.obscured,
    required this.enabled,
    required this.onPressed,
  });

  final bool obscured;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onPressed : null,
      tooltip: obscured ? 'Show password' : 'Hide password',
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
    );
  }
}

class _RegistrationStepOneData {
  const _RegistrationStepOneData({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.gender,
  });

  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String gender;

  bool get hasPassword => password.isNotEmpty;
}

class SwipeNextControl extends StatefulWidget {
  const SwipeNextControl({
    super.key,
    required this.onComplete,
    required this.loading,
    this.label = 'Next',
    this.semanticLabel = 'Swipe to continue',
  });

  final Future<bool> Function() onComplete;
  final bool loading;
  final String label;
  final String semanticLabel;

  @override
  State<SwipeNextControl> createState() => _SwipeNextControlState();
}

class _SwipeNextControlState extends State<SwipeNextControl> {
  static const _trackHeight = 72.0;
  static const _handleSize = 62.0;
  static const _inset = 5.0;
  static const _completionThreshold = 0.88;

  final _focusNode = FocusNode(debugLabel: 'Swipe to continue');
  double _position = 0;
  double _maxMovement = 0;
  double _dragStartX = 0;
  double _dragStartPosition = 0;
  bool _dragging = false;
  bool _submitting = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  double get _progress =>
      _maxMovement <= 0 ? 0 : (_position / _maxMovement).clamp(0.0, 1.0);

  void resetSwipe() {
    if (!mounted) return;
    setState(() {
      _position = 0;
      _dragging = false;
      _submitting = false;
    });
  }

  void _updateBounds(double width) {
    final nextMax = math.max(0.0, width - _handleSize - (_inset * 2));
    if ((_maxMovement - nextMax).abs() < 0.5) return;
    _maxMovement = nextMax;
    _position = _position.clamp(0.0, _maxMovement);
  }

  void _onPointerDown(PointerDownEvent event) {
    if (widget.loading || _submitting) return;
    setState(() {
      _dragging = true;
      _dragStartX = event.position.dx;
      _dragStartPosition = _position;
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_dragging || widget.loading || _submitting) return;
    final movement = event.position.dx - _dragStartX;
    setState(() {
      _position = (_dragStartPosition + movement).clamp(0.0, _maxMovement);
    });
  }

  void _onPointerUp(PointerEvent event) {
    if (!_dragging) return;
    setState(() => _dragging = false);
    if (_progress >= _completionThreshold) {
      _complete();
    } else {
      resetSwipe();
    }
  }

  Future<void> _complete() async {
    if (widget.loading || _submitting) return;
    setState(() {
      _position = _maxMovement;
      _submitting = true;
    });
    final success = await widget.onComplete();
    if (!mounted) return;
    if (!success) {
      resetSwipe();
      return;
    }
    setState(() => _submitting = false);
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent || widget.loading || _submitting) return;
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      _complete();
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      resetSwipe();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 260);

    return LayoutBuilder(
      builder: (context, constraints) {
        _updateBounds(constraints.maxWidth);
        final disabled = widget.loading || _submitting;
        return Semantics(
          slider: true,
          enabled: !disabled,
          label: widget.semanticLabel,
          value: '${(_progress * 100).round()}',
          increasedValue: '100',
          decreasedValue: '0',
          onIncrease: disabled ? null : _complete,
          onDecrease: disabled ? null : resetSwipe,
          child: KeyboardListener(
            focusNode: _focusNode,
            onKeyEvent: _onKeyEvent,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
              onPointerCancel: (_) => resetSwipe(),
              child: Container(
                height: _trackHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: disabled
                        ? const [Color(0xAA075B5F), Color(0xAA00858A)]
                        : const [Color(0xFF075B5F), Color(0xFF00858A)],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22005B5F),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: _inset + _handleSize + _position,
                      child: ColoredBox(
                        color: AppTheme.textLight.withValues(alpha: 0.10),
                      ),
                    ),
                    Center(
                      child: AnimatedOpacity(
                        opacity: _dragging ? 0.55 : 1,
                        duration: const Duration(milliseconds: 120),
                        child: disabled
                            ? const SizedBox.square(
                                dimension: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppTheme.textLight,
                                ),
                              )
                            : Text(
                                widget.label,
                                style: const TextStyle(
                                  color: AppTheme.textLight,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: _dragging ? Duration.zero : duration,
                      curve: Curves.easeOutCubic,
                      left: _inset + _position,
                      top: _inset,
                      child: Semantics(
                        excludeSemantics: true,
                        child: Container(
                          width: _handleSize,
                          height: _handleSize,
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primary,
                              width: 2,
                            ),
                            boxShadow: const [
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TermsText extends StatelessWidget {
  const _TermsText({required this.actionLabel});

  final String actionLabel;

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
        Text(
          'By clicking “$actionLabel”, I have read and agree with the ',
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

typedef DoctorRegistrationSubmitter =
    Future<bool> Function(DoctorRegistrationPayload payload);

enum _UploadSource { camera, gallery, files }

enum _DocumentTarget {
  medicalLicense('Medical License'),
  idFront('ID Front Side'),
  idBack('ID Back Side');

  const _DocumentTarget(this.label);
  final String label;
}

class _DocumentUploadTile extends StatelessWidget {
  const _DocumentUploadTile({
    required this.title,
    required this.emptySubtitle,
    required this.uploadedSubtitle,
    required this.completed,
    required this.onTap,
  });

  final String title;
  final String emptySubtitle;
  final String? uploadedSubtitle;
  final bool completed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = completed ? AppTheme.primary : AppTheme.border;

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: completed ? '$title uploaded' : 'Upload $title',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: CustomPaint(
          painter: completed
              ? null
              : _DashedRoundedBorderPainter(color: borderColor, radius: 18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 142),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            decoration: BoxDecoration(
              color: completed ? AppTheme.softTeal : AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: completed
                  ? Border.all(color: borderColor, width: 1.4)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  completed
                      ? Icons.check_circle_rounded
                      : Icons.cloud_upload_outlined,
                  color: AppTheme.primary,
                  size: 38,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  uploadedSubtitle ?? emptySubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: completed ? AppTheme.primary : AppTheme.textMuted,
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: completed ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  const _DashedRoundedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const dashLength = 6.0;
    const gapLength = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceTint,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppTheme.softTeal,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _DocumentSideOption extends StatelessWidget {
  const _DocumentSideOption({
    required this.title,
    required this.upload,
    required this.onTap,
  });

  final String title;
  final RegistrationUpload? upload;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = upload != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.softTeal : AppTheme.surfaceTint,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.badge_outlined,
              color: AppTheme.primary,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    upload?.name ?? 'Not uploaded',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              selected ? 'Replace' : 'Upload',
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
