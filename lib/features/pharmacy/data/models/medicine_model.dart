import '../../domain/entities/medicine.dart';

class MedicineModel extends Medicine {
  const MedicineModel({
    required super.id,
    required super.brandName,
    required super.genericName,
    required super.manufacturer,
    required super.category,
    required super.strength,
    required super.dosageForm,
    required super.packSize,
    required super.price,
    required super.originalPrice,
    required super.stockQuantity,
    required super.prescriptionRequired,
    required super.rating,
    required super.reviewCount,
    required super.description,
    required super.productCode,
    super.imageUrl,
    super.imageAsset,
  });
}
