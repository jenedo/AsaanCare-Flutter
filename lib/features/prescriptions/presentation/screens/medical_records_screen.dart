import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../domain/entities/prescription_record.dart';
import '../controllers/prescription_controller.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({
    super.key,
    required this.controller,
    this.patientId = PrescriptionController.mockPatientId,
  });

  final PrescriptionController controller;
  final String patientId;

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    widget.controller.loadPrescriptions(patientId: widget.patientId);
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

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppTheme.danger : null,
        content: Text(message),
      ),
    );
  }

  Future<void> _uploadPrescription() async {
    final uploaded = await widget.controller.pickAndUploadFile(
      patientId: widget.patientId,
    );

    if (!mounted) return;

    final error = widget.controller.errorMessage;

    if (uploaded) {
      _showSnackBar('Prescription uploaded successfully.');
      return;
    }

    if (error != null && error.trim().isNotEmpty) {
      _showSnackBar(error, isError: true);
    }
  }

  Future<void> _confirmDelete(PrescriptionRecord record) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete record?'),
          content: Text(
            'This will remove "${record.fileName}" from your records.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    final deleted = await widget.controller.deleteRecord(
      patientId: widget.patientId,
      prescriptionId: record.id,
    );

    if (!mounted) return;

    if (deleted) {
      _showSnackBar('Record deleted.');
      return;
    }

    _showSnackBar(
      widget.controller.errorMessage ?? 'Delete failed. Please try again.',
      isError: true,
    );
  }

  void _viewRecord(PrescriptionRecord record) {
    _showSnackBar(
      record.isUploaded
          ? 'Record viewer coming next.'
          : 'This record is not uploaded yet.',
    );
  }

  void _handleNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(AppRoutes.patientHome);
        return;

      case 1:
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.doctorDetail, arguments: 'doctor_ali');
        return;

      case 2:
        Navigator.of(context).pushReplacementNamed(AppRoutes.pharmacy);
        return;

      case 3:
        return;

      case 4:
        _showSnackBar('Wallet screen coming next.');
        return;

      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3,
        onTap: _handleNavTap,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.isUploading ? null : _uploadPrescription,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: controller.isUploading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.upload_file_outlined),
        label: Text(controller.isUploading ? 'Uploading' : 'Upload'),
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: RefreshIndicator(
              onRefresh: () {
                return controller.loadPrescriptions(
                  patientId: widget.patientId,
                );
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 120),
                children: [
                  _Header(
                    onSearchTap: () =>
                        _showSnackBar('Search records coming next.'),
                  ),
                  const SizedBox(height: 24),
                  const _FilterChips(),
                  const SizedBox(height: 28),
                  const _SectionTitle(title: 'Recent Records'),
                  const SizedBox(height: 16),
                  _RecordsBody(
                    controller: controller,
                    onRetry: () => controller.loadPrescriptions(
                      patientId: widget.patientId,
                    ),
                    onUploadTap: _uploadPrescription,
                    onViewTap: _viewRecord,
                    onDeleteTap: _confirmDelete,
                  ),
                  const SizedBox(height: 28),
                  const _SectionTitle(title: 'Health Summary'),
                  const SizedBox(height: 16),
                  const _HealthSummaryRow(),
                  const SizedBox(height: 28),
                  const _SecurityPanel(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordsBody extends StatelessWidget {
  const _RecordsBody({
    required this.controller,
    required this.onRetry,
    required this.onUploadTap,
    required this.onViewTap,
    required this.onDeleteTap,
  });

  final PrescriptionController controller;
  final VoidCallback onRetry;
  final VoidCallback onUploadTap;
  final ValueChanged<PrescriptionRecord> onViewTap;
  final ValueChanged<PrescriptionRecord> onDeleteTap;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && controller.records.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 70),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.hasError && controller.records.isEmpty) {
      return _ErrorState(
        message: controller.errorMessage ?? 'Something went wrong.',
        onRetry: onRetry,
      );
    }

    if (controller.records.isEmpty) {
      return _EmptyState(onUploadTap: onUploadTap);
    }

    return Column(
      children: controller.records
          .map((record) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RecordCard(
                record: record,
                isDeleting: controller.isDeleting,
                onViewTap: () => onViewTap(record),
                onDeleteTap: () => onDeleteTap(record),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'My Health Records',
            style: TextStyle(
              color: Color(0xFF07132D),
              fontSize: 31,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Search records',
          onPressed: onSearchTap,
          icon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF07132D),
            size: 34,
          ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    const chips = ['All', 'Prescriptions', 'Lab Reports', 'Imaging'];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = index == 0;

          return Semantics(
            button: true,
            selected: selected,
            label: chips[index],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppTheme.softTeal : AppTheme.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: selected ? const Color(0xFF9ADBD4) : AppTheme.border,
                ),
              ),
              child: Text(
                chips[index],
                style: TextStyle(
                  color: selected ? AppTheme.primary : const Color(0xFF07132D),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    required this.isDeleting,
    required this.onViewTap,
    required this.onDeleteTap,
  });

  final PrescriptionRecord record;
  final bool isDeleting;
  final VoidCallback onViewTap;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
    final isPending = record.status == PrescriptionStatus.pending;
    final isDoctorIssued = record.source == PrescriptionSource.doctorIssued;

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onViewTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: isDoctorIssued
                      ? const Color(0xFFFFF1F1)
                      : const Color(0xFFEAF7F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isDoctorIssued
                      ? Icons.receipt_long_outlined
                      : Icons.upload_file_outlined,
                  color: isDoctorIssued ? AppTheme.danger : AppTheme.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.fileName.replaceAll('_', ' '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF07132D),
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${record.source.label} • ${_formatDate(record.uploadedAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF657386),
                        fontSize: 13.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _StatusChip(
                        label: record.status.label,
                        isPending: isPending,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'View record',
                    onPressed: onViewTap,
                    icon: const Icon(
                      Icons.visibility_outlined,
                      color: AppTheme.primary,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete record',
                    onPressed: isDeleting ? null : onDeleteTap,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppTheme.danger,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.isPending});

  final String label;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xFFFFF3E0) : AppTheme.softTeal,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPending ? const Color(0xFFB26A00) : AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onUploadTap});

  final VoidCallback onUploadTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FBFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.folder_open_outlined,
            color: AppTheme.primary,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'No prescriptions yet',
            style: TextStyle(
              color: Color(0xFF07132D),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Upload your first prescription to keep it available in your records.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF657386),
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onUploadTap,
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Upload Prescription'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppTheme.danger,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF07132D),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _HealthSummaryRow extends StatelessWidget {
  const _HealthSummaryRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _SummaryCard(label: 'Height', value: '168', unit: 'cm'),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(label: 'Weight', value: '62', unit: 'kg'),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(label: 'Blood Group', value: 'B+', unit: ''),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF657386),
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: Color(0xFF07132D),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      color: Color(0xFF07132D),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Updated 10 May',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Color(0xFF657386), fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _SecurityPanel extends StatelessWidget {
  const _SecurityPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_outlined, color: AppTheme.primary, size: 46),
          SizedBox(width: 16),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Private Records Flow\n',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text:
                        'Backend storage will use private files and signed access. Do not expose medical files publicly.',
                    style: TextStyle(
                      color: Color(0xFF07132D),
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF07132D),
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.3,
      ),
    );
  }
}

String _formatDate(DateTime date) {
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

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
