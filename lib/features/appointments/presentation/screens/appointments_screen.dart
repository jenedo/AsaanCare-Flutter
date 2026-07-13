import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/layout/app_layout.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../screens/consultation/audio_call_screen.dart';
import '../../../../screens/consultation/chat_consultation_screen.dart';
import '../../../../screens/consultation/video_call_screen.dart';
import '../../domain/entities/appointment_record.dart';
import '../../domain/entities/consultation_type.dart';
import '../controllers/appointment_list_controller.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({
    super.key,
    required this.controller,
    required this.patientId,
  });

  final AppointmentListController controller;
  final String patientId;

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  static const _primary = Color(0xFF00796B);
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    Future<void>.microtask(
      () => widget.controller.load(patientId: widget.patientId),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    widget.controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _goBack() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    navigator.pushNamedAndRemoveUntil(AppRoutes.patientHome, (route) => false);
  }

  List<AppointmentRecord> get _visibleAppointments {
    return widget.controller.appointments
        .where((appointment) {
          return switch (_selectedTab) {
            0 => appointment.status == AppointmentStatus.confirmed,
            1 => appointment.status == AppointmentStatus.completed,
            _ => appointment.status == AppointmentStatus.cancelled,
          };
        })
        .toList(growable: false)
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
        ),
        title: const Text(
          'My Appointments',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE7EBEC)),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxMobileContentWidth,
            ),
            child: Column(
              children: [
                _AppointmentTabs(
                  selected: _selectedTab,
                  onSelected: (value) => setState(() => _selectedTab = value),
                ).animate().fadeIn(duration: 300.ms),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final controller = widget.controller;
    if ((controller.isInitial || controller.isLoading) &&
        controller.appointments.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }
    if (controller.hasError && controller.appointments.isEmpty) {
      return _MessageState(
        icon: Icons.cloud_off_outlined,
        title: controller.errorMessage ?? 'Could not load appointments.',
        actionLabel: 'Try again',
        onAction: () =>
            controller.load(patientId: widget.patientId, forceRefresh: true),
      );
    }

    final appointments = _visibleAppointments;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: appointments.isEmpty
          ? const _MessageState(
              key: ValueKey('empty'),
              icon: Icons.calendar_today_outlined,
              title: 'No appointments yet',
              subtitle: 'Book your first appointment',
            )
          : RefreshIndicator(
              key: ValueKey(_selectedTab),
              color: _primary,
              onRefresh: () => controller.refresh(widget.patientId),
              child: _GroupedAppointmentList(appointments: appointments),
            ),
    );
  }
}

class _AppointmentTabs extends StatelessWidget {
  const _AppointmentTabs({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const labels = ['Upcoming', 'Completed', 'Cancelled'];
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final active = index == selected;
          return Expanded(
            child: InkWell(
              onTap: () => onSelected(index),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF00796B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: active ? Colors.white : const Color(0xFF7E898C),
                    fontSize: 12,
                    fontWeight: active ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _GroupedAppointmentList extends StatelessWidget {
  const _GroupedAppointmentList({required this.appointments});

  final List<AppointmentRecord> appointments;

  @override
  Widget build(BuildContext context) {
    final groups = <DateTime, List<AppointmentRecord>>{};
    for (final appointment in appointments) {
      final date = appointment.appointmentDate;
      final day = DateTime(date.year, date.month, date.day);
      groups.putIfAbsent(day, () => []).add(appointment);
    }
    final dates = groups.keys.toList()..sort();
    var animationIndex = 0;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 18),
      itemCount: dates.length,
      itemBuilder: (context, groupIndex) {
        final date = dates[groupIndex];
        final items = groups[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 7),
              child: Text(
                _dateHeader(date),
                style: const TextStyle(
                  color: Color(0xFF697578),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...items.map((appointment) {
              final delay = animationIndex++ * 100;
              return _AppointmentCard(
                    appointment: appointment,
                    onJoin: _canJoinRemoteCall(appointment)
                        ? () => _openRemoteCall(context, appointment)
                        : null,
                  )
                  .animate(delay: delay.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: .1, end: 0);
            }),
          ],
        );
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment, this.onJoin});

  final AppointmentRecord appointment;
  final VoidCallback? onJoin;

  @override
  Widget build(BuildContext context) {
    final status = _cardStatus(appointment);
    return Container(
      constraints: const BoxConstraints(minHeight: 138),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EEEE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 68,
            child: Text(
              appointment.timeLabel,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 92,
            margin: const EdgeInsets.only(right: 16),
            color: const Color(0xFFE6EBEC),
          ),
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFE0F2F1),
            backgroundImage: appointment.doctorImageAsset.isEmpty
                ? null
                : AssetImage(appointment.doctorImageAsset),
            child: appointment.doctorImageAsset.isEmpty
                ? const Icon(Icons.person, color: Color(0xFF00796B), size: 30)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.doctorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  appointment.doctorSpecialty,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF899497),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Icon(
                      _consultationIcon(appointment.consultationType),
                      size: 15,
                      color: const Color(0xFF9AA4A7),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        appointment.consultationType.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF9AA4A7),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_StatusBadge(status: status, onTap: onJoin)],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Appointment ID  •  ',
                      style: TextStyle(color: Color(0xFFABB3B5), fontSize: 9.5),
                    ),
                    Flexible(
                      child: Text(
                        appointment.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF727E81),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: .2,
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
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, this.onTap});

  final _VisualStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = switch (status) {
      _VisualStatus.join => ('Join', const Color(0xFF00796B), Colors.white),
      _VisualStatus.upcoming => (
        'Upcoming',
        const Color(0xFFE0F2F1),
        const Color(0xFF00796B),
      ),
      _VisualStatus.completed => (
        'Completed',
        const Color(0xFFEEF1F1),
        const Color(0xFF6F7B7E),
      ),
      _VisualStatus.cancelled => (
        'Cancelled',
        const Color(0xFFFFEBEE),
        const Color(0xFFC62828),
      ),
    };
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: status == _VisualStatus.join ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: const Color(0xFFD1D7D8)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFA0AAAC),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFA0AAAC), fontSize: 13),
              ),
            ],
            if (onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

enum _VisualStatus { join, upcoming, completed, cancelled }

_VisualStatus _cardStatus(AppointmentRecord appointment) {
  if (appointment.status == AppointmentStatus.completed) {
    return _VisualStatus.completed;
  }
  if (appointment.status == AppointmentStatus.cancelled) {
    return _VisualStatus.cancelled;
  }
  return _canJoinRemoteCall(appointment)
      ? _VisualStatus.join
      : _VisualStatus.upcoming;
}

bool _canJoinRemoteCall(AppointmentRecord appointment) {
  if (appointment.status != AppointmentStatus.confirmed ||
      (appointment.consultationType != ConsultationType.video &&
          appointment.consultationType != ConsultationType.audio &&
          appointment.consultationType != ConsultationType.chat)) {
    return false;
  }
  final start = _appointmentStart(appointment);
  if (start == null) return false;
  final now = DateTime.now();
  return !now.isBefore(start.subtract(const Duration(minutes: 5))) &&
      now.isBefore(start.add(const Duration(hours: 1)));
}

Future<void> _openRemoteCall(
  BuildContext context,
  AppointmentRecord appointment,
) {
  final Widget screen;
  if (appointment.consultationType == ConsultationType.audio) {
    screen = AudioCallScreen(
      doctorName: appointment.doctorName,
      doctorSpecialty: appointment.doctorSpecialty,
      doctorImageAsset: appointment.doctorImageAsset,
      appointmentDate: appointment.appointmentDate,
      appointmentTime: appointment.timeLabel,
    );
  } else if (appointment.consultationType == ConsultationType.chat) {
    screen = ChatConsultationScreen(
      doctorName: appointment.doctorName,
      doctorSpecialty: appointment.doctorSpecialty,
      doctorImageAsset: appointment.doctorImageAsset,
      appointmentDate: appointment.appointmentDate,
      appointmentTime: appointment.timeLabel,
    );
  } else {
    screen = VideoCallScreen(
      doctorName: appointment.doctorName,
      doctorImageAsset: appointment.doctorImageAsset,
    );
  }
  return Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => screen));
}

DateTime? _appointmentStart(AppointmentRecord appointment) {
  final match = RegExp(
    r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
    caseSensitive: false,
  ).firstMatch(appointment.timeLabel.trim());
  if (match == null) return null;
  var hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final period = match.group(3)!.toUpperCase();
  if (period == 'PM' && hour != 12) hour += 12;
  if (period == 'AM' && hour == 12) hour = 0;
  final date = appointment.appointmentDate;
  return DateTime(date.year, date.month, date.day, hour, minute);
}

IconData _consultationIcon(ConsultationType type) {
  return switch (type) {
    ConsultationType.video => Icons.videocam_outlined,
    ConsultationType.audio => Icons.call_outlined,
    ConsultationType.chat => Icons.chat_bubble_outline_rounded,
    ConsultationType.clinic => Icons.local_hospital_outlined,
  };
}

String _dateHeader(DateTime date) {
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
  final now = DateTime.now();
  final today =
      date.year == now.year && date.month == now.month && date.day == now.day;
  final value = '${date.day} ${months[date.month - 1]} ${date.year}';
  return today ? 'Today, $value' : value;
}
