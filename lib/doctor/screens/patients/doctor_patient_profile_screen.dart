import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/di/service_locator.dart';
import '../../features/patient_notes/data/datasources/doctor_patient_notes_mock_data_source.dart';
import '../../features/patient_notes/data/repositories/doctor_patient_notes_repository_impl.dart';
import '../../features/patient_notes/presentation/controllers/doctor_patient_notes_controller.dart';
import '../consultation/doctor_consultation_screen.dart';
import '../consultation/write_prescription_screen.dart';

class DoctorPatientProfileScreen extends StatefulWidget {
  const DoctorPatientProfileScreen({
    super.key,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.appointmentId,
    this.imageAsset = 'assets/images/doctor_ali.png',
    this.notesController,
  });

  final String patientName;
  final int patientAge;
  final String patientGender;
  final String appointmentId;
  final String imageAsset;
  final DoctorPatientNotesController? notesController;

  @override
  State<DoctorPatientProfileScreen> createState() =>
      _DoctorPatientProfileScreenState();
}

class _DoctorPatientProfileScreenState
    extends State<DoctorPatientProfileScreen> {
  static const _teal = Color(0xFF078D83);
  late final DoctorPatientNotesController _notesController =
      widget.notesController ??
      (sl.isRegistered<DoctorPatientNotesController>()
          ? sl<DoctorPatientNotesController>()
          : DoctorPatientNotesController(
              repository: DoctorPatientNotesRepositoryImpl(
                dataSource: AppConfig.useMockApi
                    ? DoctorPatientNotesMockDataSource()
                    : throw UnimplementedError(
                        'Remote datasource not yet available — enable mock mode for development',
                      ),
              ),
            ));

  @override
  void initState() {
    super.initState();
    _notesController.load(patientRecordId: widget.appointmentId);
  }

  @override
  void dispose() {
    if (widget.notesController == null) {
      _notesController.dispose();
    }
    super.dispose();
  }

  void _showMessage(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(value)),
      );
  }

  Future<void> _startConsultation() async {
    final prescribed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => DoctorConsultationScreen(
          patientName: widget.patientName,
          patientAge: widget.patientAge,
          patientGender: widget.patientGender,
          appointmentId: widget.appointmentId,
          isVideo: true,
        ),
      ),
    );
    if (prescribed == true && mounted) {
      _showMessage('Prescription sent and consultation completed.');
    }
  }

  Future<void> _newPrescription() async {
    final sent = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => WritePrescriptionScreen(
          patientName: widget.patientName,
          patientAge: widget.patientAge,
          patientGender: widget.patientGender,
          appointmentId: widget.appointmentId,
        ),
      ),
    );
    if (sent == true && mounted) {
      _showMessage('Prescription sent successfully.');
    }
  }

  Future<void> _scheduleFollowUp() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      _showMessage('Follow-up scheduled for ${_date(date)}.');
    }
  }

  Future<void> _addNote() async {
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _AddNoteSheet(),
    );
    if (note != null && note.isNotEmpty && mounted) {
      await _notesController.addNote(note);
      _showMessage('Clinical note saved.');
    }
  }

  Future<void> _orderTest() async {
    final tests = <String>{};
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Lab Tests',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                for (final test in const [
                  'CBC',
                  'Blood Sugar',
                  'HbA1c',
                  'Lipid Profile',
                  'Chest X-Ray',
                ])
                  CheckboxListTile(
                    value: tests.contains(test),
                    title: Text(test),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (selected) => setSheetState(
                      () => selected == true
                          ? tests.add(test)
                          : tests.remove(test),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: tests.isEmpty
                        ? null
                        : () => Navigator.of(sheetContext).pop(tests),
                    child: const Text('Place Test Order'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null && mounted) {
      _showMessage(
        '${result.length} test order${result.length == 1 ? '' : 's'} placed.',
      );
    }
  }

  void _openMessage() {
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
              'Message ${widget.patientName}',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write a message...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _showMessage('Message sent.');
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _notesController,
      builder: (context, _) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        bottomNavigationBar: _PatientBottomActions(
          onFollowUp: _scheduleFollowUp,
          onConsultation: _startConsultation,
        ),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                children: [
                  _ProfileTopBar(
                    onBack: () => Navigator.of(context).pop(),
                    onCall: () =>
                        _showMessage('Calling ${widget.patientName}...'),
                    onMessage: _openMessage,
                  ),
                  _PatientHero(widget: widget),
                  const SizedBox(height: 12),
                  const _PatientStats(),
                  const SizedBox(height: 12),
                  _ProfileTabs(
                    selected: _notesController.state.selectedTab,
                    onSelected: _notesController.selectTab,
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _notesController.state.selectedTab,
                      children: [
                        _OverviewTab(
                          patientName: widget.patientName,
                          onEdit: () => _showMessage(
                            'Patient information editor opened.',
                          ),
                          onAddNote: _addNote,
                          onPrescription: _newPrescription,
                          onOrderTest: _orderTest,
                          onFollowUp: _scheduleFollowUp,
                        ),
                        const _HistoryTab(),
                        _PrescriptionsTab(onNewPrescription: _newPrescription),
                        const _ReportsTab(),
                        _NotesTab(
                          notes: _notesController.state.notes,
                          onAdd: _addNote,
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
    );
  }
}

class _AddNoteSheet extends StatefulWidget {
  const _AddNoteSheet();

  @override
  State<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<_AddNoteSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          18,
          0,
          18,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Clinical Note',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              minLines: 4,
              maxLines: 7,
              decoration: const InputDecoration(
                labelText: 'Note',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop(_controller.text.trim()),
                child: const Text('Save Note'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({
    required this.onBack,
    required this.onCall,
    required this.onMessage,
  });
  final VoidCallback onBack;
  final VoidCallback onCall;
  final VoidCallback onMessage;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
    child: Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          iconSize: 28,
        ),
        const Spacer(),
        IconButton(
          onPressed: onCall,
          tooltip: 'Call patient',
          icon: const Icon(Icons.call_outlined),
          iconSize: 25,
        ),
        Stack(
          children: [
            IconButton(
              onPressed: onMessage,
              tooltip: 'Message patient',
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              iconSize: 24,
            ),
            const Positioned(
              right: 7,
              top: 4,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Color(0xFFEF4056),
                child: Text(
                  '2',
                  style: TextStyle(color: Colors.white, fontSize: 8),
                ),
              ),
            ),
          ],
        ),
        PopupMenuButton<String>(
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'share', child: Text('Share profile summary')),
            PopupMenuItem(value: 'archive', child: Text('Archive patient')),
          ],
          onSelected: (value) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                value == 'share'
                    ? 'Profile summary ready to share.'
                    : 'Patient archived.',
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _PatientHero extends StatelessWidget {
  const _PatientHero({required this.widget});
  final DoctorPatientProfileScreen widget;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
    child: Row(
      children: [
        Semantics(
          image: true,
          label: 'Profile photo of ${widget.patientName}',
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _DoctorPatientProfileScreenState._teal,
                width: 2,
              ),
              color: const Color(0xFFE5F5F2),
              image: DecorationImage(
                image: AssetImage(widget.imageAsset),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      widget.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Icon(
                    Icons.verified_rounded,
                    color: _DoctorPatientProfileScreenState._teal,
                    size: 19,
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                '${widget.patientAge} yrs  |  ${widget.patientGender}  |  A+ Blood',
                style: const TextStyle(color: Color(0xFF59657A), fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PatientStats extends StatelessWidget {
  const _PatientStats();
  @override
  Widget build(BuildContext context) {
    const stats = [
      (
        Icons.calendar_month_outlined,
        '5',
        'Visits',
        Color(0xFF078D83),
        Color(0xFFE8F7F5),
      ),
      (
        Icons.description_outlined,
        '3',
        'Prescriptions',
        Color(0xFF7E3FD4),
        Color(0xFFF4EBFF),
      ),
      (
        Icons.monitor_heart_outlined,
        '2',
        'Follow-ups',
        Color(0xFFFF6658),
        Color(0xFFFFECEA),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _PatientStatCard(
                    icon: stats[i].$1,
                    value: stats[i].$2,
                    label: stats[i].$3,
                    foreground: stats[i].$4,
                    background: stats[i].$5,
                    compact: compact,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PatientStatCard extends StatelessWidget {
  const _PatientStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.foreground,
    required this.background,
    required this.compact,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color foreground;
  final Color background;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconBox = Container(
      width: compact ? 32 : 38,
      height: compact ? 32 : 38,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: foreground, size: compact ? 18 : 21),
    );
    final copy = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: compact
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10, color: Color(0xFF626D80)),
        ),
      ],
    );

    return Semantics(
      label: '$value $label',
      child: Container(
        height: compact ? 92 : 72,
        padding: EdgeInsets.all(compact ? 6 : 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: compact
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [iconBox, const SizedBox(height: 3), copy],
              )
            : Row(
                children: [
                  iconBox,
                  const SizedBox(width: 9),
                  Expanded(child: copy),
                ],
              ),
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({required this.selected, required this.onSelected});
  final int selected;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) {
    const tabs = [
      (Icons.person_rounded, 'Overview'),
      (Icons.history_rounded, 'History'),
      (Icons.medication_outlined, 'Prescriptions'),
      (Icons.description_outlined, 'Reports'),
      (Icons.note_alt_outlined, 'Notes'),
    ];
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xFFE3E9EA)),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onSelected(i),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: selected == i
                            ? _DoctorPatientProfileScreenState._teal
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tabs[i].$1,
                        color: selected == i
                            ? _DoctorPatientProfileScreenState._teal
                            : const Color(0xFF697386),
                        size: 20,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tabs[i].$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: selected == i
                              ? FontWeight.w900
                              : FontWeight.w600,
                          color: selected == i
                              ? _DoctorPatientProfileScreenState._teal
                              : const Color(0xFF697386),
                        ),
                      ),
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

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.patientName,
    required this.onEdit,
    required this.onAddNote,
    required this.onPrescription,
    required this.onOrderTest,
    required this.onFollowUp,
  });
  final String patientName;
  final VoidCallback onEdit;
  final VoidCallback onAddNote;
  final VoidCallback onPrescription;
  final VoidCallback onOrderTest;
  final VoidCallback onFollowUp;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
    children: [
      _ProfileCard(
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  color: _DoctorPatientProfileScreenState._teal,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Personal Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const Divider(height: 20),
            const _InfoRow(
              icon: Icons.calendar_month_outlined,
              label: 'Date of Birth',
              value: '15 Mar 1993 (32 yrs)',
            ),
            const _InfoRow(
              icon: Icons.call_outlined,
              label: 'Phone',
              value: '0300-1234567',
            ),
            const _InfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: 'ahmed@email.com',
            ),
            const _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'City',
              value: 'Karachi, Pakistan',
            ),
            const _InfoRow(
              icon: Icons.bloodtype_outlined,
              label: 'Blood Group',
              value: 'A+',
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: _DoctorPatientProfileScreenState._teal,
                ),
                SizedBox(width: 7),
                Flexible(
                  child: Text(
                    'Patient information is secure and private',
                    style: TextStyle(fontSize: 11, color: Color(0xFF697386)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      const _ProfileCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Allergies & Conditions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
                Text('View All  ›', style: TextStyle(color: Color(0xFF626D80))),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _ConditionChip('Penicillin', Colors.red),
                _ConditionChip('Aspirin', Colors.orange),
                _ConditionChip('Diabetes Type 2', Colors.purple),
                _ConditionChip('Hypertension', Colors.blue),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      const _ProfileCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  color: _DoctorPatientProfileScreenState._teal,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Last Visit Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
                Text(
                  'View Details  ›',
                  style: TextStyle(color: Color(0xFF626D80)),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.event_outlined, size: 18, color: Color(0xFF697386)),
                SizedBox(width: 7),
                Text('01 May 2025'),
                Spacer(),
                Chip(
                  avatar: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                  label: Text('Completed'),
                ),
              ],
            ),
            SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFEAF8F7),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Padding(
                padding: EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnosis',
                      style: TextStyle(
                        color: _DoctorPatientProfileScreenState._teal,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Upper Respiratory Infection',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Divider(),
                    Text(
                      'Doctor Notes',
                      style: TextStyle(
                        color: _DoctorPatientProfileScreenState._teal,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Patient responded well to antibiotics. Follow up in 2 weeks if symptoms persist.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _QuickClinicalAction(
              icon: Icons.note_add_outlined,
              label: 'Add Note',
              onTap: onAddNote,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _QuickClinicalAction(
              icon: Icons.medication_outlined,
              label: 'New Prescription',
              onTap: onPrescription,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _QuickClinicalAction(
              icon: Icons.science_outlined,
              label: 'Order Test',
              onTap: onOrderTest,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _QuickClinicalAction(
              icon: Icons.event_repeat_rounded,
              label: 'Follow-up',
              onTap: onFollowUp,
            ),
          ),
        ],
      ),
    ],
  );
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();
  @override
  Widget build(BuildContext context) => const _SimpleList(
    title: 'Visit History',
    items: [
      ('01 May 2025', 'Upper Respiratory Infection - Completed'),
      ('12 Mar 2025', 'Routine follow-up - Completed'),
      ('04 Jan 2025', 'Seasonal flu - Completed'),
    ],
  );
}

class _PrescriptionsTab extends StatelessWidget {
  const _PrescriptionsTab({required this.onNewPrescription});
  final VoidCallback onNewPrescription;
  @override
  Widget build(BuildContext context) => _SimpleList(
    title: 'Prescriptions',
    action: FilledButton.icon(
      onPressed: onNewPrescription,
      icon: const Icon(Icons.add_rounded),
      label: const Text('New'),
    ),
    items: const [
      ('01 May 2025', 'Amoxicillin, Paracetamol'),
      ('12 Mar 2025', 'Vitamin D3'),
      ('04 Jan 2025', 'Oseltamivir'),
    ],
  );
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();
  @override
  Widget build(BuildContext context) => const _SimpleList(
    title: 'Lab Reports',
    items: [
      ('29 Apr 2025', 'CBC - Normal'),
      ('28 Apr 2025', 'Chest X-Ray - Clear'),
      ('10 Mar 2025', 'HbA1c - 6.8%'),
    ],
  );
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.notes, required this.onAdd});
  final List<String> notes;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Row(
        children: [
          const Expanded(
            child: Text(
              'Clinical Notes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      for (final note in notes)
        Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(padding: const EdgeInsets.all(14), child: Text(note)),
        ),
    ],
  );
}

class _SimpleList extends StatelessWidget {
  const _SimpleList({required this.title, required this.items, this.action});
  final String title;
  final List<(String, String)> items;
  final Widget? action;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ),
          ?action,
        ],
      ),
      const SizedBox(height: 12),
      for (final item in items)
        Card(
          margin: const EdgeInsets.only(bottom: 9),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.description_outlined),
            ),
            title: Text(
              item.$1,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(item.$2),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
        ),
    ],
  );
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFE5EAEC)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, color: _DoctorPatientProfileScreenState._teal, size: 19),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF697386), fontSize: 11),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _ConditionChip extends StatelessWidget {
  const _ConditionChip(this.label, this.color);
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: color.withValues(alpha: 0.25)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.warning_rounded, color: color, size: 15),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _QuickClinicalAction extends StatelessWidget {
  const _QuickClinicalAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(13),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE4E9EB)),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _DoctorPatientProfileScreenState._teal, size: 22),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PatientBottomActions extends StatelessWidget {
  const _PatientBottomActions({
    required this.onFollowUp,
    required this.onConsultation,
  });
  final VoidCallback onFollowUp;
  final VoidCallback onConsultation;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final buttonStyle = ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
          ),
          textStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: compact ? 12 : 14, fontWeight: FontWeight.w800),
          ),
        );
        return Container(
          padding: const EdgeInsets.fromLTRB(14, 9, 14, 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: const [
              BoxShadow(
                color: Color(0x15000000),
                blurRadius: 16,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onFollowUp,
                  style: buttonStyle,
                  icon: const Icon(Icons.sync_rounded, size: 20),
                  label: Text(compact ? 'Follow-up' : 'Follow Up'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onConsultation,
                  style: buttonStyle,
                  icon: const Icon(Icons.videocam_rounded, size: 20),
                  label: Text(compact ? 'Consult' : 'Start Consultation'),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

String _date(DateTime value) {
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
