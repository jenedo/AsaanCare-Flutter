import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../appointments/doctor_appointments_screen.dart';
import '../consultation/write_prescription_screen.dart';
import '../patients/doctor_patient_profile_screen.dart';

const _patientRecords = <_PatientSummary>[
  _PatientSummary(
    name: 'Ahmed Hassan',
    imageAsset: 'assets/images/doctor_ali.png',
    age: 32,
    gender: 'Male',
    appointmentId: 'AC-250512-001',
    condition: 'Respiratory follow-up',
    lastVisit: 'Today',
    nextVisit: 'Today, 10:30 AM',
    visitCount: 5,
    status: 'Follow-up due',
  ),
  _PatientSummary(
    name: 'Sara Bibi',
    imageAsset: 'assets/images/user_avatar.png',
    age: 39,
    gender: 'Female',
    appointmentId: 'AC-250512-004',
    condition: 'In-clinic consultation',
    lastVisit: '28 Jun',
    nextVisit: 'Today, 12:00 PM',
    visitCount: 3,
    status: 'In progress',
  ),
  _PatientSummary(
    name: 'Kamran Zia',
    imageAsset: 'assets/images/user_avatar.png',
    age: 45,
    gender: 'Male',
    appointmentId: 'AC-250512-003',
    condition: 'Diabetes care plan',
    lastVisit: '02 May',
    nextVisit: 'Today, 02:30 PM',
    visitCount: 8,
    status: 'Confirmed',
  ),
  _PatientSummary(
    name: 'Fatima Ali',
    imageAsset: 'assets/images/doctor_sara.png',
    age: 28,
    gender: 'Female',
    appointmentId: 'AC-250512-002',
    condition: 'General consultation',
    lastVisit: '08 May',
    nextVisit: 'Awaiting confirmation',
    visitCount: 2,
    status: 'New request',
  ),
];

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _selectedIndex = 0;
  final List<_PendingRequest> _requests = [
    const _PendingRequest(
      id: 'ahmed-request',
      name: 'Ahmed Hassan',
      type: 'Video Consultation',
      duration: '30 min',
      requestedAgo: '10 min ago',
      imageAsset: 'assets/images/doctor_ali.png',
    ),
    const _PendingRequest(
      id: 'fatima-request',
      name: 'Fatima Ali',
      type: 'Audio Consultation',
      duration: '20 min',
      requestedAgo: '25 min ago',
      imageAsset: 'assets/images/doctor_sara.png',
    ),
  ];

  final List<_Appointment> _appointments = [
    const _Appointment(
      id: 'ahmed-appointment',
      time: '10:30',
      period: 'AM',
      name: 'Ahmed Hassan',
      type: 'Video Consultation',
      fee: 500,
      icon: Icons.videocam_rounded,
    ),
    const _Appointment(
      id: 'sara-appointment',
      time: '12:00',
      period: 'PM',
      name: 'Sara Bibi',
      type: 'Clinic Visit',
      fee: 800,
      icon: Icons.location_on_rounded,
      inProgress: true,
    ),
    const _Appointment(
      id: 'kamran-appointment',
      time: '02:30',
      period: 'PM',
      name: 'Kamran Zia',
      type: 'Video Consultation',
      fee: 500,
      icon: Icons.videocam_rounded,
    ),
  ];

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }

  void _handleRequest(_PendingRequest request, {required bool accepted}) {
    setState(() {
      _requests.removeWhere((item) => item.id == request.id);
      if (accepted && !_appointments.any((item) => item.name == request.name)) {
        _appointments.add(
          _Appointment(
            id: '${request.id}-appointment',
            time: '04:00',
            period: 'PM',
            name: request.name,
            type: request.type,
            fee: 500,
            icon: request.type.startsWith('Video')
                ? Icons.videocam_rounded
                : Icons.phone_in_talk_rounded,
          ),
        );
      }
    });
    _showMessage(
      accepted
          ? '${request.name}\'s request was accepted.'
          : '${request.name}\'s request was declined.',
    );
  }

  void _toggleAppointment(_Appointment appointment) {
    final index = _appointments.indexWhere((item) => item.id == appointment.id);
    if (index < 0) return;
    setState(() {
      _appointments[index] = appointment.copyWith(
        inProgress: !appointment.inProgress,
      );
    });
    _showMessage(
      appointment.inProgress
          ? '${appointment.name}\'s consultation was paused.'
          : '${appointment.name}\'s consultation is now in progress.',
    );
  }

  void _openPatient(_PatientSummary patient) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DoctorPatientProfileScreen(
          patientName: patient.name,
          patientAge: patient.age,
          patientGender: patient.gender,
          appointmentId: patient.appointmentId,
          imageAsset: patient.imageAsset,
        ),
      ),
    );
  }

  _PatientSummary _patientForAppointment(_Appointment appointment) {
    for (final patient in _patientRecords) {
      if (patient.name == appointment.name) return patient;
    }

    return _PatientSummary(
      name: appointment.name,
      imageAsset: 'assets/images/user_avatar.png',
      age: 0,
      gender: 'Not provided',
      appointmentId: appointment.id,
      condition: appointment.type,
      lastVisit: 'New patient',
      nextVisit: '${appointment.time} ${appointment.period}',
      visitCount: 1,
      status: appointment.inProgress ? 'In progress' : 'Confirmed',
    );
  }

  void _openNotifications() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              _NotificationTile(
                icon: Icons.person_add_alt_1_rounded,
                title: '${_requests.length} consultation requests',
                subtitle: 'Review and respond from your home screen.',
              ),
              const _NotificationTile(
                icon: Icons.schedule_rounded,
                title: 'Appointment in 30 minutes',
                subtitle: 'Ahmed Hassan · Video consultation',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPrescriptionComposer() {
    final patient = _patientRecords.first;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WritePrescriptionScreen(
          patientName: patient.name,
          patientAge: patient.age,
          patientGender: patient.gender,
          appointmentId: patient.appointmentId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeDashboard(
        requests: _requests,
        appointments: _appointments,
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
        onNotificationsTap: _openNotifications,
        onRequestAction: _handleRequest,
        onAppointmentAction: _toggleAppointment,
        onPatientTap: (appointment) =>
            _openPatient(_patientForAppointment(appointment)),
        onNavigationTap: (index) => setState(() => _selectedIndex = index),
        onPrescriptionTap: _openPrescriptionComposer,
      ),
      DoctorAppointmentsScreen(
        onBack: () => setState(() => _selectedIndex = 0),
      ),
      _PatientsPage(onPatientTap: _openPatient),
      const _EarningsPage(),
      const _ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: _DoctorBottomNavigation(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard({
    required this.requests,
    required this.appointments,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onNotificationsTap,
    required this.onRequestAction,
    required this.onAppointmentAction,
    required this.onPatientTap,
    required this.onNavigationTap,
    required this.onPrescriptionTap,
  });

  final List<_PendingRequest> requests;
  final List<_Appointment> appointments;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final VoidCallback onNotificationsTap;
  final void Function(_PendingRequest request, {required bool accepted})
  onRequestAction;
  final ValueChanged<_Appointment> onAppointmentAction;
  final ValueChanged<_Appointment> onPatientTap;
  final ValueChanged<int> onNavigationTap;
  final VoidCallback onPrescriptionTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                sliver: SliverList.list(
                  children: [
                    _DoctorHeader(
                      isDarkMode: isDarkMode,
                      onThemeToggle: onThemeToggle,
                      onNotificationsTap: onNotificationsTap,
                    ),
                    const SizedBox(height: 18),
                    _OverviewCard(
                      pendingCount: requests.length,
                      appointmentCount: appointments.length + requests.length,
                    ),
                    const SizedBox(height: 18),
                    _QuickActions(
                      onScheduleTap: () => onNavigationTap(1),
                      onPatientsTap: () => onNavigationTap(2),
                      onPrescribeTap: onPrescriptionTap,
                      onEarningsTap: () => onNavigationTap(3),
                    ),
                    const SizedBox(height: 22),
                    _SectionHeader(
                      title: 'Pending Requests',
                      count: requests.length,
                    ),
                    const SizedBox(height: 10),
                    if (requests.isEmpty)
                      const _EmptyRequestsCard()
                    else
                      for (final request in requests) ...[
                        _RequestCard(
                          request: request,
                          onAccept: () =>
                              onRequestAction(request, accepted: true),
                          onReject: () =>
                              onRequestAction(request, accepted: false),
                        ),
                        const SizedBox(height: 10),
                      ],
                    const SizedBox(height: 12),
                    _SectionHeader(
                      title: 'Today\'s Appointments',
                      actionLabel: 'See All',
                      onAction: () => onNavigationTap(1),
                    ),
                    const SizedBox(height: 10),
                    for (final appointment in appointments) ...[
                      _AppointmentCard(
                        appointment: appointment,
                        onAction: () => onAppointmentAction(appointment),
                        onPatientTap: () => onPatientTap(appointment),
                      ),
                      const SizedBox(height: 9),
                    ],
                    if (dark) const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorHeader extends StatelessWidget {
  const _DoctorHeader({
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onNotificationsTap,
  });

  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          image: true,
          label: 'Profile photo of Dr. Sara Khan',
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Color(0xFFDDF4F1),
                backgroundImage: AssetImage('assets/images/user_avatar.png'),
              ),
              Positioned(
                right: -1,
                bottom: 2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF19B640),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning',
                style: TextStyle(
                  color: Color(0xFF5D6979),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Dr. Sara Khan',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 23,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        _HeaderAction(
          tooltip: isDarkMode ? 'Use light theme' : 'Use dark theme',
          icon: isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          filled: true,
          onTap: onThemeToggle,
        ),
        const SizedBox(width: 9),
        _HeaderAction(
          tooltip: 'Notifications',
          icon: Icons.notifications_none_rounded,
          showBadge: true,
          onTap: onNotificationsTap,
        ),
      ],
    ).animate().fadeIn(duration: 280.ms);
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.filled = false,
    this.showBadge = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: filled ? _DoctorColors.teal : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          elevation: filled ? 2 : 1,
          shadowColor: Colors.black26,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: Tooltip(
              message: tooltip,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  icon,
                  color: filled ? Colors.white : const Color(0xFF55606F),
                  size: 25,
                ),
              ),
            ),
          ),
        ),
        if (showBadge)
          Positioned(
            right: 7,
            top: 7,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFF0182D),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.pendingCount,
    required this.appointmentCount,
  });

  final int pendingCount;
  final int appointmentCount;

  @override
  Widget build(BuildContext context) {
    final date = _formatDate(DateTime.now());
    final stats = [
      (Icons.calendar_month_outlined, '$appointmentCount', 'Appointments'),
      (Icons.history_rounded, '$pendingCount', 'Pending'),
      (Icons.check_circle_outline_rounded, '5', 'Completed'),
      (Icons.account_balance_wallet_outlined, 'Rs.4K', 'Earned'),
    ];

    return Container(
      height: 168,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF07877E), Color(0xFF09C7CE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33008C86),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Today\'s Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              children: List.generate(stats.length, (index) {
                final stat = stats[index];
                return Expanded(
                  child: Row(
                    children: [
                      if (index > 0)
                        const SizedBox(
                          height: 72,
                          child: VerticalDivider(
                            width: 8,
                            color: Color(0x66FFFFFF),
                          ),
                        ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(stat.$1, color: Colors.white, size: 23),
                            const SizedBox(height: 2),
                            Text(
                              stat.$2,
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            Text(
                              stat.$3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    ).animate(delay: 60.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04);
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onScheduleTap,
    required this.onPatientsTap,
    required this.onPrescribeTap,
    required this.onEarningsTap,
  });

  final VoidCallback onScheduleTap;
  final VoidCallback onPatientsTap;
  final VoidCallback onPrescribeTap;
  final VoidCallback onEarningsTap;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        Icons.calendar_month_rounded,
        'Schedule',
        const Color(0xFFE8F8F7),
        const Color(0xFF078F86),
        onScheduleTap,
      ),
      (
        Icons.people_alt_rounded,
        'Patients',
        const Color(0xFFEEF4FF),
        const Color(0xFF316BEE),
        onPatientsTap,
      ),
      (
        Icons.edit_note_rounded,
        'Prescribe',
        const Color(0xFFF6EFFF),
        const Color(0xFF7F47E8),
        onPrescribeTap,
      ),
      (
        Icons.account_balance_wallet_rounded,
        'Earnings',
        const Color(0xFFFFF0F2),
        const Color(0xFFF0446A),
        onEarningsTap,
      ),
    ];

    return Row(
      children: List.generate(actions.length, (index) {
        final action = actions[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
            child: _QuickAction(
              icon: action.$1,
              label: action.$2,
              background: action.$3,
              foreground: action.$4,
              onTap: action.$5,
            ),
          ),
        );
      }),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Container(
                height: 66,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: foreground.withValues(alpha: 0.15)),
                ),
                child: Center(child: Icon(icon, color: foreground, size: 30)),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.count,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final int? count;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 9),
          Container(
            width: 27,
            height: 27,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFF5314),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: _DoctorColors.teal,
              minimumSize: const Size(64, 44),
              padding: const EdgeInsets.symmetric(horizontal: 5),
            ),
            child: Text(
              actionLabel!,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
            ),
          ),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  final _PendingRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFF7A38)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Semantics(
            image: true,
            label: 'Profile photo of ${request.name}',
            child: CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFDDF4F1),
              backgroundImage: AssetImage(request.imageAsset),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${request.type} · ${request.duration}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF5F6878),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Requested: ${request.requestedAgo}',
                  style: const TextStyle(
                    color: Color(0xFFFF5314),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 86,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: FilledButton(
                    onPressed: onAccept,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(48, 38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: FilledButton(
                    onPressed: onReject,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFE9EC),
                      foregroundColor: const Color(0xFFE51E3C),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(48, 38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRequestsCard extends StatelessWidget {
  const _EmptyRequestsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F7F4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: _DoctorColors.teal),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'All caught up — no pending requests.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.onAction,
    required this.onPatientTap,
  });

  final _Appointment appointment;
  final VoidCallback onAction;
  final VoidCallback onPatientTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 84),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: appointment.inProgress
                ? _DoctorColors.teal
                : Colors.transparent,
            width: 5,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  appointment.time,
                  style: const TextStyle(
                    color: _DoctorColors.teal,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  appointment.period,
                  style: const TextStyle(
                    color: _DoctorColors.teal,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 52,
            child: VerticalDivider(width: 15, color: Color(0xFFE1E6E6)),
          ),
          Expanded(
            child: Semantics(
              button: true,
              label: 'Open ${appointment.name} patient record',
              child: InkWell(
                key: ValueKey('home-patient-${appointment.id}'),
                onTap: onPatientTap,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFE5F5F2),
                        backgroundImage: AssetImage(
                          _patientImageForName(appointment.name),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  appointment.icon,
                                  color: _DoctorColors.teal,
                                  size: 17,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    appointment.type,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF5F6878),
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: 34,
                child: FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: appointment.inProgress
                        ? _DoctorColors.teal
                        : const Color(0xFFE6F6F4),
                    foregroundColor: appointment.inProgress
                        ? Colors.white
                        : _DoctorColors.teal,
                    minimumSize: const Size(76, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  child: Text(appointment.inProgress ? 'In Progress' : 'Start'),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Rs.${appointment.fee}',
                style: const TextStyle(color: Color(0xFF5F6878), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoctorBottomNavigation extends StatelessWidget {
  const _DoctorBottomNavigation({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onTap,
        height: 70,
        elevation: 0,
        indicatorColor: const Color(0xFFE4F5F2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_alt_rounded),
            label: 'Patients',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Earnings',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _PatientsPage extends StatefulWidget {
  const _PatientsPage({required this.onPatientTap});

  final ValueChanged<_PatientSummary> onPatientTap;

  @override
  State<_PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<_PatientsPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final patients = query.isEmpty
        ? _patientRecords
        : _patientRecords
              .where(
                (patient) =>
                    patient.name.toLowerCase().contains(query) ||
                    patient.condition.toLowerCase().contains(query) ||
                    patient.appointmentId.toLowerCase().contains(query),
              )
              .toList(growable: false);
    final countLabel = patients.length == 1
        ? '1 patient record'
        : '${patients.length} patient records';

    return _SecondaryPage(
      title: 'Patients',
      subtitle: 'Your recent patient records',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const ValueKey('patient-search-field'),
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Find a patient',
              hintText: 'Name, condition, or appointment ID',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      tooltip: 'Clear patient search',
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  countLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.shield_outlined,
                size: 18,
                color: _DoctorColors.teal,
              ),
              const SizedBox(width: 5),
              const Text(
                'Private',
                style: TextStyle(
                  color: _DoctorColors.teal,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (patients.isEmpty)
            _EmptyPatientSearch(query: _query)
          else
            for (final patient in patients) ...[
              _PatientRecordCard(
                patient: patient,
                onTap: () => widget.onPatientTap(patient),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _PatientRecordCard extends StatelessWidget {
  const _PatientRecordCard({required this.patient, required this.onTap});

  final _PatientSummary patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final mutedText = dark ? const Color(0xFFB8C5C7) : const Color(0xFF657178);

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('patient-card-${patient.appointmentId}'),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: dark ? const Color(0xFF294044) : const Color(0xFFE5ECEC),
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    image: true,
                    label: 'Profile photo of ${patient.name}',
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE5F5F2),
                        border: Border.all(color: _DoctorColors.teal, width: 2),
                        image: DecorationImage(
                          image: AssetImage(patient.imageAsset),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${patient.age} yrs · ${patient.gender} · ${patient.appointmentId}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: mutedText, fontSize: 12),
                        ),
                        const SizedBox(height: 9),
                        _PatientStatusChip(status: patient.status),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _DoctorColors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                patient.condition,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: dark
                      ? const Color(0xFF17272A)
                      : const Color(0xFFF1F8F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PatientMeta(
                      icon: Icons.history_rounded,
                      label: 'Last: ${patient.lastVisit}',
                    ),
                    const SizedBox(height: 8),
                    _PatientMeta(
                      icon: Icons.event_available_rounded,
                      label: 'Next: ${patient.nextVisit}',
                    ),
                    const SizedBox(height: 8),
                    _PatientMeta(
                      icon: Icons.description_outlined,
                      label: '${patient.visitCount} visits',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientStatusChip extends StatelessWidget {
  const _PatientStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final inProgress = status == 'In progress';
    final foreground = inProgress
        ? const Color(0xFF9A5A00)
        : _DoctorColors.teal;
    final background = inProgress
        ? const Color(0xFFFFF1D6)
        : const Color(0xFFE5F5F2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            inProgress
                ? Icons.schedule_rounded
                : Icons.check_circle_outline_rounded,
            size: 14,
            color: foreground,
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientMeta extends StatelessWidget {
  const _PatientMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16, color: _DoctorColors.teal),
      const SizedBox(width: 5),
      Expanded(
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}

class _EmptyPatientSearch extends StatelessWidget {
  const _EmptyPatientSearch({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.person_search_rounded,
          size: 38,
          color: _DoctorColors.teal,
        ),
        const SizedBox(height: 10),
        Text(
          'No patient records match “${query.trim()}”.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text('Try a name, condition, or appointment ID.'),
      ],
    ),
  );
}

class _EarningsPage extends StatelessWidget {
  const _EarningsPage();

  @override
  Widget build(BuildContext context) {
    return _SecondaryPage(
      title: 'Earnings',
      subtitle: 'Income and payment activity',
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF07877E), Color(0xFF09C7CE)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This month', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 6),
                Text(
                  'Rs. 48,500',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.arrow_downward_rounded)),
              title: Text('Consultation payment'),
              subtitle: Text('Ahmed Hassan · Today'),
              trailing: Text(
                '+ Rs.500',
                style: TextStyle(
                  color: _DoctorColors.teal,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return _SecondaryPage(
      title: 'Profile',
      subtitle: 'Account and professional details',
      child: Column(
        children: [
          const CircleAvatar(
            radius: 58,
            backgroundColor: Color(0xFFDDF4F1),
            backgroundImage: AssetImage('assets/images/user_avatar.png'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Dr. Sara Khan',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const Text('General Physician · PMDC Verified'),
          const SizedBox(height: 22),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Professional information'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryPage extends StatelessWidget {
  const _SecondaryPage({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFF657178))),
              const SizedBox(height: 22),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE4F5F2),
        child: Icon(icon, color: _DoctorColors.teal),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
    );
  }
}

class _PendingRequest {
  const _PendingRequest({
    required this.id,
    required this.name,
    required this.type,
    required this.duration,
    required this.requestedAgo,
    required this.imageAsset,
  });

  final String id;
  final String name;
  final String type;
  final String duration;
  final String requestedAgo;
  final String imageAsset;
}

class _PatientSummary {
  const _PatientSummary({
    required this.name,
    required this.imageAsset,
    required this.age,
    required this.gender,
    required this.appointmentId,
    required this.condition,
    required this.lastVisit,
    required this.nextVisit,
    required this.visitCount,
    required this.status,
  });

  final String name;
  final String imageAsset;
  final int age;
  final String gender;
  final String appointmentId;
  final String condition;
  final String lastVisit;
  final String nextVisit;
  final int visitCount;
  final String status;
}

class _Appointment {
  const _Appointment({
    required this.id,
    required this.time,
    required this.period,
    required this.name,
    required this.type,
    required this.fee,
    required this.icon,
    this.inProgress = false,
  });

  final String id;
  final String time;
  final String period;
  final String name;
  final String type;
  final int fee;
  final IconData icon;
  final bool inProgress;

  _Appointment copyWith({bool? inProgress}) {
    return _Appointment(
      id: id,
      time: time,
      period: period,
      name: name,
      type: type,
      fee: fee,
      icon: icon,
      inProgress: inProgress ?? this.inProgress,
    );
  }
}

class _DoctorColors {
  const _DoctorColors._();
  static const teal = Color(0xFF078D83);
}

String _patientImageForName(String name) {
  for (final patient in _patientRecords) {
    if (patient.name == name) return patient.imageAsset;
  }
  return 'assets/images/user_avatar.png';
}

String _formatDate(DateTime value) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${weekdays[value.weekday - 1]}, ${value.day} ${months[value.month - 1]}';
}
