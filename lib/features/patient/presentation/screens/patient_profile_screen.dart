import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/user_initials.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

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

    if (!mounted || selected == null || selected == _language) return;
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
              _DialogField(label: 'Full name', value: user.fullName),
              const SizedBox(height: 14),
              _DialogField(label: 'Email or phone', value: user.emailOrPhone),
              const SizedBox(height: 14),
              _DialogField(label: 'Account type', value: 'Patient'),
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
                _ProfileHeader(
                  fullName: user.fullName,
                  identity: user.emailOrPhone,
                ),
                const SizedBox(height: 20),
                const _SectionTitle('Account'),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal information',
                      subtitle: 'Name, email or phone, account type',
                      onTap: _showAccountDetails,
                    ),
                    _SettingsTile(
                      icon: Icons.calendar_month_outlined,
                      title: 'My appointments',
                      subtitle: 'Upcoming and previous consultations',
                      onTap: () => _showMessage(
                        'Appointments list will be connected to the appointment repository.',
                      ),
                    ),
                    _SettingsTile(
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
                const _SectionTitle('Settings'),
                const SizedBox(height: 8),
                _SettingsCard(
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
                    _SettingsTile(
                      icon: Icons.language_outlined,
                      title: 'Language',
                      subtitle: _language,
                      onTap: _selectLanguage,
                    ),
                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Password & security',
                      subtitle: 'Password reset and active sessions',
                      onTap: () => _showMessage(
                        'Password reset requires the backend email or OTP endpoint.',
                      ),
                    ),
                    _SettingsTile(
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.fullName, required this.identity});

  final String fullName;
  final String identity;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: const Color(0xFFD7F1EC),
              child: Text(
                UserInitials.fromName(fullName),
                style: const TextStyle(
                  color: Color(0xFF00796F),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    identity,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF667085)),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Patient account',
                    style: TextStyle(
                      color: Color(0xFF00796F),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
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
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
