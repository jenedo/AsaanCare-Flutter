import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/di/service_locator.dart';
import '../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/profile/data/datasources/doctor_profile_mock_data_source.dart';
import '../../features/profile/data/repositories/doctor_profile_repository_impl.dart';
import '../../features/profile/domain/entities/doctor_profile_state.dart';
import '../../features/profile/presentation/controllers/doctor_profile_controller.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({
    super.key,
    this.showBackButton = true,
    this.doctorId,
    this.controller,
  });

  final bool showBackButton;
  final String? doctorId;
  final DoctorProfileController? controller;

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  late final DoctorProfileController _controller =
      widget.controller ??
      (sl.isRegistered<DoctorProfileController>()
          ? sl<DoctorProfileController>()
          : DoctorProfileController(
              repository: DoctorProfileRepositoryImpl(
                dataSource: DoctorProfileMockDataSource(),
              ),
            ));

  DoctorProfileState get _profile => _controller.state;

  @override
  void initState() {
    super.initState();
    final authController = sl.isRegistered<AuthController>()
        ? sl<AuthController>()
        : null;
    final doctorId =
        widget.doctorId ?? authController?.currentUser?.id ?? 'doctor_demo';
    _controller.load(doctorId: doctorId);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        child: switch (_profile.page) {
          0 => _ProfileHome(
            key: const ValueKey('profile'),
            name: _profile.name,
            specialty: _profile.specialty,
            qualification: _profile.qualification,
            onEdit: _editProfile,
            onPublic: () => _infoSheet(
              'Public Profile Preview',
              _PublicPreview(
                name: _profile.name,
                specialty: _profile.specialty,
                fee: _profile.fee,
              ),
            ),
            onPractice: () => _setPage(1),
            onAccount: () => _setPage(2),
          ),
          1 => _PracticePage(
            key: const ValueKey('practice'),
            onBack: _back,
            specialty: _profile.specialty,
            qualification: _profile.qualification,
            clinic: _profile.clinic,
            address: _profile.address,
            fee: _profile.fee,
            days: _profile.days.toSet(),
            autoApprove: _profile.autoApprove,
            reschedule: _profile.reschedule,
            video: _profile.video,
            recordingConsent: _profile.recordingConsent,
            onProfessional: _editProfessional,
            onClinic: _editClinic,
            onFees: _editFees,
            onSchedule: _editSchedule,
            onPreferences: _editPreferences,
            onVideo: _editVideo,
          ),
          2 => _AccountPage(
            key: const ValueKey('account'),
            onBack: _back,
            phone: _profile.phone,
            email: _profile.email,
            language: _profile.language,
            appearance: _profile.appearance,
            bank: _profile.bank,
            onPersonal: _editProfile,
            onPhone: _editPhone,
            onEmail: _editEmail,
            onPassword: _changePassword,
            onDocuments: () => _infoSheet(
              'Verification Documents',
              const Column(
                children: [
                  _InfoLine(
                    icon: Icons.badge_outlined,
                    title: 'CNIC',
                    value: 'Approved',
                  ),
                  _InfoLine(
                    icon: Icons.medical_information_outlined,
                    title: 'PMDC certificate',
                    value: 'Approved',
                  ),
                  _InfoLine(
                    icon: Icons.local_hospital_outlined,
                    title: 'Clinic license',
                    value: 'Approved',
                  ),
                ],
              ),
            ),
            onPrivacy: _privacy,
            onBank: _editBank,
            onNotifications: _notifications,
            onLanguage: () => _optionSheet(
              'Language',
              ['English', 'Urdu'],
              _profile.language,
              _controller.saveLanguage,
            ),
            onAppearance: () => _optionSheet(
              'Appearance',
              ['System default', 'Light', 'Dark'],
              _profile.appearance,
              _controller.saveAppearance,
            ),
            onInfo: _supportInfo,
            onLogout: _logout,
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  void _setPage(int page) {
    HapticFeedback.lightImpact();
    _controller.setPage(page);
  }

  void _back() {
    if (_profile.page != 0) _setPage(0);
  }

  void _editProfile() {
    final name = TextEditingController(text: _profile.name);
    final specialty = TextEditingController(text: _profile.specialty);
    _formSheet(
      'Edit Profile',
      [_field('Doctor name', name), _field('Specialty', specialty)],
      () =>
          _controller.saveIdentity(name: name.text, specialty: specialty.text),
    );
  }

  void _editProfessional() {
    final specialty = TextEditingController(text: _profile.specialty);
    final qualification = TextEditingController(text: _profile.qualification);
    _formSheet(
      'Professional Information',
      [
        _field('Specialty', specialty),
        _field('Qualification', qualification),
        const _InfoLine(
          icon: Icons.verified,
          title: 'PMDC status',
          value: 'Verified',
        ),
      ],
      () => _controller.saveProfessional(
        specialty: specialty.text,
        qualification: qualification.text,
      ),
    );
  }

  void _editClinic() {
    final clinic = TextEditingController(text: _profile.clinic);
    final address = TextEditingController(text: _profile.address);
    _formSheet(
      'Clinic & Hospital',
      [_field('Clinic / hospital', clinic), _field('Address', address)],
      () => _controller.saveClinic(clinic: clinic.text, address: address.text),
    );
  }

  void _editFees() {
    final fee = TextEditingController(text: _profile.fee.toString());
    _formSheet(
      'Consultation Fees',
      [
        _field('Fee in PKR', fee, keyboardType: TextInputType.number),
        const Text(
          'Patients will see this fee before booking.',
          style: _Styles.muted,
        ),
      ],
      () {
        final value = int.tryParse(fee.text.trim());
        if (value != null && value > 0) {
          _controller.saveFee(value);
        }
      },
    );
  }

  void _editPhone() {
    final c = TextEditingController(text: _profile.phone);
    _formSheet('Phone Number', [
      _field('Phone number', c, keyboardType: TextInputType.phone),
    ], () => _controller.savePhone(c.text));
  }

  void _editEmail() {
    final c = TextEditingController(text: _profile.email);
    _formSheet('Email Address', [
      _field('Email address', c, keyboardType: TextInputType.emailAddress),
    ], () => _controller.saveEmail(c.text));
  }

  void _editBank() {
    final c = TextEditingController(text: _profile.bank);
    _formSheet('Bank & Payout Details', [
      _field('Bank account', c),
    ], () => _controller.saveBank(c.text));
  }

  void _changePassword() {
    final a = TextEditingController();
    final b = TextEditingController();
    _formSheet('Change Password', [
      _field('Current password', a, obscureText: true),
      _field('New password', b, obscureText: true),
    ], () {});
  }

  void _editSchedule() {
    final selected = Set<String>.from(_profile.days);
    _stateSheet(
      'Availability & Schedule',
      (context, setSheetState) {
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final day in days)
              FilterChip(
                label: Text(day),
                selected: selected.contains(day),
                selectedColor: _Colors.softTeal,
                checkmarkColor: _Colors.teal,
                onSelected: (v) => setSheetState(
                  () => v ? selected.add(day) : selected.remove(day),
                ),
              ),
          ],
        );
      },
      () => _controller.saveDays(selected.toList(growable: false)),
    );
  }

  void _editPreferences() {
    var auto = _profile.autoApprove;
    var reschedule = _profile.reschedule;
    _stateSheet(
      'Appointment Preferences',
      (context, setSheetState) => Column(
        children: [
          _switchTile(
            'Auto approve bookings',
            'Skip manual approval for appointments',
            auto,
            (v) => setSheetState(() => auto = v),
          ),
          _switchTile(
            'Allow reschedule requests',
            'Patients can request a new time',
            reschedule,
            (v) => setSheetState(() => reschedule = v),
          ),
        ],
      ),
      () => _controller.savePreferences(
        autoApprove: auto,
        reschedule: reschedule,
      ),
    );
  }

  void _editVideo() {
    var video = _profile.video;
    var consent = _profile.recordingConsent;
    _stateSheet(
      'Video Consultation Settings',
      (context, setSheetState) => Column(
        children: [
          _switchTile(
            'Enable video consultations',
            'Allow video appointments from patients',
            video,
            (v) => setSheetState(() => video = v),
          ),
          _switchTile(
            'Require recording consent',
            'Ask before saving consultation recordings',
            consent,
            (v) => setSheetState(() => consent = v),
          ),
        ],
      ),
      () => _controller.saveVideoSettings(
        video: video,
        recordingConsent: consent,
      ),
    );
  }

  void _privacy() {
    var two = _profile.twoFactor;
    var pub = _profile.public;
    _stateSheet(
      'Privacy & Security',
      (context, setSheetState) => Column(
        children: [
          _switchTile(
            'Two-factor authentication',
            'Extra security during sign in',
            two,
            (v) => setSheetState(() => two = v),
          ),
          _switchTile(
            'Public profile visible',
            'Patients can find your profile',
            pub,
            (v) => setSheetState(() => pub = v),
          ),
        ],
      ),
      () => _controller.savePrivacy(twoFactor: two, isPublic: pub),
    );
  }

  void _notifications() {
    var push = _profile.push;
    var sms = _profile.sms;
    _stateSheet(
      'Notifications',
      (context, setSheetState) => Column(
        children: [
          _switchTile(
            'Push notifications',
            'Appointment and payout alerts',
            push,
            (v) => setSheetState(() => push = v),
          ),
          _switchTile(
            'SMS alerts',
            'Receive booking alerts on phone',
            sms,
            (v) => setSheetState(() => sms = v),
          ),
        ],
      ),
      () => _controller.saveNotifications(push: push, sms: sms),
    );
  }

  void _supportInfo(String title) {
    final body = switch (title) {
      'Help & support' =>
        'Contact support at support@asaancare.example or call 021-111-ASAN.',
      'Terms & conditions' =>
        'Consultation, payout, cancellation, and platform usage terms are available here.',
      'Privacy policy' =>
        'Control how your profile, payout, patient, and security data is handled.',
      _ => 'AsaanCare Doctor app\nVersion 1.0.0',
    };
    _infoSheet(title, Text(body, style: _Styles.muted));
  }

  void _logout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out'),
        content: const Text(
          'Are you sure you want to log out of your doctor account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (sl.isRegistered<AuthController>()) {
                await sl<AuthController>().logout();
              }
              if (mounted) {
                _saved('Logged out successfully');
              }
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool obscureText = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: _Colors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
  Widget _switchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title, style: _Styles.tileTitle),
    subtitle: Text(subtitle, style: _Styles.muted),
    value: value,
    activeThumbColor: _Colors.teal,
    onChanged: onChanged,
  );
  void _formSheet(String title, List<Widget> children, VoidCallback onSave) =>
      _stateSheet(
        title,
        (context, setSheetState) => Column(children: children),
        onSave,
      );
  void _optionSheet(
    String title,
    List<String> options,
    String selected,
    ValueChanged<String> onPick,
  ) {
    var choice = selected;
    _stateSheet(
      title,
      (context, setSheetState) => Column(
        children: [
          for (final option in options)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(option),
              trailing: choice == option
                  ? const Icon(Icons.check_circle, color: _Colors.teal)
                  : const Icon(Icons.circle_outlined, color: _Colors.muted),
              onTap: () => setSheetState(() => choice = option),
            ),
        ],
      ),
      () => onPick(choice),
    );
  }

  void _infoSheet(String title, Widget child) =>
      _stateSheet(title, (context, setSheetState) => child, () {});
  void _stateSheet(
    String title,
    Widget Function(BuildContext, StateSetter) builder,
    VoidCallback onSave,
  ) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => _SheetScaffold(
          title: title,
          onSave: () {
            onSave();
            Navigator.pop(sheetContext);
            _saved('$title saved');
          },
          child: builder(context, setSheetState),
        ),
      ),
    );
  }

  void _saved(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}

class _ProfileHome extends StatelessWidget {
  const _ProfileHome({
    super.key,
    required this.name,
    required this.specialty,
    required this.qualification,
    required this.onEdit,
    required this.onPublic,
    required this.onPractice,
    required this.onAccount,
  });
  final String name, specialty, qualification;
  final VoidCallback onEdit, onPublic, onPractice, onAccount;
  @override
  Widget build(BuildContext context) => _ProfileScaffold(
    title: 'Profile',
    showNotification: true,
    child: Column(
      children: [
        _ProfileCard(
          name: name,
          specialty: specialty,
          qualification: qualification,
          onEdit: onEdit,
        ),
        const SizedBox(height: 14),
        const _StatsCard(),
        const SizedBox(height: 14),
        _ActionTile(
          icon: Icons.visibility_outlined,
          title: 'View public profile',
          subtitle: 'See what patients can view',
          onTap: onPublic,
        ),
        const SizedBox(height: 12),
        _FeatureTile(
          icon: Icons.medical_services_outlined,
          title: 'Practice Management',
          subtitle:
              'Manage your practice, fees, schedule and consultation settings',
          onTap: onPractice,
        ),
        const SizedBox(height: 12),
        _FeatureTile(
          icon: Icons.settings_outlined,
          title: 'Account & App Settings',
          subtitle: 'Manage your account, preferences and app settings',
          onTap: onAccount,
        ),
      ],
    ),
  );
}

class _PracticePage extends StatelessWidget {
  const _PracticePage({
    super.key,
    required this.onBack,
    required this.specialty,
    required this.qualification,
    required this.clinic,
    required this.address,
    required this.fee,
    required this.days,
    required this.autoApprove,
    required this.reschedule,
    required this.video,
    required this.recordingConsent,
    required this.onProfessional,
    required this.onClinic,
    required this.onFees,
    required this.onSchedule,
    required this.onPreferences,
    required this.onVideo,
  });
  final VoidCallback onBack,
      onProfessional,
      onClinic,
      onFees,
      onSchedule,
      onPreferences,
      onVideo;
  final String specialty, qualification, clinic, address;
  final int fee;
  final Set<String> days;
  final bool autoApprove, reschedule, video, recordingConsent;
  @override
  Widget build(BuildContext context) => _ProfileScaffold(
    title: 'Practice Management',
    onBack: onBack,
    child: Column(
      children: [
        _ActionTile(
          icon: Icons.person_outline,
          title: 'Professional information',
          subtitle: '$specialty - $qualification',
          onTap: onProfessional,
        ),
        const SizedBox(height: 12),
        _ActionTile(
          icon: Icons.local_hospital_outlined,
          title: 'Clinic & hospital',
          subtitle: '$clinic\n$address',
          onTap: onClinic,
        ),
        const SizedBox(height: 12),
        _ActionTile(
          icon: Icons.payments_outlined,
          title: 'Consultation fees',
          subtitle: 'PKR $fee',
          accent: true,
          onTap: onFees,
        ),
        const SizedBox(height: 12),
        _ActionTile(
          icon: Icons.calendar_month_outlined,
          title: 'Availability & schedule',
          subtitle: days.join('-'),
          accent: true,
          onTap: onSchedule,
        ),
        const SizedBox(height: 12),
        _ActionTile(
          icon: Icons.notifications_none_outlined,
          title: 'Appointment preferences',
          subtitle:
              '${autoApprove ? 'Auto approve' : 'Manual approval'} - ${reschedule ? 'Reschedule allowed' : 'No reschedule'}',
          onTap: onPreferences,
        ),
        const SizedBox(height: 12),
        _ActionTile(
          icon: Icons.videocam_outlined,
          title: 'Video consultation settings',
          subtitle:
              '${video ? 'Enabled' : 'Disabled'} - ${recordingConsent ? 'Consent required' : 'Standard consent'}',
          accent: video,
          onTap: onVideo,
        ),
      ],
    ),
  );
}

class _AccountPage extends StatelessWidget {
  const _AccountPage({
    super.key,
    required this.onBack,
    required this.phone,
    required this.email,
    required this.language,
    required this.appearance,
    required this.bank,
    required this.onPersonal,
    required this.onPhone,
    required this.onEmail,
    required this.onPassword,
    required this.onDocuments,
    required this.onPrivacy,
    required this.onBank,
    required this.onNotifications,
    required this.onLanguage,
    required this.onAppearance,
    required this.onInfo,
    required this.onLogout,
  });
  final VoidCallback onBack,
      onPersonal,
      onPhone,
      onEmail,
      onPassword,
      onDocuments,
      onPrivacy,
      onBank,
      onNotifications,
      onLanguage,
      onAppearance,
      onLogout;
  final String phone, email, language, appearance, bank;
  final ValueChanged<String> onInfo;
  @override
  Widget build(BuildContext context) => _ProfileScaffold(
    title: 'Account & Settings',
    onBack: onBack,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Personal'),
        _GroupedList(
          children: [
            _SettingsRow(
              icon: Icons.person_outline,
              title: 'Personal information',
              onTap: onPersonal,
            ),
            _SettingsRow(
              icon: Icons.phone_outlined,
              title: 'Phone number',
              value: phone,
              badge: 'Verified',
              onTap: onPhone,
            ),
            _SettingsRow(
              icon: Icons.email_outlined,
              title: 'Email address',
              value: email,
              badge: 'Verified',
              onTap: onEmail,
            ),
            _SettingsRow(
              icon: Icons.lock_outline,
              title: 'Change password',
              onTap: onPassword,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _SectionLabel('Privacy & Security'),
        _GroupedList(
          children: [
            _SettingsRow(
              icon: Icons.description_outlined,
              title: 'Verification documents',
              badge: 'Approved',
              onTap: onDocuments,
            ),
            _SettingsRow(
              icon: Icons.shield_outlined,
              title: 'Privacy & security',
              onTap: onPrivacy,
            ),
            _SettingsRow(
              icon: Icons.account_balance_outlined,
              title: 'Bank & payout details',
              value: bank,
              onTap: onBank,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _SectionLabel('App Settings'),
        _GroupedList(
          children: [
            _SettingsRow(
              icon: Icons.notifications_none_outlined,
              title: 'Notifications',
              onTap: onNotifications,
            ),
            _SettingsRow(
              icon: Icons.language,
              title: 'Language',
              value: language,
              onTap: onLanguage,
            ),
            _SettingsRow(
              icon: Icons.palette_outlined,
              title: 'Appearance',
              value: appearance,
              onTap: onAppearance,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _SectionLabel('Support'),
        _GroupedList(
          children: [
            _SettingsRow(
              icon: Icons.help_outline,
              title: 'Help & support',
              onTap: () => onInfo('Help & support'),
            ),
            _SettingsRow(
              icon: Icons.description_outlined,
              title: 'Terms & conditions',
              onTap: () => onInfo('Terms & conditions'),
            ),
            _SettingsRow(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy policy',
              onTap: () => onInfo('Privacy policy'),
            ),
            _SettingsRow(
              icon: Icons.info_outline,
              title: 'About AsaanCare',
              onTap: () => onInfo('About AsaanCare'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout, color: _Colors.red),
            label: const Text(
              'Log out',
              style: TextStyle(color: _Colors.red, fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ProfileScaffold extends StatelessWidget {
  const _ProfileScaffold({
    required this.title,
    required this.child,
    this.onBack,
    this.showNotification = false,
  });

  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final bool showNotification;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_Colors.teal, _Colors.darkTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 34),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  if (onBack != null)
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    )
                  else
                    const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: _Styles.appBar,
                      textAlign: onBack == null
                          ? TextAlign.left
                          : TextAlign.center,
                    ),
                  ),
                  if (showNotification)
                    Stack(
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                        Positioned(
                          right: 1,
                          top: 1,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -20),
            child: Container(
              decoration: const BoxDecoration(
                color: _Colors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.specialty,
    required this.qualification,
    required this.onEdit,
  });
  final String name, specialty, qualification;
  final VoidCallback onEdit;
  @override
  Widget build(BuildContext context) => _Surface(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: _Colors.softTeal,
              backgroundImage: AssetImage('assets/images/doctor_ali.png'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: _Styles.name),
                  const SizedBox(height: 4),
                  Text('$specialty\n$qualification', style: _Styles.body),
                  const SizedBox(height: 10),
                  const _Badge('PMDC Verified', icon: Icons.verified),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _ProfileCompletion(onEdit: onEdit),
      ],
    ),
  );
}

class _ProfileCompletion extends StatelessWidget {
  const _ProfileCompletion({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    const percentage = Text(
      '85%',
      style: TextStyle(
        color: _Colors.teal,
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
    const progress = LinearProgressIndicator(
      value: 0.85,
      minHeight: 6,
      borderRadius: BorderRadius.all(Radius.circular(99)),
      color: _Colors.teal,
      backgroundColor: Color(0xFFD7EEF0),
    );
    final edit = OutlinedButton.icon(
      onPressed: onEdit,
      icon: const Icon(Icons.edit_outlined, size: 18),
      label: const Text('Edit profile'),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  percentage,
                  SizedBox(width: 8),
                  Expanded(child: progress),
                ],
              ),
              const SizedBox(height: 10),
              edit,
            ],
          );
        }
        return Row(
          children: [
            percentage,
            const SizedBox(width: 8),
            const Expanded(child: progress),
            const SizedBox(width: 12),
            edit,
          ],
        );
      },
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard();
  @override
  Widget build(BuildContext context) => const _Surface(
    child: Row(
      children: [
        _Stat(icon: Icons.star_border, label: 'Rating', value: '4.8'),
        _Divider(),
        _Stat(icon: Icons.work_outline, label: 'Experience', value: '8 years'),
        _Divider(),
        _Stat(icon: Icons.groups_outlined, label: 'Patients', value: '2.5k+'),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: _Colors.text),
        const SizedBox(height: 6),
        Text(label, style: _Styles.muted),
        const SizedBox(height: 3),
        Text(value, style: _Styles.tileTitle),
      ],
    ),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 54, color: _Colors.divider);
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent = false,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final bool accent;
  @override
  Widget build(BuildContext context) => _Surface(
    padding: EdgeInsets.zero,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      leading: _IconBox(icon: icon, filled: false),
      title: Text(title, style: _Styles.tileTitle),
      subtitle: Text(
        subtitle,
        style: accent
            ? _Styles.muted.copyWith(
                color: _Colors.teal,
                fontWeight: FontWeight.w700,
              )
            : _Styles.muted,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    ),
  );
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => _Surface(
    padding: EdgeInsets.zero,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      leading: _IconBox(icon: icon, filled: true),
      title: Text(title, style: _Styles.tileTitle),
      subtitle: Text(subtitle, style: _Styles.muted),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    ),
  );
}

class _GroupedList extends StatelessWidget {
  const _GroupedList({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => _Surface(
    padding: EdgeInsets.zero,
    child: Column(children: children),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
    this.badge,
  });
  final IconData icon;
  final String title;
  final String? value, badge;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    leading: Icon(icon, color: _Colors.teal),
    title: Text(title, style: _Styles.tileTitle),
    subtitle: value == null
        ? null
        : Text(
            value!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _Styles.muted,
          ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (badge != null) _Badge(badge!),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, size: 20),
      ],
    ),
    onTap: () {
      HapticFeedback.lightImpact();
      onTap();
    },
  );
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.filled});
  final IconData icon;
  final bool filled;
  @override
  Widget build(BuildContext context) => Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: filled ? _Colors.teal : _Colors.softTeal,
      borderRadius: BorderRadius.circular(16),
      boxShadow: filled
          ? const [
              BoxShadow(
                color: Color(0x33008D83),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ]
          : null,
    ),
    child: Icon(icon, color: filled ? Colors.white : _Colors.teal),
  );
}

class _Surface extends StatelessWidget {
  const _Surface({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    clipBehavior: Clip.antiAlias,
    elevation: 1,
    shadowColor: Colors.black.withValues(alpha: 0.08),
    child: Padding(padding: padding, child: child),
  );
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, {this.icon});
  final String text;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: _Colors.softTeal,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: _Colors.teal),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: const TextStyle(
            color: _Colors.teal,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: _Colors.text,
      ),
    ),
  );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final String title, value;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: _Colors.teal),
    title: Text(title),
    trailing: Text(
      value,
      style: const TextStyle(color: _Colors.teal, fontWeight: FontWeight.w800),
    ),
  );
}

class _PublicPreview extends StatelessWidget {
  const _PublicPreview({
    required this.name,
    required this.specialty,
    required this.fee,
  });
  final String name, specialty;
  final int fee;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(name, style: _Styles.name),
      const SizedBox(height: 6),
      Text(specialty, style: _Styles.body),
      const SizedBox(height: 10),
      Text('Consultation fee: PKR $fee', style: _Styles.tileTitle),
      const SizedBox(height: 10),
      const _Badge('Visible to patients', icon: Icons.visibility_outlined),
    ],
  );
}

class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({
    required this.title,
    required this.child,
    required this.onSave,
  });
  final String title;
  final Widget child;
  final VoidCallback onSave;
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    padding: EdgeInsets.fromLTRB(
      20,
      12,
      20,
      MediaQuery.of(context).viewInsets.bottom + 20,
    ),
    child: SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _Colors.divider,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: _Colors.text,
              ),
            ),
            const SizedBox(height: 16),
            child,
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: _Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Colors {
  const _Colors._();
  static const teal = Color(0xFF078D83);
  static const darkTeal = Color(0xFF006B63);
  static const softTeal = Color(0xFFE4F5F2);
  static const background = Color(0xFFF4FAF9);
  static const text = Color(0xFF17232F);
  static const muted = Color(0xFF657178);
  static const divider = Color(0xFFE2ECEB);
  static const red = Color(0xFFE33636);
}

class _Styles {
  const _Styles._();
  static const appBar = TextStyle(
    color: Colors.white,
    fontSize: 25,
    fontWeight: FontWeight.w900,
  );
  static const name = TextStyle(
    color: _Colors.text,
    fontSize: 22,
    fontWeight: FontWeight.w900,
  );
  static const body = TextStyle(
    color: _Colors.text,
    fontSize: 15,
    height: 1.35,
  );
  static const tileTitle = TextStyle(
    color: _Colors.text,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );
  static const muted = TextStyle(
    color: _Colors.muted,
    fontSize: 13,
    height: 1.35,
  );
}
