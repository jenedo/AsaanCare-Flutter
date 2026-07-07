import 'dart:typed_data';

import '../../domain/entities/prescription_record.dart';
import '../../domain/repositories/prescription_repository.dart';
import '../datasources/prescription_mock_data_source.dart';

class PrescriptionRepositoryImpl implements PrescriptionRepository {
  const PrescriptionRepositoryImpl({required this.mockDataSource});

  final PrescriptionMockDataSource mockDataSource;

  @override
  Future<PrescriptionRecord> uploadPrescription({
    required String patientId,
    required String fileName,
    required Uint8List fileBytes,
    required String contentType,
  }) {
    return mockDataSource.uploadPrescription(
      patientId: patientId,
      fileName: fileName,
      fileBytes: fileBytes,
      contentType: contentType,
    );
  }

  @override
  Future<List<PrescriptionRecord>> getPrescriptions({
    required String patientId,
  }) {
    return mockDataSource.getPrescriptions(patientId: patientId);
  }

  @override
  Future<void> deletePrescription({
    required String patientId,
    required String prescriptionId,
  }) {
    return mockDataSource.deletePrescription(
      patientId: patientId,
      prescriptionId: prescriptionId,
    );
  }
}
