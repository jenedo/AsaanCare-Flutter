import 'package:asaancare/features/pharmacy/data/datasources/pharmacy_mock_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PharmacyMockDataSource', () {
    test(
      'generates 100 unique SKU ids with seed and variant components',
      () async {
        final dataSource = PharmacyMockDataSource(delay: Duration.zero);

        final medicines = await dataSource.getPopularMedicines();
        final ids = medicines.map((medicine) => medicine.id).toList();

        expect(medicines, hasLength(100));
        expect(ids.toSet(), hasLength(100));

        for (final id in ids) {
          expect(
            id,
            matches(RegExp(r'^[a-z0-9-]+-\d+-\d+$')),
            reason: 'SKU id must include seedIndex and variantIndex: $id',
          );
        }
      },
    );

    test('verified prescription references current catalog SKU ids', () async {
      final dataSource = PharmacyMockDataSource(delay: Duration.zero);

      final medicines = await dataSource.getPopularMedicines();
      final prescription = await dataSource.getRecentPrescription();
      final medicineIds = medicines.map((medicine) => medicine.id).toSet();

      expect(prescription.isVerified, isTrue);
      expect(prescription.medicineIds, isNotEmpty);
      expect(prescription.medicineIds.every(medicineIds.contains), isTrue);
    });
  });
}
