class PharmacyProductModel {
  final String id;
  final String categoryId;
  final String sku;
  final String genericName;
  final String brandName;
  final String? strength;
  final String dosageForm;
  final String? manufacturer;
  final int packSize;
  final bool prescriptionRequired;
  final int unitPriceMinor;
  final String currency;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final int availableStock;

  const PharmacyProductModel({
    required this.id,
    required this.categoryId,
    required this.sku,
    required this.genericName,
    required this.brandName,
    this.strength,
    required this.dosageForm,
    this.manufacturer,
    required this.packSize,
    required this.prescriptionRequired,
    required this.unitPriceMinor,
    this.currency = 'PKR',
    this.description,
    this.imageUrl,
    this.isActive = true,
    required this.availableStock,
  });

  factory PharmacyProductModel.fromJson(Map<String, dynamic> json) {
    return PharmacyProductModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      genericName: json['genericName'] as String? ?? '',
      brandName: json['brandName'] as String? ?? '',
      strength: json['strength'] as String?,
      dosageForm: json['dosageForm'] as String? ?? '',
      manufacturer: json['manufacturer'] as String?,
      packSize: (json['packSize'] as num?)?.toInt() ?? 1,
      prescriptionRequired: json['prescriptionRequired'] as bool? ?? false,
      unitPriceMinor: (json['unitPriceMinor'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'PKR',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      availableStock: (json['availableStock'] as num?)?.toInt() ?? 0,
    );
  }
}
