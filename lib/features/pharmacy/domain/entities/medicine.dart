enum MedicineCategory {
  painRelief,
  coldAndFlu,
  diabetesCare,
  heartCare,
  vitamins,
  babyCare,
  skinCare,
  personalCare,
  firstAid,
  digestiveCare,
}

extension MedicineCategoryX on MedicineCategory {
  String get label {
    return switch (this) {
      MedicineCategory.painRelief => 'Pain Relief',
      MedicineCategory.coldAndFlu => 'Cold & Flu',
      MedicineCategory.diabetesCare => 'Diabetes',
      MedicineCategory.heartCare => 'Heart Care',
      MedicineCategory.vitamins => 'Vitamins',
      MedicineCategory.babyCare => 'Baby Care',
      MedicineCategory.skinCare => 'Skin Care',
      MedicineCategory.personalCare => 'Personal Care',
      MedicineCategory.firstAid => 'First Aid',
      MedicineCategory.digestiveCare => 'Digestive Care',
    };
  }
}

class Medicine {
  const Medicine({
    required this.id,
    required this.brandName,
    required this.genericName,
    required this.manufacturer,
    required this.category,
    required this.strength,
    required this.dosageForm,
    required this.packSize,
    required this.price,
    required this.originalPrice,
    required this.stockQuantity,
    required this.prescriptionRequired,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.productCode,
    this.imageUrl,
    this.imageAsset,
  });

  final String id;
  final String brandName;
  final String genericName;
  final String manufacturer;
  final MedicineCategory category;
  final String strength;
  final String dosageForm;
  final String packSize;
  final int price;
  final int originalPrice;
  final int stockQuantity;
  final bool prescriptionRequired;
  final double rating;
  final int reviewCount;
  final String description;
  final String productCode;
  final String? imageUrl;
  final String? imageAsset;

  String get name => brandName;
  bool get isInStock => stockQuantity > 0;
  bool get isOnSale => originalPrice > price;

  int get discountPercent {
    if (!isOnSale || originalPrice <= 0) return 0;
    return (((originalPrice - price) / originalPrice) * 100).round();
  }

  String get subtitle => '$strength â€¢ $dosageForm';

  String get searchableText {
    return [
      brandName,
      genericName,
      manufacturer,
      category.label,
      strength,
      dosageForm,
      packSize,
      productCode,
    ].join(' ').toLowerCase();
  }
}
