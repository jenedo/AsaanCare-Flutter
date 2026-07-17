import 'package:flutter/material.dart';

import '../../../features/dashboard/domain/entities/doctor_dashboard_snapshot.dart';
import '../../../features/dashboard/presentation/controllers/doctor_dashboard_controller.dart';

class DoctorPatientsTab extends StatefulWidget {
  const DoctorPatientsTab({
    super.key,
    required this.controller,
    required this.onPatientTap,
  });

  final DoctorDashboardController controller;
  final ValueChanged<DoctorPatientSummary> onPatientTap;

  @override
  State<DoctorPatientsTab> createState() => _DoctorPatientsTabState();
}

class _DoctorPatientsTabState extends State<DoctorPatientsTab> {
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
        final records = <String, DoctorPatientSummary>{};
        for (final appointment
            in widget.controller.snapshot?.appointments ??
                const <DoctorAppointmentRecord>[]) {
          records[appointment.patient.id] = appointment.patient;
        }
        final patients =
            records.values
                .where((patient) {
                  return query.isEmpty ||
                      patient.name.toLowerCase().contains(query) ||
                      patient.condition.toLowerCase().contains(query);
                })
                .toList(growable: false)
              ..sort((a, b) => a.name.compareTo(b.name));

        return SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: CustomScrollView(
                key: const PageStorageKey('doctor-patients-scroll'),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                    sliver: SliverList.list(
                      children: [
                        Text(
                          'Patients',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${patients.length} patient record${patients.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          key: const ValueKey('patient-search-field'),
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Search name or condition',
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
                        const SizedBox(height: 16),
                        if (patients.isEmpty)
                          _EmptyPatients(query: _searchController.text)
                        else
                          for (final patient in patients) ...[
                            _PatientCard(
                              patient: patient,
                              onTap: () => widget.onPatientTap(patient),
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
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient, required this.onTap});
  final DoctorPatientSummary patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: .55)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage(patient.imageAsset),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text('${patient.age} years · ${patient.gender}'),
                    const SizedBox(height: 3),
                    Text(
                      patient.condition,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${patient.visitCount} visits',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPatients extends StatelessWidget {
  const _EmptyPatients({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        Icon(
          Icons.person_search_rounded,
          size: 38,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 10),
        Text(
          query.trim().isEmpty
              ? 'No patient records yet.'
              : 'No records match “${query.trim()}”.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}
