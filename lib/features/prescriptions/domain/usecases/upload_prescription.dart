import 'dart:typed_data';

import '../entities/prescription_record.dart';
import '../repositories/prescription_repository.dart';

class UploadPrescription {
  const UploadPrescription(this._repository);

  final PrescriptionRepository _repository;

  Future<PrescriptionRecord> call({
    required String patientId,
    required String fileName,
    required Uint8List fileBytes,
    required String contentType,
  }) {
    final trimmedPatientId = patientId.trim();
    final trimmedFileName = fileName.trim();
    final trimmedContentType = contentType.trim().toLowerCase();

    if (trimmedPatientId.isEmpty) {
      throw ArgumentError('patientId cannot be empty.');
    }

    if (trimmedFileName.isEmpty) {
      throw ArgumentError('fileName cannot be empty.');
    }

    if (fileBytes.isEmpty) {
      throw ArgumentError('fileBytes cannot be empty.');
    }

    if (trimmedContentType.isEmpty) {
      throw ArgumentError('contentType cannot be empty.');
    }

    return _repository.uploadPrescription(
      patientId: trimmedPatientId,
      fileName: trimmedFileName,
      fileBytes: fileBytes,
      contentType: trimmedContentType,
    );
  }
}
