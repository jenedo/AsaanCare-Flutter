import 'package:flutter/material.dart';

import '../../features/dashboard/domain/entities/doctor_dashboard_snapshot.dart';
import '../../features/dashboard/presentation/controllers/doctor_dashboard_controller.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({
    super.key,
    required this.controller,
    required this.onBack,
    required this.onPatientTap,
    required this.onAppointmentAction,
  });

  final DoctorDashboardController controller;
  final VoidCallback onBack;
  final ValueChanged<DoctorPatientSummary> onPatientTap;
  final ValueChanged<DoctorAppointmentRecord> onAppointmentAction;

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refresh);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final query = _searchController.text.trim().toLowerCase();
        final appointments =
            widget.controller.filteredAppointments
                .where(
                  (item) =>
                      query.isEmpty ||
                      item.patient.name.toLowerCase().contains(query) ||
                      item.id.toLowerCase().contains(query),
                )
                .toList(growable: false)
              ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

        return SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: CustomScrollView(
                key: const PageStorageKey('doctor-appointments-scroll'),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    sliver: SliverList.list(
                      children: [
                        _TopBar(onBack: widget.onBack),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Search patient or appointment ID',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: query.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    onPressed: _searchController.clear,
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _Filters(controller: widget.controller),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${appointments.length} appointment${appointments.length == 1 ? '' : 's'}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Refresh appointments',
                              onPressed: widget.controller.refresh,
                              icon: const Icon(Icons.refresh_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (appointments.isEmpty)
                          const _EmptyAppointments()
                        else
                          for (final appointment in appointments) ...[
                            _AppointmentListCard(
                              appointment: appointment,
                              isLoading: widget.controller.isUpdating(
                                appointment.id,
                              ),
                              onPatientTap: () =>
                                  widget.onPatientTap(appointment.patient),
                              onAction: () =>
                                  widget.onAppointmentAction(appointment),
                              onAccept: () => widget.controller.acceptRequest(
                                appointment.id,
                              ),
                              onReject: () => _confirmReject(appointment),
                            ),
                            const SizedBox(height: 10),
                          ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmReject(DoctorAppointmentRecord appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject appointment?'),
        content: Text(
          '${appointment.patient.name} will be notified that this request was declined.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.controller.rejectRequest(appointment.id);
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        tooltip: 'Back to doctor home',
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          'Appointments',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    ],
  );
}

class _Filters extends StatelessWidget {
  const _Filters({required this.controller});
  final DoctorDashboardController controller;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: DoctorAppointmentFilter.values.map((filter) {
        final label = switch (filter) {
          DoctorAppointmentFilter.all => 'All',
          DoctorAppointmentFilter.pending => 'Pending',
          DoctorAppointmentFilter.completed => 'Completed',
        };
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(label),
            selected: controller.appointmentFilter == filter,
            onSelected: (_) => controller.selectAppointmentFilter(filter),
          ),
        );
      }).toList(),
    ),
  );
}

class _AppointmentListCard extends StatelessWidget {
  const _AppointmentListCard({
    required this.appointment,
    required this.isLoading,
    required this.onPatientTap,
    required this.onAction,
    required this.onAccept,
    required this.onReject,
  });
  final DoctorAppointmentRecord appointment;
  final bool isLoading;
  final VoidCallback onPatientTap;
  final VoidCallback onAction;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: .55)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: onPatientTap,
                  child: CircleAvatar(
                    radius: 27,
                    backgroundImage: AssetImage(appointment.patient.imageAsset),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patient.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${appointment.type.label} · ${appointment.durationMinutes} min',
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_date(appointment.scheduledAt)} · ${_time(appointment.scheduledAt)}',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: appointment.status),
              ],
            ),
            const SizedBox(height: 12),
            if (appointment.status == DoctorAppointmentStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : onReject,
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: isLoading ? null : onAccept,
                      child: isLoading
                          ? const SizedBox.square(
                              dimension: 19,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Accept'),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed:
                      appointment.status == DoctorAppointmentStatus.confirmed
                      ? null
                      : onAction,
                  icon: Icon(
                    appointment.status == DoctorAppointmentStatus.completed
                        ? Icons.description_outlined
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(switch (appointment.status) {
                    DoctorAppointmentStatus.completed => 'View Summary',
                    DoctorAppointmentStatus.inProgress => 'Continue',
                    DoctorAppointmentStatus.ready => 'Start Consultation',
                    _ => 'Upcoming',
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final DoctorAppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = switch (status) {
      DoctorAppointmentStatus.pending => colors.tertiary,
      DoctorAppointmentStatus.completed => const Color(0xFF287D3C),
      DoctorAppointmentStatus.cancelled => colors.error,
      _ => colors.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyAppointments extends StatelessWidget {
  const _EmptyAppointments();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Column(
      children: [
        Icon(Icons.event_available_rounded, size: 42),
        SizedBox(height: 10),
        Text(
          'No matching appointments',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 4),
        Text(
          'Try another search or status filter.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

String _date(DateTime value) => '${value.day}/${value.month}/${value.year}';

String _time(DateTime value) {
  final hour = value.hour == 0
      ? 12
      : value.hour > 12
      ? value.hour - 12
      : value.hour;
  return '$hour:${value.minute.toString().padLeft(2, '0')} ${value.hour >= 12 ? 'PM' : 'AM'}';
}
