import 'package:flutter/material.dart';

import '../consultation/doctor_consultation_screen.dart';
import '../patients/doctor_patient_profile_screen.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  static const _teal = Color(0xFF078D83);
  static const _orange = Color(0xFFFF660F);
  static const _red = Color(0xFFD71920);
  static const _green = Color(0xFF45A82C);
  static const _blue = Color(0xFF1551C4);
  static const _purple = Color(0xFF6935C5);

  final _searchController = TextEditingController();
  late List<_DoctorAppointment> _appointments;
  _AppointmentStatus? _statusFilter;
  _ConsultationType? _typeFilter;
  DateTime? _dateFilter;

  @override
  void initState() {
    super.initState();
    _appointments = _seedAppointments();
    _searchController.addListener(_refresh);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  List<_DoctorAppointment> get _filteredAppointments {
    final query = _searchController.text.trim().toLowerCase();
    return _appointments
        .where((appointment) {
          final matchesSearch =
              query.isEmpty ||
              appointment.name.toLowerCase().contains(query) ||
              appointment.id.toLowerCase().contains(query);
          final matchesStatus =
              _statusFilter == null || appointment.status == _statusFilter;
          final matchesType =
              _typeFilter == null || appointment.type == _typeFilter;
          final matchesDate =
              _dateFilter == null ||
              DateUtils.isSameDay(appointment.date, _dateFilter);
          return matchesSearch && matchesStatus && matchesType && matchesDate;
        })
        .toList(growable: false);
  }

  int _count(_AppointmentStatus status) =>
      _appointments.where((item) => item.status == status).length;

  void _updateStatus(
    _DoctorAppointment appointment,
    _AppointmentStatus status,
  ) {
    final index = _appointments.indexWhere((item) => item.id == appointment.id);
    if (index < 0) return;
    setState(() {
      _appointments[index] = appointment.copyWith(status: status);
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }

  void _accept(_DoctorAppointment appointment) {
    _updateStatus(appointment, _AppointmentStatus.confirmed);
    _showMessage('${appointment.name}\'s appointment was confirmed.');
  }

  Future<void> _reject(_DoctorAppointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject appointment?'),
        content: Text(
          '${appointment.name} will be notified that this request was declined.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: _red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _updateStatus(appointment, _AppointmentStatus.cancelled);
    _showMessage('${appointment.name}\'s appointment was rejected.');
  }

  Future<void> _reschedule(_DoctorAppointment appointment) async {
    final date = await showDatePicker(
      context: context,
      initialDate: appointment.date.isBefore(DateTime.now())
          ? DateTime.now()
          : appointment.date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _parseTime(appointment.time),
    );
    if (time == null || !mounted) return;
    final index = _appointments.indexWhere((item) => item.id == appointment.id);
    if (index < 0) return;
    setState(() {
      _appointments[index] = appointment.copyWith(
        date: date,
        time: _formatTime(time),
        status: _AppointmentStatus.confirmed,
      );
    });
    _showMessage('${appointment.name} was rescheduled successfully.');
  }

  Future<void> _startConsultation(_DoctorAppointment appointment) async {
    final start = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          appointment.type == _ConsultationType.clinic
              ? Icons.local_hospital_outlined
              : Icons.videocam_outlined,
          color: _teal,
          size: 36,
        ),
        title: const Text('Start consultation'),
        content: Text('Begin the session with ${appointment.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Not yet'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Start'),
          ),
        ],
      ),
    );
    if (start != true || !mounted) return;
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => DoctorConsultationScreen(
          patientName: appointment.name,
          patientAge: appointment.age,
          patientGender: appointment.gender,
          appointmentId: appointment.id,
          isVideo: appointment.type == _ConsultationType.video,
        ),
      ),
    );
    if (completed == true && mounted) {
      _updateStatus(appointment, _AppointmentStatus.completed);
      _showMessage('Consultation completed and prescription sent.');
    }
  }

  void _openPatient(_DoctorAppointment appointment) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DoctorPatientProfileScreen(
          patientName: appointment.name,
          patientAge: appointment.age,
          patientGender: appointment.gender,
          appointmentId: appointment.id,
          imageAsset: appointment.gender == 'Female'
              ? 'assets/images/doctor_sara.png'
              : 'assets/images/doctor_ali.png',
        ),
      ),
    );
  }

  void _openMessage(_DoctorAppointment appointment) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          0,
          18,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Message ${appointment.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _showMessage('Message sent to ${appointment.name}.');
                },
                icon: const Icon(Icons.send_rounded),
                label: const Text('Send Message'),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(controller.dispose);
  }

  void _viewPrescription(_DoctorAppointment appointment) {
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
              const Row(
                children: [
                  Icon(Icons.description_outlined, color: _purple),
                  SizedBox(width: 9),
                  Text(
                    'Prescription',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                appointment.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text('• Paracetamol 500mg — twice daily for 3 days'),
              const SizedBox(height: 6),
              const Text('• Hydration and rest'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Save Copy'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateFilter() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dateFilter ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null && mounted) setState(() => _dateFilter = selected);
  }

  Future<void> _openTypeFilter() async {
    final selected = await showModalBottomSheet<_ConsultationType?>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Consultation type',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.grid_view_rounded),
                title: const Text('All types'),
                onTap: () => Navigator.of(sheetContext).pop(),
              ),
              for (final type in _ConsultationType.values)
                ListTile(
                  leading: Icon(type.icon, color: _teal),
                  title: Text(type.label),
                  trailing: _typeFilter == type
                      ? const Icon(Icons.check_circle_rounded, color: _teal)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(type),
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _typeFilter = selected);
  }

  @override
  Widget build(BuildContext context) {
    final confirmed =
        _count(_AppointmentStatus.confirmed) +
        _count(_AppointmentStatus.completed);
    final visible = _filteredAppointments;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _AppointmentsHeader(
            onBack: widget.onBack,
            onFilter: _openTypeFilter,
            onCalendar: _pickDateFilter,
            hasFilter: _typeFilter != null || _dateFilter != null,
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                  children: [
                    _SummaryCard(
                      total: _appointments.length,
                      pending: _count(_AppointmentStatus.pending),
                      confirmed: confirmed,
                      cancelled: _count(_AppointmentStatus.cancelled),
                    ),
                    const SizedBox(height: 14),
                    _StatusFilters(
                      selected: _statusFilter,
                      onSelected: (status) =>
                          setState(() => _statusFilter = status),
                    ),
                    const SizedBox(height: 12),
                    _AppointmentSearch(
                      controller: _searchController,
                      onCalendar: _pickDateFilter,
                      dateFilter: _dateFilter,
                      onClearDate: () => setState(() => _dateFilter = null),
                    ),
                    if (_typeFilter != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InputChip(
                          avatar: Icon(_typeFilter!.icon, size: 16),
                          label: Text(_typeFilter!.label),
                          onDeleted: () => setState(() => _typeFilter = null),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (visible.isEmpty)
                      const _EmptyAppointments()
                    else
                      for (final appointment in visible) ...[
                        _AppointmentListCard(
                          appointment: appointment,
                          onPatientTap: () => _openPatient(appointment),
                          onAccept: () => _accept(appointment),
                          onReject: () => _reject(appointment),
                          onReschedule: () => _reschedule(appointment),
                          onStart: () => _startConsultation(appointment),
                          onMessage: () => _openMessage(appointment),
                          onPrescription: () => _viewPrescription(appointment),
                          onFollowUp: () => _reschedule(appointment),
                        ),
                        const SizedBox(height: 10),
                      ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentsHeader extends StatelessWidget {
  const _AppointmentsHeader({
    required this.onBack,
    required this.onFilter,
    required this.onCalendar,
    required this.hasFilter,
  });

  final VoidCallback onBack;
  final VoidCallback onFilter;
  final VoidCallback onCalendar;
  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF047871), Color(0xFF07958E)],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: 'Back to doctor home',
            icon: const Icon(Icons.chevron_left_rounded),
            color: Colors.white,
            iconSize: 34,
          ),
          const Expanded(
            child: Text(
              'Appointments',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: onFilter,
                tooltip: 'Filter consultation type',
                icon: const Icon(Icons.filter_alt_outlined),
                color: Colors.white,
                iconSize: 27,
              ),
              if (hasFilter)
                const Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: Color(0xFFFFD43B),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: onCalendar,
            tooltip: 'Choose date',
            icon: const Icon(Icons.calendar_month_outlined),
            color: Colors.white,
            iconSize: 27,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.pending,
    required this.confirmed,
    required this.cancelled,
  });

  final int total;
  final int pending;
  final int confirmed;
  final int cancelled;

  @override
  Widget build(BuildContext context) {
    final items = [
      (total, 'Total', Icons.people_outline_rounded, const Color(0xFF087C7A)),
      (pending, 'Pending', Icons.schedule_rounded, const Color(0xFFFF660F)),
      (confirmed, 'Confirmed', Icons.check_rounded, const Color(0xFF45A82C)),
      (cancelled, 'Cancelled', Icons.close_rounded, const Color(0xFFD71920)),
    ];
    return Container(
      constraints: const BoxConstraints(minHeight: 126),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  const SizedBox(
                    height: 78,
                    child: VerticalDivider(width: 6, color: Color(0xFFE0E5E8)),
                  ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${item.$1}',
                        style: TextStyle(
                          color: item.$4,
                          fontSize: 24,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(item.$2, style: const TextStyle(fontSize: 11)),
                      const SizedBox(height: 8),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: item.$4.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(item.$3, color: item.$4, size: 21),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({required this.selected, required this.onSelected});

  final _AppointmentStatus? selected;
  final ValueChanged<_AppointmentStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = <(_AppointmentStatus?, String)>[
      (null, 'All'),
      (_AppointmentStatus.pending, 'Pending'),
      (_AppointmentStatus.confirmed, 'Confirmed'),
      (_AppointmentStatus.completed, 'Completed'),
      (_AppointmentStatus.cancelled, 'Cancelled'),
    ];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final active = selected == filter.$1;
          return ChoiceChip(
            selected: active,
            showCheckmark: false,
            label: Text(filter.$2),
            onSelected: (_) => onSelected(filter.$1),
            selectedColor: _DoctorAppointmentsScreenState._teal,
            backgroundColor: Theme.of(context).cardColor,
            side: BorderSide(
              color: active
                  ? _DoctorAppointmentsScreenState._teal
                  : const Color(0xFFE0E5E8),
            ),
            labelStyle: TextStyle(
              color: active ? Colors.white : null,
              fontWeight: FontWeight.w700,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          );
        },
      ),
    );
  }
}

class _AppointmentSearch extends StatelessWidget {
  const _AppointmentSearch({
    required this.controller,
    required this.onCalendar,
    required this.dateFilter,
    required this.onClearDate,
  });

  final TextEditingController controller;
  final VoidCallback onCalendar;
  final DateTime? dateFilter;
  final VoidCallback onClearDate;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search patient name...',
        prefixIcon: const Icon(Icons.search_rounded, size: 28),
        suffixIcon: dateFilter == null
            ? IconButton(
                onPressed: onCalendar,
                tooltip: 'Filter by date',
                icon: const Icon(Icons.calendar_month_outlined),
              )
            : IconButton(
                onPressed: onClearDate,
                tooltip: 'Clear date filter',
                icon: const Icon(Icons.event_busy_outlined),
              ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE1E7EA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE1E7EA)),
        ),
      ),
    );
  }
}

class _AppointmentListCard extends StatelessWidget {
  const _AppointmentListCard({
    required this.appointment,
    required this.onPatientTap,
    required this.onAccept,
    required this.onReject,
    required this.onReschedule,
    required this.onStart,
    required this.onMessage,
    required this.onPrescription,
    required this.onFollowUp,
  });

  final _DoctorAppointment appointment;
  final VoidCallback onPatientTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onReschedule;
  final VoidCallback onStart;
  final VoidCallback onMessage;
  final VoidCallback onPrescription;
  final VoidCallback onFollowUp;

  Color get _statusColor => switch (appointment.status) {
    _AppointmentStatus.pending => _DoctorAppointmentsScreenState._orange,
    _AppointmentStatus.confirmed => _DoctorAppointmentsScreenState._teal,
    _AppointmentStatus.completed => _DoctorAppointmentsScreenState._green,
    _AppointmentStatus.cancelled => _DoctorAppointmentsScreenState._red,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 11),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: _statusColor, width: 5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onPatientTap,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: const Color(0xFFE7F5F4),
                  child: Text(
                    appointment.name.characters.first,
                    style: const TextStyle(
                      color: _DoctorAppointmentsScreenState._teal,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 15,
                            color: Color(0xFF687389),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${appointment.age} yrs  ·  ${appointment.gender}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF687389),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 5,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: appointment.type.color.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  appointment.type.icon,
                                  color: appointment.type.color,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  appointment.type.shortLabel,
                                  style: TextStyle(
                                    color: appointment.type.color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'ID: ${appointment.id}',
                            style: const TextStyle(
                              color: Color(0xFF687389),
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 70,
                  child: VerticalDivider(width: 16, color: Color(0xFFE1E5E8)),
                ),
                SizedBox(
                  width: 76,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.schedule_rounded, size: 16),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              appointment.time,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _dateLabel(appointment.date),
                        style: const TextStyle(
                          color: Color(0xFF687389),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        'Rs. ${appointment.fee}',
                        style: const TextStyle(
                          color: _DoctorAppointmentsScreenState._teal,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          _actions(),
        ],
      ),
    );
  }

  Widget _actions() {
    return switch (appointment.status) {
      _AppointmentStatus.pending => Row(
        children: [
          Expanded(
            child: _CardAction(
              icon: Icons.check_circle_rounded,
              label: 'Accept',
              color: _DoctorAppointmentsScreenState._green,
              onTap: onAccept,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _CardAction(
              icon: Icons.event_repeat_rounded,
              label: 'Reschedule',
              color: _DoctorAppointmentsScreenState._blue,
              onTap: onReschedule,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _CardAction(
              icon: Icons.cancel_rounded,
              label: 'Reject',
              color: _DoctorAppointmentsScreenState._red,
              onTap: onReject,
            ),
          ),
        ],
      ),
      _AppointmentStatus.confirmed => Row(
        children: [
          Expanded(
            flex: 4,
            child: _CardAction(
              icon: Icons.videocam_rounded,
              label: 'Start Consultation',
              color: _DoctorAppointmentsScreenState._teal,
              filled: true,
              onTap: onStart,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CardAction(
              icon: Icons.chat_bubble_outline_rounded,
              label: '',
              color: _DoctorAppointmentsScreenState._teal,
              onTap: onMessage,
            ),
          ),
        ],
      ),
      _AppointmentStatus.completed => Row(
        children: [
          Expanded(
            child: _CardAction(
              icon: Icons.description_outlined,
              label: 'View Prescription',
              color: _DoctorAppointmentsScreenState._purple,
              onTap: onPrescription,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CardAction(
              icon: Icons.sync_rounded,
              label: 'Follow Up',
              color: _DoctorAppointmentsScreenState._teal,
              onTap: onFollowUp,
            ),
          ),
        ],
      ),
      _AppointmentStatus.cancelled => _CardAction(
        icon: Icons.event_repeat_rounded,
        label: 'Reschedule',
        color: _DoctorAppointmentsScreenState._orange,
        onTap: onReschedule,
      ),
    };
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: label.isEmpty
            ? const SizedBox.shrink()
            : Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          backgroundColor: filled ? color : Colors.transparent,
          foregroundColor: filled ? Colors.white : color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _EmptyAppointments extends StatelessWidget {
  const _EmptyAppointments();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_busy_outlined, size: 42, color: Color(0xFF7C8993)),
          SizedBox(height: 10),
          Text(
            'No appointments match these filters.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

enum _AppointmentStatus { pending, confirmed, completed, cancelled }

enum _ConsultationType {
  video,
  clinic,
  audio;

  String get label => switch (this) {
    video => 'Video Consultation',
    clinic => 'Clinic Visit',
    audio => 'Audio Consultation',
  };

  String get shortLabel => switch (this) {
    video => 'Video',
    clinic => 'Clinic',
    audio => 'Audio',
  };

  IconData get icon => switch (this) {
    video => Icons.videocam_rounded,
    clinic => Icons.location_on_rounded,
    audio => Icons.phone_in_talk_rounded,
  };

  Color get color => switch (this) {
    video => const Color(0xFF1551C4),
    clinic => const Color(0xFF6935C5),
    audio => const Color(0xFF078D83),
  };
}

class _DoctorAppointment {
  const _DoctorAppointment({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.type,
    required this.time,
    required this.date,
    required this.fee,
    required this.status,
  });

  final String id;
  final String name;
  final int age;
  final String gender;
  final _ConsultationType type;
  final String time;
  final DateTime date;
  final int fee;
  final _AppointmentStatus status;

  _DoctorAppointment copyWith({
    String? time,
    DateTime? date,
    _AppointmentStatus? status,
  }) {
    return _DoctorAppointment(
      id: id,
      name: name,
      age: age,
      gender: gender,
      type: type,
      time: time ?? this.time,
      date: date ?? this.date,
      fee: fee,
      status: status ?? this.status,
    );
  }
}

List<_DoctorAppointment> _seedAppointments() {
  final today = DateUtils.dateOnly(DateTime.now());
  return [
    _DoctorAppointment(
      id: 'AC-250512-001',
      name: 'Ahmed Hassan',
      age: 32,
      gender: 'Male',
      type: _ConsultationType.video,
      time: '10:30 AM',
      date: today,
      fee: 500,
      status: _AppointmentStatus.pending,
    ),
    _DoctorAppointment(
      id: 'AC-250512-002',
      name: 'Sara Bibi',
      age: 28,
      gender: 'Female',
      type: _ConsultationType.clinic,
      time: '12:00 PM',
      date: today,
      fee: 800,
      status: _AppointmentStatus.confirmed,
    ),
    _DoctorAppointment(
      id: 'AC-250512-003',
      name: 'Kamran Zia',
      age: 45,
      gender: 'Male',
      type: _ConsultationType.video,
      time: '02:30 PM',
      date: today,
      fee: 500,
      status: _AppointmentStatus.pending,
    ),
    _DoctorAppointment(
      id: 'AC-250511-001',
      name: 'Fatima Malik',
      age: 35,
      gender: 'Female',
      type: _ConsultationType.video,
      time: '11:00 AM',
      date: today.subtract(const Duration(days: 1)),
      fee: 500,
      status: _AppointmentStatus.completed,
    ),
    _DoctorAppointment(
      id: 'AC-250510-001',
      name: 'Usman Ali',
      age: 52,
      gender: 'Male',
      type: _ConsultationType.clinic,
      time: '03:00 PM',
      date: today.subtract(const Duration(days: 2)),
      fee: 800,
      status: _AppointmentStatus.cancelled,
    ),
    _DoctorAppointment(
      id: 'AC-250512-004',
      name: 'Ayesha Noor',
      age: 41,
      gender: 'Female',
      type: _ConsultationType.audio,
      time: '04:00 PM',
      date: today,
      fee: 400,
      status: _AppointmentStatus.confirmed,
    ),
    _DoctorAppointment(
      id: 'AC-250509-001',
      name: 'Bilal Ahmed',
      age: 38,
      gender: 'Male',
      type: _ConsultationType.video,
      time: '09:30 AM',
      date: today.subtract(const Duration(days: 3)),
      fee: 500,
      status: _AppointmentStatus.completed,
    ),
    _DoctorAppointment(
      id: 'AC-250513-001',
      name: 'Hina Tariq',
      age: 26,
      gender: 'Female',
      type: _ConsultationType.clinic,
      time: '10:00 AM',
      date: today.add(const Duration(days: 1)),
      fee: 800,
      status: _AppointmentStatus.confirmed,
    ),
    _DoctorAppointment(
      id: 'AC-250508-001',
      name: 'Zain Raza',
      age: 49,
      gender: 'Male',
      type: _ConsultationType.audio,
      time: '01:30 PM',
      date: today.subtract(const Duration(days: 4)),
      fee: 400,
      status: _AppointmentStatus.completed,
    ),
    _DoctorAppointment(
      id: 'AC-250514-001',
      name: 'Nida Khan',
      age: 33,
      gender: 'Female',
      type: _ConsultationType.video,
      time: '03:30 PM',
      date: today.add(const Duration(days: 2)),
      fee: 500,
      status: _AppointmentStatus.confirmed,
    ),
    _DoctorAppointment(
      id: 'AC-250515-001',
      name: 'Omar Farooq',
      age: 56,
      gender: 'Male',
      type: _ConsultationType.clinic,
      time: '11:30 AM',
      date: today.add(const Duration(days: 3)),
      fee: 800,
      status: _AppointmentStatus.pending,
    ),
    _DoctorAppointment(
      id: 'AC-250507-001',
      name: 'Tariq Mehmood',
      age: 61,
      gender: 'Male',
      type: _ConsultationType.video,
      time: '05:00 PM',
      date: today.subtract(const Duration(days: 5)),
      fee: 500,
      status: _AppointmentStatus.cancelled,
    ),
  ];
}

TimeOfDay _parseTime(String value) {
  final parts = value.split(' ');
  final clock = parts.first.split(':');
  var hour = int.parse(clock.first);
  final minute = int.parse(clock.last);
  if (parts.last == 'PM' && hour != 12) hour += 12;
  if (parts.last == 'AM' && hour == 12) hour = 0;
  return TimeOfDay(hour: hour, minute: minute);
}

String _formatTime(TimeOfDay value) {
  final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

String _dateLabel(DateTime value) {
  final today = DateUtils.dateOnly(DateTime.now());
  if (DateUtils.isSameDay(value, today)) return 'Today';
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
  return '${value.day} ${months[value.month - 1]}';
}
