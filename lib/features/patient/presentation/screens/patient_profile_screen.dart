import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

import '../widgets/patient_profile_widgets.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  bool _notificationsEnabled = true;
  String _language = 'English';

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _selectLanguage() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Choose language',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              ListTile(
                title: const Text('English'),
                trailing: _language == 'English'
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.of(context).pop('English'),
              ),
              ListTile(
                title: const Text('Urdu'),
                trailing: _language == 'Urdu'
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.of(context).pop('Urdu'),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null || selected == _language) return;
    setState(() => _language = selected);

    if (selected == 'Urdu') {
      _showMessage(
        'Urdu selected. Full app translation will be connected in the localization phase.',
      );
    }
  }

  Future<void> _showAccountDetails() async {
    final user = widget.authController.currentUser;
    if (user == null) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Account information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileDialogField(label: 'Full name', value: user.fullName),
              const SizedBox(height: 14),
              ProfileDialogField(
                label: 'Email or phone',
                value: user.emailOrPhone,
              ),
              const SizedBox(height: 14),
              ProfileDialogField(label: 'Account type', value: 'Patient'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text(
            'Your local session, cart, favorites, and active pharmacy order will be cleared.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    await widget.authController.logout();
    if (!mounted) return;

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.authController,
      builder: (context, child) {
        final user = widget.authController.currentUser;

        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: const Center(child: Text('No signed-in patient was found.')),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F8FA),
          appBar: AppBar(
            title: const Text('Profile & Settings'),
            centerTitle: false,
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                PatientProfileHeader(
                  fullName: user.fullName,
                  identity: user.emailOrPhone,
                ),
                const SizedBox(height: 20),
                const ProfileSectionTitle('Account'),
                const SizedBox(height: 8),
                ProfileSettingsCard(
                  children: [
                    ProfileSettingsTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal information',
                      subtitle: 'Name, email or phone, account type',
                      onTap: _showAccountDetails,
                    ),
                    ProfileSettingsTile(
                      icon: Icons.calendar_month_outlined,
                      title: 'My appointments',
                      subtitle: 'Upcoming and previous consultations',
                      onTap: () => _showMessage(
                        'Appointments list will be connected to the appointment repository.',
                      ),
                    ),
                    ProfileSettingsTile(
                      icon: Icons.folder_copy_outlined,
                      title: 'Medical records',
                      subtitle: 'Prescriptions and uploaded documents',
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.medicalRecords),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const ProfileSectionTitle('Settings'),
                const SizedBox(height: 8),
                ProfileSettingsCard(
                  children: [
                    SwitchListTile.adaptive(
                      secondary: const Icon(Icons.notifications_outlined),
                      title: const Text(
                        'Notifications',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        _notificationsEnabled
                            ? 'Appointment and medicine alerts enabled'
                            : 'Notifications disabled for this session',
                      ),
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                      },
                    ),
                    ProfileSettingsTile(
                      icon: Icons.language_outlined,
                      title: 'Language',
                      subtitle: _language,
                      onTap: _selectLanguage,
                    ),
                    ProfileSettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Password & security',
                      subtitle: 'Password reset and active sessions',
                      onTap: () => _showMessage(
                        'Password reset requires the backend email or OTP endpoint.',
                      ),
                    ),
                    ProfileSettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy & support',
                      subtitle: 'Privacy controls and help',
                      onTap: () => _showMessage(
                        'Privacy policy and support contact will be added before production release.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: widget.authController.isLoading
                        ? null
                        : _confirmLogout,
                    icon: widget.authController.isLoading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout_rounded),
                    label: const Text(
                      'Log out',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB42318),
                      side: const BorderSide(color: Color(0xFFF2B8B5)),
                    ),
                  ),
                ),
                if (widget.authController.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.authController.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFB42318)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
