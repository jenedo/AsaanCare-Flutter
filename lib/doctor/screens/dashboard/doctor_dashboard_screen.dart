import 'package:flutter/material.dart';

import '../../features/dashboard/domain/entities/doctor_dashboard_snapshot.dart';
import '../../features/dashboard/presentation/controllers/doctor_dashboard_controller.dart';
import '../../features/finance/presentation/controllers/doctor_finance_controller.dart';
import '../appointments/doctor_appointments_screen.dart';
import '../consultation/doctor_consultation_screen.dart';
import '../consultation/write_prescription_screen.dart';
import '../earnings/doctor_earnings_screen.dart';
import '../patients/doctor_patient_profile_screen.dart';
import '../profile/doctor_profile_screen.dart';
import 'widgets/doctor_home_content.dart';
import 'widgets/doctor_patients_tab.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.dashboardController,
    required this.financeController,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  final String doctorId;
  final String doctorName;
  final DoctorDashboardController dashboardController;
  final DoctorFinanceController financeController;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  static const _homeIndex = 0;
  static const _scheduleIndex = 1;
  static const _patientsIndex = 2;
  static const _earningsIndex = 3;
  static const _profileIndex = 4;

  int _selectedIndex = _homeIndex;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant DoctorDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doctorId != widget.doctorId) _load(force: true);
  }

  void _load({bool force = false}) {
    Future<void>.microtask(() async {
      await Future.wait([
        widget.dashboardController.load(
          doctorId: widget.doctorId,
          force: force,
        ),
        widget.financeController.load(doctorId: widget.doctorId, force: force),
      ]);
    });
  }

  void _selectTab(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  void _openAppointments(DoctorAppointmentFilter filter) {
    widget.dashboardController.selectAppointmentFilter(filter);
    _selectTab(_scheduleIndex);
  }

  void _openPatient(DoctorPatientSummary patient) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DoctorPatientProfileScreen(
          patientName: patient.name,
          patientAge: patient.age,
          patientGender: patient.gender,
          appointmentId: patient.id,
          imageAsset: patient.imageAsset,
        ),
      ),
    );
  }

  void _openNotifications() {
    final requests = widget.dashboardController.pendingRequests;
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
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              if (requests.isEmpty)
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.notifications_none_rounded),
                  title: Text('You are all caught up'),
                  subtitle: Text('New consultation requests appear here.'),
                )
              else
                for (final request in requests.take(3))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_add_alt_1_rounded),
                    ),
                    title: Text('${request.patient.name} requested a visit'),
                    subtitle: Text(request.type.label),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openAppointments(DoctorAppointmentFilter.pending);
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPrescription() {
    final snapshot = widget.dashboardController.snapshot;
    final patient = snapshot?.appointments.isNotEmpty == true
        ? snapshot!.appointments.first.patient
        : null;
    if (patient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a patient before prescribing.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WritePrescriptionScreen(
          patientName: patient.name,
          patientAge: patient.age,
          patientGender: patient.gender,
          appointmentId: patient.id,
        ),
      ),
    );
  }

  Future<void> _handleAppointment(DoctorAppointmentRecord appointment) async {
    if (appointment.status == DoctorAppointmentStatus.completed) {
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consultation Summary',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(appointment.patient.imageAsset),
                  ),
                  title: Text(appointment.patient.name),
                  subtitle: Text(appointment.type.label),
                  trailing: const Chip(label: Text('Completed')),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }
    if (appointment.type == DoctorConsultationType.clinic) {
      _openPatient(appointment.patient);
      return;
    }
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => DoctorConsultationScreen(
          patientName: appointment.patient.name,
          patientAge: appointment.patient.age,
          patientGender: appointment.patient.gender,
          appointmentId: appointment.id,
          isVideo: appointment.type == DoctorConsultationType.video,
        ),
      ),
    );
    if (!mounted) return;
    if (completed == true) {
      await widget.dashboardController.updateStatus(
        appointment.id,
        DoctorAppointmentStatus.completed,
      );
    } else if (appointment.status == DoctorAppointmentStatus.ready) {
      await widget.dashboardController.updateStatus(
        appointment.id,
        DoctorAppointmentStatus.inProgress,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DoctorHomeContent(
        doctorName: widget.doctorName,
        dashboardController: widget.dashboardController,
        financeController: widget.financeController,
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
        onProfileTap: () => _selectTab(_profileIndex),
        onNotificationsTap: _openNotifications,
        onAppointmentsTap: () => _openAppointments(DoctorAppointmentFilter.all),
        onPendingTap: () => _openAppointments(DoctorAppointmentFilter.pending),
        onCompletedTap: () =>
            _openAppointments(DoctorAppointmentFilter.completed),
        onScheduleTap: () => _openAppointments(DoctorAppointmentFilter.all),
        onPatientsTap: () => _selectTab(_patientsIndex),
        onPrescribeTap: _openPrescription,
        onEarningsTap: () => _selectTab(_earningsIndex),
        onPatientTap: _openPatient,
        onAppointmentAction: _handleAppointment,
      ),
      DoctorAppointmentsScreen(
        controller: widget.dashboardController,
        onBack: () => _selectTab(_homeIndex),
        onPatientTap: _openPatient,
        onAppointmentAction: _handleAppointment,
      ),
      DoctorPatientsTab(
        controller: widget.dashboardController,
        onPatientTap: _openPatient,
      ),
      DoctorEarningsScreen(
        controller: widget.financeController,
        dashboardController: widget.dashboardController,
      ),
      const DoctorProfileScreen(showBackButton: false),
    ];

    const navTeal = Color(0xFF006D5B);
    const navMuted = Color(0xFF6F8588);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;
          return NavigationBarTheme(
            data: NavigationBarThemeData(
              height: compact ? 64 : 70,
              backgroundColor: Colors.white,
              elevation: 8,
              shadowColor: const Color(0x180D5C63),
              indicatorColor: const Color(0xFFE7F6F4),
              indicatorShape: const CircleBorder(),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return TextStyle(
                  color: selected ? navTeal : navMuted,
                  fontSize: compact ? 9 : 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return IconThemeData(
                  color: selected ? navTeal : navMuted,
                  size: compact ? 20 : 22,
                );
              }),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE8EEEE))),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x140D5C63),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _selectTab,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_today_outlined),
                    selectedIcon: Icon(Icons.calendar_month_rounded),
                    label: 'Schedule',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.group_outlined),
                    selectedIcon: Icon(Icons.group_rounded),
                    label: 'Patients',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.attach_money_rounded),
                    selectedIcon: Icon(Icons.attach_money_rounded),
                    label: 'Earnings',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
