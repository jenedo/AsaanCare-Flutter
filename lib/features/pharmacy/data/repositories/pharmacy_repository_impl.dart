import '../../domain/entities/medicine.dart';
import '../../domain/entities/prescription_order.dart';
import '../../domain/repositories/pharmacy_repository.dart';
import '../datasources/pharmacy_mock_data_source.dart';

class PharmacyRepositoryImpl implements PharmacyRepository {
  const PharmacyRepositoryImpl({required this.mockDataSource});

  final PharmacyMockDataSource mockDataSource;

  @override
  Future<List<Medicine>> getPopularMedicines() {
    return mockDataSource.getPopularMedicines();
  }

  @override
  Future<PrescriptionOrder> getRecentPrescription() {
    return mockDataSource.getRecentPrescription();
  }
}
