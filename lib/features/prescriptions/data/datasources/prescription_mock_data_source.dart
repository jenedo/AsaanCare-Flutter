import 'dart:convert';
import 'dart:typed_data';

import '../../domain/entities/prescription_record.dart';

class PrescriptionMockDataSource {
  PrescriptionMockDataSource() {
    _records.addAll(_seedRecords());
  }

  static const int _maxFileSizeInBytes = 5 * 1024 * 1024;

  static const Set<String> _allowedContentTypes = {
    'image/jpeg',
    'image/png',
    'application/pdf',
  };

  final List<PrescriptionRecord> _records = [];

  List<PrescriptionRecord> _seedRecords() {
    return [
      _createDemoRecord(
        id: 'mock_prescription_001',
        fileName: 'Dr_Ali_Raza_Prescription.pdf',
        uploadedAt: DateTime(2024, 5, 18),
        recordType: HealthRecordType.prescription,
        title: 'Prescription',
        summary: 'Dr. Ali Raza',
        issuer: 'Dr. Ali Raza',
      ),
      _createDemoRecord(
        id: 'mock_lab_001',
        fileName: 'Lipid_Profile_Report.pdf',
        uploadedAt: DateTime(2024, 5, 15),
        recordType: HealthRecordType.labReport,
        title: 'Lab Report',
        summary: 'Lipid Profile',
        issuer: 'AsaanCare Diagnostics',
      ),
      _createDemoRecord(
        id: 'mock_lab_002',
        fileName: 'Blood_Sugar_FBS_Report.pdf',
        uploadedAt: DateTime(2024, 5, 12),
        recordType: HealthRecordType.labReport,
        title: 'Lab Report',
        summary: 'Blood Sugar (FBS)',
        issuer: 'AsaanCare Diagnostics',
      ),
      _createDemoRecord(
        id: 'mock_imaging_001',
        fileName: 'Chest_XRay_Report.pdf',
        uploadedAt: DateTime(2024, 5, 10),
        recordType: HealthRecordType.imaging,
        title: 'X-Ray Report',
        summary: 'Chest X-Ray',
        issuer: 'AsaanCare Imaging',
      ),
    ];
  }

  PrescriptionRecord _createDemoRecord({
    required String id,
    required String fileName,
    required DateTime uploadedAt,
    required HealthRecordType recordType,
    required String title,
    required String summary,
    required String issuer,
  }) {
    return PrescriptionRecord(
      id: id,
      patientId: 'mock_patient_001',
      fileName: fileName,
      fileBytes: _buildDemoPdf(title: title, summary: summary, issuer: issuer),
      fileUrl: 'mock://records/$id/$fileName',
      uploadedAt: uploadedAt,
      source: PrescriptionSource.doctorIssued,
      status: PrescriptionStatus.reviewed,
      recordType: recordType,
      title: title,
      summary: summary,
      issuer: issuer,
    );
  }

  Future<PrescriptionRecord> uploadPrescription({
    required String patientId,
    required String fileName,
    required Uint8List fileBytes,
    required String contentType,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final trimmedPatientId = patientId.trim();
    final trimmedFileName = fileName.trim();
    final normalizedContentType = contentType.trim().toLowerCase();

    _validateUploadInput(
      patientId: trimmedPatientId,
      fileName: trimmedFileName,
      fileBytes: fileBytes,
      contentType: normalizedContentType,
    );

    final now = DateTime.now();
    final id = 'prescription_${now.microsecondsSinceEpoch}';
    final safeFileName = Uri.encodeComponent(trimmedFileName);

    final record = PrescriptionRecord(
      id: id,
      patientId: trimmedPatientId,
      fileName: trimmedFileName,
      fileBytes: Uint8List.fromList(fileBytes),
      fileUrl: 'mock://prescriptions/$id/$safeFileName',
      uploadedAt: now,
      source: PrescriptionSource.patientUploaded,
      status: PrescriptionStatus.pending,
      recordType: HealthRecordType.prescription,
      title: 'Uploaded Prescription',
      summary: trimmedFileName.replaceAll('_', ' '),
      issuer: 'Patient Upload',
    );

    _records.insert(0, record);
    return record;
  }

  Future<List<PrescriptionRecord>> getPrescriptions({
    required String patientId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final trimmedPatientId = patientId.trim();

    if (trimmedPatientId.isEmpty) {
      throw ArgumentError('patientId cannot be empty.');
    }

    final patientRecords = _records.where(
      (record) => record.patientId == trimmedPatientId,
    );

    return List<PrescriptionRecord>.unmodifiable(patientRecords);
  }

  Future<void> deletePrescription({
    required String patientId,
    required String prescriptionId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final trimmedPatientId = patientId.trim();
    final trimmedPrescriptionId = prescriptionId.trim();

    if (trimmedPatientId.isEmpty) {
      throw ArgumentError('patientId cannot be empty.');
    }

    if (trimmedPrescriptionId.isEmpty) {
      throw ArgumentError('prescriptionId cannot be empty.');
    }

    final index = _records.indexWhere(
      (record) =>
          record.id == trimmedPrescriptionId &&
          record.patientId == trimmedPatientId,
    );

    if (index == -1) {
      throw StateError('Record not found or access denied.');
    }

    _records.removeAt(index);
  }

  void _validateUploadInput({
    required String patientId,
    required String fileName,
    required Uint8List fileBytes,
    required String contentType,
  }) {
    if (patientId.isEmpty) {
      throw ArgumentError('patientId cannot be empty.');
    }

    if (fileName.isEmpty) {
      throw ArgumentError('fileName cannot be empty.');
    }

    if (fileBytes.isEmpty) {
      throw ArgumentError('Prescription file cannot be empty.');
    }

    if (fileBytes.lengthInBytes > _maxFileSizeInBytes) {
      throw ArgumentError('Prescription file must be smaller than 5 MB.');
    }

    if (!_allowedContentTypes.contains(contentType)) {
      throw ArgumentError(
        'Unsupported file type. Only JPG, PNG, and PDF files are allowed.',
      );
    }
  }

  Uint8List _buildDemoPdf({
    required String title,
    required String summary,
    required String issuer,
  }) {
    final safeTitle = _escapePdfText(title);
    final safeSummary = _escapePdfText(summary);
    final safeIssuer = _escapePdfText(issuer);

    final content = [
      'BT',
      '/F1 22 Tf',
      '50 760 Td',
      '($safeTitle) Tj',
      '0 -36 Td',
      '/F1 14 Tf',
      '($safeSummary) Tj',
      '0 -24 Td',
      '/F1 11 Tf',
      '(Issued by: $safeIssuer) Tj',
      '0 -22 Td',
      '(Generated for the AsaanCare demo records module.) Tj',
      'ET',
    ].join('\n');

    final objects = <String>[
      '<< /Type /Catalog /Pages 2 0 R >>',
      '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
      '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] '
          '/Resources << /Font << /F1 5 0 R >> >> /Contents 4 0 R >>',
      '<< /Length ${utf8.encode(content).length} >>\nstream\n$content\nendstream',
      '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
    ];

    final bytes = <int>[];
    final offsets = <int>[0];

    void addText(String value) {
      bytes.addAll(utf8.encode(value));
    }

    addText('%PDF-1.4\n');

    for (var index = 0; index < objects.length; index++) {
      offsets.add(bytes.length);
      addText('${index + 1} 0 obj\n${objects[index]}\nendobj\n');
    }

    final xrefOffset = bytes.length;
    addText('xref\n0 ${objects.length + 1}\n');
    addText('0000000000 65535 f \n');

    for (final offset in offsets.skip(1)) {
      addText('${offset.toString().padLeft(10, '0')} 00000 n \n');
    }

    addText(
      'trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\n'
      'startxref\n$xrefOffset\n%%EOF',
    );

    return Uint8List.fromList(bytes);
  }

  String _escapePdfText(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll('(', r'\(')
        .replaceAll(')', r'\)');
  }
}
