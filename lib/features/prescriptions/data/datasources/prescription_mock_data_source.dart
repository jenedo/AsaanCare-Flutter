import 'dart:typed_data';

import '../../domain/entities/prescription_record.dart';

class PrescriptionMockDataSource {
  PrescriptionMockDataSource();

  static const int _maxFileSizeInBytes = 5 * 1024 * 1024; // 5 MB

  static const Set<String> _allowedContentTypes = {
    'image/jpeg',
    'image/png',
    'application/pdf',
  };

  final List<PrescriptionRecord> _records = [
    PrescriptionRecord(
      id: 'mock_prescription_001',
      patientId: 'mock_patient_001',
      fileName: 'Dr_Ali_Raza_Prescription.pdf',
      fileBytes: null,
      fileUrl:
          'mock://prescriptions/mock_prescription_001/Dr_Ali_Raza_Prescription.pdf',
      uploadedAt: DateTime(2024, 5, 18),
      source: PrescriptionSource.doctorIssued,
      status: PrescriptionStatus.reviewed,
    ),
  ];

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
      fileBytes: null,
      fileUrl: 'mock://prescriptions/$id/$safeFileName',
      uploadedAt: now,
      source: PrescriptionSource.patientUploaded,
      status: PrescriptionStatus.pending,
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
      throw StateError('Prescription not found or access denied.');
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
}
