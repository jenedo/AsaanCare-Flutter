import '../../../../core/config/app_config.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/entities/prescription_order.dart';
import '../../domain/repositories/pharmacy_repository.dart';
import '../datasources/pharmacy_mock_data_source.dart';
import '../datasources/pharmacy_remote_data_source.dart';

class PharmacyRepositoryImpl implements PharmacyRepository {
  const PharmacyRepositoryImpl({this.mockDataSource, this.remoteDataSource});

  final PharmacyMockDataSource? mockDataSource;
  final PharmacyRemoteDataSource? remoteDataSource;

  @override
  Future<List<Medicine>> getPopularMedicines() async {
    final remote = remoteDataSource;
    if (!AppConfig.useMockApi && remote != null) {
      try {
        final medicines = await remote.getPopularMedicines();
        if (medicines.isNotEmpty) return medicines;
      } catch (_) {}
    }
    final mock = mockDataSource ?? PharmacyMockDataSource();
    return mock.getPopularMedicines();
  }

  @override
  Future<PrescriptionOrder> getRecentPrescription() async {
    final remote = remoteDataSource;
    if (!AppConfig.useMockApi && remote != null) {
      try {
        return await remote.getRecentPrescription();
      } catch (_) {}
    }
    final mock = mockDataSource ?? PharmacyMockDataSource();
    return mock.getRecentPrescription();
  }
}
