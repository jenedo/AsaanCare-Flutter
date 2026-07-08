import 'dart:collection';

import '../../domain/entities/medicine.dart';
import '../../domain/entities/prescription_order.dart';
import '../models/medicine_model.dart';

abstract class PharmacyDataSource {
  Future<List<MedicineModel>> getPopularMedicines();
  Future<PrescriptionOrder> getRecentPrescription();
}

class PharmacyMockDataSource implements PharmacyDataSource {
  PharmacyMockDataSource({this.delay = const Duration(milliseconds: 300)});

  final Duration delay;

  static const List<_Seed> _seeds = [
    _Seed(
      'Panadol',
      'Paracetamol',
      'GSK',
      MedicineCategory.painRelief,
      '500mg',
      'Tablet',
      120,
      false,
    ),
    _Seed(
      'Brufen',
      'Ibuprofen',
      'Abbott',
      MedicineCategory.painRelief,
      '400mg',
      'Tablet',
      170,
      false,
    ),
    _Seed(
      'Calpol',
      'Paracetamol',
      'GSK',
      MedicineCategory.babyCare,
      '120mg/5ml',
      'Suspension',
      210,
      false,
    ),
    _Seed(
      'Voltral',
      'Diclofenac',
      'Novartis',
      MedicineCategory.painRelief,
      '50mg',
      'Tablet',
      260,
      true,
    ),
    _Seed(
      'Disprin',
      'Aspirin',
      'Reckitt',
      MedicineCategory.painRelief,
      '300mg',
      'Tablet',
      95,
      false,
    ),
    _Seed(
      'Arinac',
      'Ibuprofen + Pseudoephedrine',
      'P&G',
      MedicineCategory.coldAndFlu,
      '200mg/30mg',
      'Tablet',
      250,
      false,
    ),
    _Seed(
      'Telfast',
      'Fexofenadine',
      'Sanofi',
      MedicineCategory.coldAndFlu,
      '120mg',
      'Tablet',
      430,
      false,
    ),
    _Seed(
      'Strepsils',
      'Throat Formula',
      'Reckitt',
      MedicineCategory.coldAndFlu,
      'Standard',
      'Lozenge',
      280,
      false,
    ),
    _Seed(
      'Hydryllin',
      'Cough Formula',
      'Searle',
      MedicineCategory.coldAndFlu,
      '120ml',
      'Syrup',
      240,
      false,
    ),
    _Seed(
      'Glucophage',
      'Metformin',
      'Merck',
      MedicineCategory.diabetesCare,
      '500mg',
      'Tablet',
      390,
      true,
    ),
    _Seed(
      'Diamicron',
      'Gliclazide',
      'Servier',
      MedicineCategory.diabetesCare,
      '60mg MR',
      'Tablet',
      620,
      true,
    ),
    _Seed(
      'Januvia',
      'Sitagliptin',
      'MSD',
      MedicineCategory.diabetesCare,
      '100mg',
      'Tablet',
      980,
      true,
    ),
    _Seed(
      'Concor',
      'Bisoprolol',
      'Merck',
      MedicineCategory.heartCare,
      '5mg',
      'Tablet',
      460,
      true,
    ),
    _Seed(
      'Norvasc',
      'Amlodipine',
      'Pfizer',
      MedicineCategory.heartCare,
      '5mg',
      'Tablet',
      510,
      true,
    ),
    _Seed(
      'Lipitor',
      'Atorvastatin',
      'Pfizer',
      MedicineCategory.heartCare,
      '20mg',
      'Tablet',
      750,
      true,
    ),
    _Seed(
      'Centrum',
      'Multivitamins + Minerals',
      'Haleon',
      MedicineCategory.vitamins,
      'Daily Formula',
      'Tablet',
      1450,
      false,
    ),
    _Seed(
      'Vitamin D3',
      'Cholecalciferol',
      'Nutrifactor',
      MedicineCategory.vitamins,
      '2000 IU',
      'Capsule',
      350,
      false,
    ),
    _Seed(
      'Calcium + D3',
      'Calcium + Cholecalciferol',
      'Nutrifactor',
      MedicineCategory.vitamins,
      '600mg/400 IU',
      'Tablet',
      430,
      false,
    ),
    _Seed(
      'Baby Lotion',
      'Moisturising Lotion',
      'Johnson & Johnson',
      MedicineCategory.babyCare,
      '200ml',
      'Lotion',
      540,
      false,
    ),
    _Seed(
      'Baby Rash Cream',
      'Zinc Oxide',
      'Sebamed',
      MedicineCategory.babyCare,
      '100ml',
      'Cream',
      780,
      false,
    ),
    _Seed(
      'Fucidin',
      'Fusidic Acid',
      'LEO Pharma',
      MedicineCategory.skinCare,
      '2%',
      'Cream',
      590,
      true,
    ),
    _Seed(
      'Hydrozole',
      'Hydrocortisone + Clotrimazole',
      'Pacific',
      MedicineCategory.skinCare,
      '1%/1%',
      'Cream',
      410,
      true,
    ),
    _Seed(
      'Dettol Handwash',
      'Antiseptic Handwash',
      'Reckitt',
      MedicineCategory.personalCare,
      '250ml',
      'Liquid',
      320,
      false,
    ),
    _Seed(
      'First Aid Kit',
      'Basic Dressing Supplies',
      'AsaanCare',
      MedicineCategory.firstAid,
      'Standard',
      'Kit',
      1250,
      false,
    ),
    _Seed(
      'Gaviscon',
      'Sodium Alginate Formula',
      'Reckitt',
      MedicineCategory.digestiveCare,
      '150ml',
      'Suspension',
      520,
      false,
    ),
  ];

  static const List<_Variant> _variants = [
    _Variant('Standard Pack', 1.0),
    _Variant('Value Pack', 1.65),
    _Variant('Family Pack', 2.35),
    _Variant('Monthly Pack', 3.05),
  ];

  @override
  Future<List<MedicineModel>> getPopularMedicines() async {
    await Future<void>.delayed(delay);
    final output = <MedicineModel>[];

    for (var seedIndex = 0; seedIndex < _seeds.length; seedIndex++) {
      final seed = _seeds[seedIndex];

      for (
        var variantIndex = 0;
        variantIndex < _variants.length;
        variantIndex++
      ) {
        final variant = _variants[variantIndex];
        final price = (seed.basePrice * variant.multiplier).round();
        final onSale = (seedIndex + variantIndex) % 3 == 0;
        final originalPrice = onSale ? (price * 1.18).round() : price;
        final stock = (seedIndex + variantIndex) % 13 == 0
            ? 0
            : 8 + ((seedIndex * 7 + variantIndex * 5) % 70);
        final suffix = variantIndex == 0 ? '' : ' ${variant.label}';

        output.add(
          MedicineModel(
            id: '${_slug(seed.brand)}-${variantIndex + 1}',
            brandName: '${seed.brand}$suffix',
            genericName: seed.generic,
            manufacturer: seed.manufacturer,
            category: seed.category,
            strength: seed.strength,
            dosageForm: seed.dosageForm,
            packSize: variant.label,
            price: price,
            originalPrice: originalPrice,
            stockQuantity: stock,
            prescriptionRequired: seed.prescriptionRequired,
            rating: 4.2 + (((seedIndex + variantIndex) % 7) * 0.1),
            reviewCount: 90 + (seedIndex * 83) + (variantIndex * 27),
            description:
                'Catalog information only. Follow the package label and pharmacist or clinician guidance.',
            productCode:
                'AC-${(seedIndex + 1).toString().padLeft(3, '0')}-${variantIndex + 1}',
          ),
        );
      }
    }

    if (output.length != 100) {
      throw StateError('Expected 100 medicine SKUs, got ${output.length}.');
    }

    return UnmodifiableListView<MedicineModel>(output);
  }

  @override
  Future<PrescriptionOrder> getRecentPrescription() async {
    await Future<void>.delayed(delay);
    return const PrescriptionOrder(
      id: 'pr_12345',
      title: 'Prescription #PR12345',
      uploadedDate: 'Uploaded on 10 May 2024',
      isVerified: true,
      imageAsset: 'assets/images/prescription_paper.png',
      medicineIds: ['panadol-1', 'brufen-1', 'calpol-1'],
    );
  }

  static String _slug(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}

class _Seed {
  const _Seed(
    this.brand,
    this.generic,
    this.manufacturer,
    this.category,
    this.strength,
    this.dosageForm,
    this.basePrice,
    this.prescriptionRequired,
  );

  final String brand;
  final String generic;
  final String manufacturer;
  final MedicineCategory category;
  final String strength;
  final String dosageForm;
  final int basePrice;
  final bool prescriptionRequired;
}

class _Variant {
  const _Variant(this.label, this.multiplier);

  final String label;
  final double multiplier;
}
