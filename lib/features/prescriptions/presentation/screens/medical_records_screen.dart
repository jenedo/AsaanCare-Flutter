import 'package:flutter/material.dart';

import '../../../../core/design/app_motion.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../domain/entities/prescription_record.dart';
import '../controllers/prescription_controller.dart';

enum _RecordFilter { all, prescriptions, labReports, imaging }

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({
    super.key,
    required this.controller,
    required this.patientId,
  });

  final PrescriptionController controller;
  final String patientId;

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  _RecordFilter _selectedFilter = _RecordFilter.all;
  bool _showSearch = false;

  List<PrescriptionRecord> get _filteredRecords {
    final query = _searchController.text.trim().toLowerCase();

    return widget.controller.records
        .where((record) {
          final matchesFilter = switch (_selectedFilter) {
            _RecordFilter.all => true,
            _RecordFilter.prescriptions =>
              record.recordType == HealthRecordType.prescription,
            _RecordFilter.labReports =>
              record.recordType == HealthRecordType.labReport,
            _RecordFilter.imaging =>
              record.recordType == HealthRecordType.imaging,
          };

          final matchesSearch =
              query.isEmpty ||
              record.title.toLowerCase().contains(query) ||
              record.summary.toLowerCase().contains(query) ||
              record.issuer.toLowerCase().contains(query) ||
              record.fileName.toLowerCase().contains(query);

          return matchesFilter && matchesSearch;
        })
        .toList(growable: false);
  }

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
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
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
      setState(() {
        _selectedFilter = _RecordFilter.all;
        _searchController.clear();
      });
      _showSnackBar('Prescription uploaded successfully.');
      return;
    }

    if (error != null && error.trim().isNotEmpty) {
      _showSnackBar(error, isError: true);
    }
  }

  Future<void> _downloadRecord(PrescriptionRecord record) async {
    final downloaded = await widget.controller.downloadRecord(record);

    if (!mounted) return;

    if (downloaded) {
      _showSnackBar('Download started for ${record.fileName}.');
      return;
    }

    final error = widget.controller.errorMessage;
    if (error != null && error.trim().isNotEmpty) {
      _showSnackBar(error, isError: true);
    }
  }

  Future<void> _confirmDelete(PrescriptionRecord record) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete record?'),
          content: Text(
            'This will remove "${record.title}" from your records.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
              onPressed: () => Navigator.of(dialogContext).pop(true),
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

  void _showRecordDetails(PrescriptionRecord record) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final visual = _recordVisual(record.recordType);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 76,
                  width: 76,
                  decoration: BoxDecoration(
                    color: visual.background,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(visual.icon, color: visual.color, size: 40),
                ),
                const SizedBox(height: 18),
                Text(
                  record.title,
                  style: const TextStyle(
                    color: Color(0xFF07132D),
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  record.summary,
                  style: const TextStyle(
                    color: Color(0xFF536078),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                _DetailRow(label: 'Issued by', value: record.issuer),
                _DetailRow(
                  label: 'Date',
                  value: _formatDate(record.uploadedAt),
                ),
                _DetailRow(label: 'Status', value: record.status.label),
                _DetailRow(label: 'File', value: record.fileName),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.controller.isDownloading
                            ? null
                            : () {
                                Navigator.of(sheetContext).pop();
                                _downloadRecord(record);
                              },
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Download'),
                      ),
                    ),
                    if (record.source ==
                        PrescriptionSource.patientUploaded) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.danger,
                          ),
                          onPressed: widget.controller.isDeleting
                              ? null
                              : () {
                                  Navigator.of(sheetContext).pop();
                                  _confirmDelete(record);
                                },
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Delete'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        _searchFocusNode.unfocus();
      }
    });

    if (_showSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedFilter = _RecordFilter.all;
      _searchController.clear();
    });
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
        Navigator.of(context).pushReplacementNamed(AppRoutes.wallet);
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final records = _filteredRecords;
    final hasActiveFilter =
        _selectedFilter != _RecordFilter.all ||
        _searchController.text.trim().isNotEmpty;

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
            : const Icon(Icons.upload_file_rounded),
        label: Text(controller.isUploading ? 'Uploading' : 'Upload'),
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: RefreshIndicator(
              onRefresh: () {
                return controller.loadPrescriptions(
                  patientId: widget.patientId,
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                children: [
                  _Header(searchOpen: _showSearch, onSearchTap: _toggleSearch),
                  AnimatedSize(
                    duration: AppMotion.medium,
                    curve: AppMotion.standard,
                    child: _showSearch
                        ? Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Search reports, doctors, labs...',
                                prefixIcon: const Icon(Icons.search_rounded),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {});
                                        },
                                        icon: const Icon(Icons.close_rounded),
                                      )
                                    : null,
                                filled: true,
                                fillColor: AppTheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: AppTheme.border,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: AppTheme.border,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: AppTheme.primary,
                                    width: 1.7,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 22),
                  _FilterChips(
                    selected: _selectedFilter,
                    onSelected: (filter) {
                      setState(() => _selectedFilter = filter);
                    },
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Expanded(
                        child: _SectionTitle(title: 'Recent Records'),
                      ),
                      if (hasActiveFilter)
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _RecordsBody(
                    controller: controller,
                    records: records,
                    hasActiveFilter: hasActiveFilter,
                    onRetry: () => controller.loadPrescriptions(
                      patientId: widget.patientId,
                    ),
                    onUploadTap: _uploadPrescription,
                    onClearFilters: _clearFilters,
                    onViewTap: _showRecordDetails,
                    onDownloadTap: _downloadRecord,
                  ),
                  const SizedBox(height: 30),
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

class _Header extends StatelessWidget {
  const _Header({required this.searchOpen, required this.onSearchTap});

  final bool searchOpen;
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
          tooltip: searchOpen ? 'Close search' : 'Search records',
          onPressed: onSearchTap,
          icon: Icon(
            searchOpen ? Icons.close_rounded : Icons.search_rounded,
            color: const Color(0xFF07132D),
            size: 34,
          ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final _RecordFilter selected;
  final ValueChanged<_RecordFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    const items = [
      (_RecordFilter.all, 'All'),
      (_RecordFilter.prescriptions, 'Prescriptions'),
      (_RecordFilter.labReports, 'Lab Reports'),
      (_RecordFilter.imaging, 'Imaging'),
    ];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selected == item.$1;

          return ChoiceChip(
            label: Text(item.$2),
            selected: isSelected,
            onSelected: (_) => onSelected(item.$1),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            labelStyle: TextStyle(
              color: isSelected ? AppTheme.primary : const Color(0xFF07132D),
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
            ),
            selectedColor: AppTheme.softTeal,
            backgroundColor: AppTheme.surface,
            side: BorderSide(
              color: isSelected ? const Color(0xFF9ADBD4) : AppTheme.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          );
        },
      ),
    );
  }
}

class _RecordsBody extends StatelessWidget {
  const _RecordsBody({
    required this.controller,
    required this.records,
    required this.hasActiveFilter,
    required this.onRetry,
    required this.onUploadTap,
    required this.onClearFilters,
    required this.onViewTap,
    required this.onDownloadTap,
  });

  final PrescriptionController controller;
  final List<PrescriptionRecord> records;
  final bool hasActiveFilter;
  final VoidCallback onRetry;
  final VoidCallback onUploadTap;
  final VoidCallback onClearFilters;
  final ValueChanged<PrescriptionRecord> onViewTap;
  final ValueChanged<PrescriptionRecord> onDownloadTap;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && controller.records.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.hasError && controller.records.isEmpty) {
      return _ErrorState(
        message: controller.errorMessage ?? 'Something went wrong.',
        onRetry: onRetry,
      );
    }

    if (records.isEmpty) {
      return _EmptyState(
        filtered: hasActiveFilter,
        onActionTap: hasActiveFilter ? onClearFilters : onUploadTap,
      );
    }

    return AnimatedSwitcher(
      duration: AppMotion.medium,
      switchInCurve: AppMotion.standard,
      child: Column(
        key: ValueKey(records.map((record) => record.id).join('|')),
        children: [
          for (final record in records)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RecordCard(
                record: record,
                isDownloading: controller.isDownloading,
                onViewTap: () => onViewTap(record),
                onDownloadTap: () => onDownloadTap(record),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    required this.isDownloading,
    required this.onViewTap,
    required this.onDownloadTap,
  });

  final PrescriptionRecord record;
  final bool isDownloading;
  final VoidCallback onViewTap;
  final VoidCallback onDownloadTap;

  @override
  Widget build(BuildContext context) {
    final visual = _recordVisual(record.recordType);

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onViewTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 92),
          padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: visual.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(visual.icon, color: visual.color, size: 31),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF07132D),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${record.summary} • ${_formatDate(record.uploadedAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF657386),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(height: 52, width: 1, color: AppTheme.border),
              IconButton(
                tooltip: 'Download ${record.title}',
                onPressed: isDownloading ? null : onDownloadTap,
                icon: isDownloading
                    ? const SizedBox(
                        height: 19,
                        width: 19,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.download_rounded,
                        color: AppTheme.primary,
                        size: 29,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthSummaryRow extends StatelessWidget {
  const _HealthSummaryRow();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Height', '168', 'cm'),
      ('Weight', '62', 'kg'),
      ('Blood Group', 'B+', ''),
    ];

    return Row(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          Expanded(
            child: _HealthSummaryCard(
              label: items[index].$1,
              value: items[index].$2,
              unit: items[index].$3,
            ),
          ),
          if (index < items.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _HealthSummaryCard extends StatelessWidget {
  const _HealthSummaryCard({
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
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF657386),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFF07132D),
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 5),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      color: Color(0xFF07132D),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Updated 10 May',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Color(0xFF657386), fontSize: 12),
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
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: AppTheme.primary, size: 52),
          SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure & Private',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your records are scoped to your authenticated patient account. Production storage will use private signed access.',
                  style: TextStyle(
                    color: Color(0xFF07132D),
                    fontSize: 14,
                    height: 1.4,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF07132D),
        fontSize: 21,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF657386),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF07132D),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filtered, required this.onActionTap});

  final bool filtered;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(
            filtered ? Icons.search_off_rounded : Icons.folder_open_rounded,
            color: AppTheme.primary,
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            filtered ? 'No matching records' : 'No health records yet',
            style: const TextStyle(
              color: Color(0xFF07132D),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: onActionTap,
            child: Text(filtered ? 'Clear filters' : 'Upload prescription'),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppTheme.danger,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class _RecordVisual {
  const _RecordVisual({
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;
}

_RecordVisual _recordVisual(HealthRecordType type) {
  return switch (type) {
    HealthRecordType.prescription => const _RecordVisual(
      icon: Icons.receipt_long_outlined,
      color: Color(0xFFE53935),
      background: Color(0xFFFFF1F1),
    ),
    HealthRecordType.labReport => const _RecordVisual(
      icon: Icons.science_outlined,
      color: AppTheme.primary,
      background: Color(0xFFEAF7F5),
    ),
    HealthRecordType.imaging => const _RecordVisual(
      icon: Icons.image_search_outlined,
      color: Color(0xFF2563EB),
      background: Color(0xFFEEF4FF),
    ),
  };
}

String _formatDate(DateTime value) {
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
