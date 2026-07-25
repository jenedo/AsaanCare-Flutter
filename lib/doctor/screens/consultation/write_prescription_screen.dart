import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../features/prescription_writer/data/datasources/doctor_prescription_draft_mock_data_source.dart';
import '../../features/prescription_writer/data/repositories/doctor_prescription_draft_repository_impl.dart';
import '../../features/prescription_writer/domain/entities/doctor_written_prescription.dart';
import '../../features/prescription_writer/presentation/controllers/doctor_prescription_controller.dart';

class WritePrescriptionScreen extends StatefulWidget {
  const WritePrescriptionScreen({
    super.key,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.appointmentId,
    this.controller,
  });

  final String patientName;
  final int patientAge;
  final String patientGender;
  final String appointmentId;
  final DoctorPrescriptionController? controller;

  @override
  State<WritePrescriptionScreen> createState() =>
      _WritePrescriptionScreenState();
}

class _WritePrescriptionScreenState extends State<WritePrescriptionScreen> {
  static const _teal = Color(0xFF078D83);

  late final DoctorPrescriptionController _controller =
      widget.controller ??
      (sl.isRegistered<DoctorPrescriptionController>()
          ? sl<DoctorPrescriptionController>()
          : DoctorPrescriptionController(
              repository: DoctorPrescriptionDraftRepositoryImpl(
                dataSource: DoctorPrescriptionDraftMockDataSource(),
              ),
            ));

  final _diagnosisController = TextEditingController();
  final _complaintController = TextEditingController();
  final _notesController = TextEditingController();
  bool _didSync = false;

  @override
  void initState() {
    super.initState();
    _controller.load(appointmentId: widget.appointmentId).then((_) {
      if (mounted) {
        setState(_syncFields);
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _diagnosisController.dispose();
    _complaintController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _syncFields() {
    final state = _controller.state;
    _diagnosisController.text = state.diagnosis;
    _complaintController.text = state.chiefComplaint;
    _notesController.text = state.doctorNotes;
    _didSync = true;
  }

  Future<void> _editMedicine({DoctorWrittenPrescription? medicine}) async {
    final name = TextEditingController(text: medicine?.name);
    final dosage = TextEditingController(text: medicine?.dosage);
    final frequency = TextEditingController(text: medicine?.frequency);
    final duration = TextEditingController(text: medicine?.duration);
    final instructions = TextEditingController(text: medicine?.instructions);
    final result = await showModalBottomSheet<DoctorWrittenPrescription>(
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
              medicine == null ? 'Add Medicine' : 'Edit Medicine',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            _ModalField(controller: name, label: 'Medicine name'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ModalField(controller: dosage, label: 'Dosage'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ModalField(controller: duration, label: 'Duration'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _ModalField(controller: frequency, label: 'Frequency'),
            const SizedBox(height: 10),
            _ModalField(controller: instructions, label: 'Instructions'),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (name.text.trim().isEmpty || dosage.text.trim().isEmpty) {
                    return;
                  }
                  Navigator.of(sheetContext).pop(
                    DoctorWrittenPrescription(
                      name: name.text.trim(),
                      dosage: dosage.text.trim(),
                      frequency: frequency.text.trim(),
                      duration: duration.text.trim(),
                      instructions: instructions.text.trim(),
                    ),
                  );
                },
                child: Text(medicine == null ? 'Add Medicine' : 'Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    dosage.dispose();
    frequency.dispose();
    duration.dispose();
    instructions.dispose();
    if (result == null || !mounted) return;
    if (medicine == null) {
      await _controller.addMedicine(result);
    } else {
      await _controller.updateMedicine(medicine, result);
    }
  }

  void _preview() {
    final state = _controller.state;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        minChildSize: 0.45,
        maxChildSize: 0.94,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
          children: [
            const Text(
              'Prescription Preview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text('${widget.patientName} · ${widget.appointmentId}'),
            const Divider(height: 28),
            Text(
              'Diagnosis',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(state.diagnosis),
            const SizedBox(height: 16),
            Text(
              'Medicines',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            for (final medicine in state.medicines)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.medication_outlined, color: _teal),
                title: Text('${medicine.name} ${medicine.dosage}'),
                subtitle: Text(
                  '${medicine.frequency} · ${medicine.duration}\n${medicine.instructions}',
                ),
              ),
            if (state.labTests.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Lab tests',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              Text(state.labTests.join(', ')),
            ],
            const SizedBox(height: 16),
            Text(
              'Doctor notes',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(state.doctorNotes),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    await _controller.updateDiagnosis(_diagnosisController.text);
    await _controller.updateChiefComplaint(_complaintController.text);
    await _controller.updateDoctorNotes(_notesController.text);
    if (!mounted) return;

    if (!_controller.canSend) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a diagnosis and at least one medicine.'),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.send_rounded, color: _teal, size: 36),
        title: const Text('Send prescription?'),
        content: Text(
          'The prescription will be shared with ${widget.patientName}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Review'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    if (!mounted) return;

    if (confirmed == true) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_didSync) {
      _syncFields();
    }
    const symptoms = [
      'Fever',
      'Cough',
      'Headache',
      'Fatigue',
      'Nausea',
      'Chest Pain',
      'Shortness of Breath',
      'Sore Throat',
      'Body Aches',
      'Loss of Appetite',
    ];
    const tests = [
      'CBC (Complete Blood Count)',
      'Blood Sugar (Fasting)',
      'HbA1c',
      'Lipid Profile',
      'Thyroid Function (TSH)',
      'Urine Complete',
      'Chest X-Ray',
      'ECG',
    ];
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final state = _controller.state;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(false),
              icon: const Icon(Icons.chevron_left_rounded),
              iconSize: 32,
            ),
            title: const Text(
              'Write Prescription',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: OutlinedButton.icon(
                  onPressed: _preview,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Preview'),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await _controller.saveDraft();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Prescription draft saved.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Save Draft'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Send Prescription'),
                  ),
                ),
              ],
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                children: [
                  _PatientPrescriptionHeader(widget: widget),
                  const SizedBox(height: 18),
                  const _SectionTitle('1. Diagnosis & Chief Complaint'),
                  const SizedBox(height: 10),
                  _LabeledField(
                    label: 'Primary Diagnosis',
                    controller: _diagnosisController,
                    onChanged: _controller.updateDiagnosis,
                  ),
                  const SizedBox(height: 10),
                  _LabeledField(
                    label: 'Chief Complaint',
                    controller: _complaintController,
                    maxLines: 2,
                    onChanged: _controller.updateChiefComplaint,
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('2. Common Symptoms'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 7,
                    children: [
                      for (final symptom in symptoms)
                        FilterChip(
                          selected: state.symptoms.contains(symptom),
                          showCheckmark: true,
                          label: Text(symptom),
                          onSelected: (_) => _controller.toggleSymptom(symptom),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(child: _SectionTitle('3. Medicines')),
                      OutlinedButton.icon(
                        onPressed: _editMedicine,
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: const Text('Add Medicine'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (var index = 0; index < state.medicines.length; index++)
                    _MedicineCard(
                      index: index + 1,
                      medicine: state.medicines[index],
                      onEdit: () =>
                          _editMedicine(medicine: state.medicines[index]),
                      onDelete: () => _controller.removeMedicineAt(index),
                    ),
                  const SizedBox(height: 12),
                  const _SectionTitle('4. Lab Tests'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 7,
                    children: [
                      for (final test in tests)
                        FilterChip(
                          selected: state.labTests.contains(test),
                          label: Text(test),
                          onSelected: (_) => _controller.toggleLabTest(test),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final followUp = _FollowUpCard(
                        enabled: state.followUp,
                        selected: state.followUpAfter,
                        onEnabled: _controller.setFollowUp,
                        onSelected: _controller.setFollowUpAfter,
                      );
                      final notes = _DoctorNotes(
                        controller: _notesController,
                        onChanged: _controller.updateDoctorNotes,
                      );
                      if (constraints.maxWidth < 520) {
                        return Column(
                          children: [
                            followUp,
                            const SizedBox(height: 14),
                            notes,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: followUp),
                          const SizedBox(width: 14),
                          Expanded(child: notes),
                        ],
                      );
                    },
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

class _PatientPrescriptionHeader extends StatelessWidget {
  const _PatientPrescriptionHeader({required this.widget});
  final WritePrescriptionScreen widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFCDEBE8)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: _WritePrescriptionScreenState._teal,
            child: Text(
              widget.patientName.characters.first,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.patientName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${widget.patientAge} yrs  ·  ${widget.patientGender}  ·  A+ Blood',
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Appointment ID', style: TextStyle(fontSize: 10)),
              Text(
                widget.appointmentId,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(_todayLabel(), style: const TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
  );
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.onChanged,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: maxLines,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
    ],
  );
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({
    required this.index,
    required this.medicine,
    required this.onEdit,
    required this.onDelete,
  });

  final int index;
  final DoctorWrittenPrescription medicine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 9),
    child: Padding(
      padding: const EdgeInsets.all(11),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _WritePrescriptionScreenState._teal,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              '$index',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  '${medicine.dosage}  ·  ${medicine.frequency}  ·  ${medicine.duration}',
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  medicine.instructions,
                  style: const TextStyle(
                    color: _WritePrescriptionScreenState._teal,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            tooltip: 'Edit medicine',
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: onDelete,
            tooltip: 'Delete medicine',
            color: Colors.red,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    ),
  );
}

class _FollowUpCard extends StatelessWidget {
  const _FollowUpCard({
    required this.enabled,
    required this.selected,
    required this.onEnabled,
    required this.onSelected,
  });

  final bool enabled;
  final String selected;
  final ValueChanged<bool> onEnabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle('5. Follow Up'),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDDE5E7)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(child: Text('Schedule Follow Up')),
                Switch(value: enabled, onChanged: onEnabled),
              ],
            ),
            if (enabled)
              Wrap(
                spacing: 6,
                children: [
                  for (final value in const [
                    '1 week',
                    '2 weeks',
                    '1 month',
                    '3 months',
                  ])
                    ChoiceChip(
                      selected: selected == value,
                      label: Text(value),
                      onSelected: (_) => onSelected(value),
                    ),
                ],
              ),
          ],
        ),
      ),
    ],
  );
}

class _DoctorNotes extends StatelessWidget {
  const _DoctorNotes({required this.controller, this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle('6. Doctor Notes'),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        onChanged: onChanged,
        minLines: 5,
        maxLines: 7,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          alignLabelWithHint: true,
          labelText: 'Clinical notes',
        ),
      ),
    ],
  );
}

class _ModalField extends StatelessWidget {
  const _ModalField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}

String _todayLabel() {
  final value = DateTime.now();
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
  return '${value.day} ${months[value.month - 1]} ${value.year}';
}
