import 'dart:typed_data';

import '../../../../core/config/app_config.dart';
import '../../domain/entities/prescription_record.dart';
import '../../domain/repositories/prescription_repository.dart';
import '../datasources/prescription_mock_data_source.dart';
import '../datasources/prescription_remote_data_source.dart';

class PrescriptionRepositoryImpl implements PrescriptionRepository {
  const PrescriptionRepositoryImpl({
    required this.mockDataSource,
    this.remoteDataSource,
  });

  final PrescriptionMockDataSource mockDataSource;
  final PrescriptionRemoteDataSource? remoteDataSource;

  @override
  Future<PrescriptionRecord> uploadPrescription({
    required String patientId,
    required String fileName,
    required Uint8List fileBytes,
    required String contentType,
  }) async {
    final remote = remoteDataSource;
    if (!AppConfig.useMockApi && remote != null) {
      try {
        return await remote.uploadPrescription(
          patientId: patientId,
          fileName: fileName,
          fileBytes: fileBytes,
          contentType: contentType,
        );
      } catch (_) {
        return mockDataSource.uploadPrescription(
          patientId: patientId,
          fileName: fileName,
          fileBytes: fileBytes,
          contentType: contentType,
        );
      }
    }
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
  }) async {
    final remote = remoteDataSource;
    if (!AppConfig.useMockApi && remote != null) {
      try {
        final records = await remote.getPrescriptions(patientId: patientId);
        if (records.isNotEmpty) return records;
      } catch (_) {}
    }
    return mockDataSource.getPrescriptions(patientId: patientId);
  }

  @override
  Future<void> deletePrescription({
    required String patientId,
    required String prescriptionId,
  }) async {
    final remote = remoteDataSource;
    if (!AppConfig.useMockApi && remote != null) {
      await remote.deletePrescription(
        patientId: patientId,
        prescriptionId: prescriptionId,
      );
    }
    return mockDataSource.deletePrescription(
      patientId: patientId,
      prescriptionId: prescriptionId,
    );
  }
}
