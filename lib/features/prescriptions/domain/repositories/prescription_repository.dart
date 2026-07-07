import 'dart:typed_data';

import '../entities/prescription_record.dart';

abstract class PrescriptionRepository {
  Future<PrescriptionRecord> uploadPrescription({
    required String patientId,
    required String fileName,
    required Uint8List fileBytes,
    required String contentType,
  });

  Future<List<PrescriptionRecord>> getPrescriptions({
    required String patientId,
  });

  Future<void> deletePrescription({
    required String patientId,
    required String prescriptionId,
  });
}
