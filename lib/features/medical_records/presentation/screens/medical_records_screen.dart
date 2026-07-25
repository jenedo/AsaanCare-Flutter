import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../domain/entities/medical_record.dart';
import '../controllers/medical_records_controller.dart';

enum _RecordFilter { all, prescriptions, labReports, imaging }

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key, required this.controller});

  final MedicalRecordsController controller;

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  _RecordFilter _selectedFilter = _RecordFilter.all;
  bool _showSearch = false;

  List<MedicalRecord> get _filteredRecords {
    final query = _searchController.text.trim().toLowerCase();

    return widget.controller.records
        .where((record) {
          final matchesFilter = switch (_selectedFilter) {
            _RecordFilter.all => true,
            _RecordFilter.prescriptions =>
              record.purpose == MedicalRecordPurpose.prescriptionAttachment,
            _RecordFilter.labReports =>
              record.purpose == MedicalRecordPurpose.labResult,
            _RecordFilter.imaging =>
              record.purpose == MedicalRecordPurpose.imaging,
          };

          final matchesSearch =
              query.isEmpty ||
              record.id.toLowerCase().contains(query) ||
              record.mimeType.toLowerCase().contains(query) ||
              record.purpose.name.toLowerCase().contains(query);

          return matchesFilter && matchesSearch;
        })
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    widget.controller.loadRecords();
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

  Future<void> _uploadDocument() async {
    final uploaded = await widget.controller.pickAndUploadFile(
      purpose: _selectedFilter == _RecordFilter.prescriptions
          ? MedicalRecordPurpose.prescriptionAttachment
          : MedicalRecordPurpose.medicalRecord,
    );

    if (!mounted) return;

    final error = widget.controller.errorMessage;

    if (uploaded) {
      setState(() {
        _selectedFilter = _RecordFilter.all;
        _searchController.clear();
      });
      _showSnackBar(
        'Medical document uploaded successfully. Security verification in progress (VALIDATING).',
      );
      return;
    }

    if (error != null && error.trim().isNotEmpty) {
      _showSnackBar(error, isError: true);
    }
  }

  Future<void> _downloadRecord(MedicalRecord record) async {
    if (!record.canDownload) {
      _showSnackBar(
        'Download unavailable until security verification is PASSED.',
        isError: true,
      );
      return;
    }

    final url = await widget.controller.fetchDownloadUrl(record);
    if (!mounted) return;

    if (url != null) {
      _showSnackBar('Download URL generated successfully.');
      return;
    }

    _showSnackBar(
      widget.controller.errorMessage ?? 'Download failed.',
      isError: true,
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
        Navigator.of(context).pushReplacementNamed(AppRoutes.wallet);
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
        onPressed: controller.isUploading ? null : _uploadDocument,
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
              onRefresh: controller.loadRecords,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                children: [
                  _Header(
                    searchOpen: _showSearch,
                    onSearchTap: () {
                      setState(() {
                        _showSearch = !_showSearch;
                        if (!_showSearch) _searchController.clear();
                      });
                    },
                  ),
                  if (_showSearch)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search medical records...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: AppTheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: AppTheme.border,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 22),
                  _FilterChips(
                    selected: _selectedFilter,
                    onSelected: (filter) =>
                        setState(() => _selectedFilter = filter),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Recent Medical Records',
                          style: TextStyle(
                            color: Color(0xFF07132D),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (hasActiveFilter)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilter = _RecordFilter.all;
                              _searchController.clear();
                            });
                          },
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (controller.isLoading && controller.records.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (controller.hasError && controller.records.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                          controller.errorMessage ?? 'Failed to load records.',
                          style: const TextStyle(color: AppTheme.danger),
                        ),
                      ),
                    )
                  else if (records.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: Text('No medical records found.')),
                    )
                  else
                    for (final record in records)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RecordCard(
                          record: record,
                          isDownloading: controller.isDownloading,
                          onDownloadTap: () => _downloadRecord(record),
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
            selectedColor: AppTheme.softTeal,
            backgroundColor: AppTheme.surface,
          );
        },
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    required this.isDownloading,
    required this.onDownloadTap,
  });

  final MedicalRecord record;
  final bool isDownloading;
  final VoidCallback onDownloadTap;

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (record.scanStatus) {
      MedicalRecordScanStatus.pending => 'PENDING',
      MedicalRecordScanStatus.validating => 'VALIDATING',
      MedicalRecordScanStatus.passed =>
        record.isAvailable ? 'PASSED' : 'PROCESSING',
      MedicalRecordScanStatus.rejected => 'REJECTED',
      MedicalRecordScanStatus.quarantined => 'QUARANTINED',
      MedicalRecordScanStatus.error => 'ERROR',
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.description_rounded,
            color: AppTheme.primary,
            size: 36,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.purpose.name.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF07132D),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Status: $statusLabel • ${(record.sizeBytes / 1024).toStringAsFixed(1)} KB',
                  style: const TextStyle(
                    color: Color(0xFF657386),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (record.canDownload)
            IconButton(
              onPressed: isDownloading ? null : onDownloadTap,
              icon: const Icon(
                Icons.download_rounded,
                color: AppTheme.primary,
                size: 28,
              ),
            )
          else
            Chip(
              label: Text(
                statusLabel,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor:
                  record.scanStatus == MedicalRecordScanStatus.validating
                  ? Colors.amber.shade100
                  : AppTheme.border,
            ),
        ],
      ),
    );
  }
}
