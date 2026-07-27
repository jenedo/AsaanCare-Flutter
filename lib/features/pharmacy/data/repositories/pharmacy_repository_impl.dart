import '../../../../core/config/app_config.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/entities/prescription_order.dart';
import '../../domain/repositories/pharmacy_repository.dart';
import '../datasources/pharmacy_mock_data_source.dart';
import '../datasources/pharmacy_remote_data_source.dart';
import '../models/pharmacy_product_model.dart';

class PharmacyRepositoryImpl implements PharmacyRepository {
  const PharmacyRepositoryImpl({this.mockDataSource, this.remoteDataSource});

  final PharmacyMockDataSource? mockDataSource;
  final PharmacyRemoteDataSource? remoteDataSource;

  @override
  Future<List<Medicine>> getPopularMedicines() async {
    final remote = remoteDataSource;
    if (AppConfig.useMockApi || remote == null) {
      final mock = mockDataSource ?? PharmacyMockDataSource();
      return mock.getPopularMedicines();
    }

    try {
      final result = await remote.getProducts(limit: 10);
      final products = result['data'] as List<dynamic>? ?? [];
      if (products.isEmpty) {
        final mock = mockDataSource ?? PharmacyMockDataSource();
        return mock.getPopularMedicines();
      }
      return products.map((p) {
        final model = p as PharmacyProductModel;
        return Medicine(
          id: model.id,
          brandName: model.brandName,
          genericName: model.genericName,
          manufacturer: model.manufacturer ?? 'Pharma',
          category: MedicineCategory.painRelief,
          strength: model.strength ?? 'N/A',
          dosageForm: model.dosageForm,
          packSize: '${model.packSize} Units',
          price: model.unitPriceMinor,
          originalPrice: model.unitPriceMinor,
          stockQuantity: model.availableStock,
          prescriptionRequired: model.prescriptionRequired,
          rating: 4.8,
          reviewCount: 12,
          description: model.description ?? 'Pharmacy medicine item',
          productCode: model.sku,
          imageUrl: model.imageUrl,
        );
      }).toList();
    } catch (_) {
      final mock = mockDataSource ?? PharmacyMockDataSource();
      return mock.getPopularMedicines();
    }
  }

  @override
  Future<PrescriptionOrder> getRecentPrescription() {
    final mock = mockDataSource ?? PharmacyMockDataSource();
    return mock.getRecentPrescription();
  }
}
