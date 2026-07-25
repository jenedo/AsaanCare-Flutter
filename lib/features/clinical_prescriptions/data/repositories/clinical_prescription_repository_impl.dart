// ignore_for_file: prefer_initializing_formals
import '../../domain/entities/clinical_prescription.dart';
import '../../domain/repositories/clinical_prescription_repository.dart';
import '../datasources/clinical_prescription_remote_data_source.dart';

class ClinicalPrescriptionRepositoryImpl
    implements ClinicalPrescriptionRepository {
  ClinicalPrescriptionRepositoryImpl({
    required ClinicalPrescriptionRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ClinicalPrescriptionRemoteDataSource _remoteDataSource;

  @override
  Future<List<ClinicalPrescription>> getClinicalPrescriptions() {
    return _remoteDataSource.getClinicalPrescriptions();
  }

  @override
  Future<ClinicalPrescription> getClinicalPrescription(String id) {
    return _remoteDataSource.getClinicalPrescription(id);
  }
}
