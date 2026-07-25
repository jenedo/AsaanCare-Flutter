import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/clinical_prescription.dart';
import '../controllers/clinical_prescriptions_controller.dart';

class ClinicalPrescriptionsScreen extends StatefulWidget {
  const ClinicalPrescriptionsScreen({super.key, required this.controller});

  final ClinicalPrescriptionsController controller;

  @override
  State<ClinicalPrescriptionsScreen> createState() =>
      _ClinicalPrescriptionsScreenState();
}

class _ClinicalPrescriptionsScreenState
    extends State<ClinicalPrescriptionsScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    widget.controller.loadPrescriptions();
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

  void _showPrescriptionDetail(ClinicalPrescription prescription) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Clinical Prescription',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF07132D),
                        ),
                      ),
                    ),
                    _StatusChip(status: prescription.status),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Issued by: ${prescription.doctorName ?? "Doctor"}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF657386),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Prescribed Medicines',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF07132D),
                  ),
                ),
                const SizedBox(height: 8),
                for (final medicine in prescription.medicines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicine.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dosage: ${medicine.dosage} • Frequency: ${medicine.frequency} • Duration: ${medicine.duration}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF657386),
                            ),
                          ),
                          if (medicine.instructions != null &&
                              medicine.instructions!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Instructions: ${medicine.instructions}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                if (prescription.instructions != null &&
                    prescription.instructions!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Doctor Instructions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prescription.instructions!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF657386),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      appBar: AppBar(title: const Text('Clinical Prescriptions')),
      body: RefreshIndicator(
        onRefresh: controller.loadPrescriptions,
        child: Builder(
          builder: (context) {
            if (controller.isLoading && controller.prescriptions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.hasError && controller.prescriptions.isEmpty) {
              return Center(
                child: Text(
                  controller.errorMessage ?? 'Failed to load prescriptions.',
                  style: const TextStyle(color: AppTheme.danger),
                ),
              );
            }

            if (controller.isEmpty || controller.prescriptions.isEmpty) {
              return const Center(
                child: Text('No clinical prescriptions found.'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: controller.prescriptions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = controller.prescriptions[index];

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.doctorName ?? 'Clinical Prescription',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF07132D),
                              ),
                            ),
                          ),
                          _StatusChip(status: item.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Medicines: ${item.medicines.length} item(s)',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF657386),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          onPressed: () => _showPrescriptionDetail(item),
                          child: const Text('View Details'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ClinicalPrescriptionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      ClinicalPrescriptionStatus.issued => (
        'ISSUED',
        const Color(0xFF059669),
        const Color(0xFFD1FAE5),
      ),
      ClinicalPrescriptionStatus.superseded => (
        'SUPERSEDED',
        const Color(0xFFD97706),
        const Color(0xFFFEF3C7),
      ),
      ClinicalPrescriptionStatus.voided => (
        'VOIDED',
        const Color(0xFFDC2626),
        const Color(0xFFFEE2E2),
      ),
    };

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      backgroundColor: bg,
      side: BorderSide.none,
    );
  }
}
