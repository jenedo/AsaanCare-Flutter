class PharmacyOrderItemModel {
  final String id;
  final String productNameSnap;
  final String skuSnap;
  final int unitPriceSnap;
  final int quantity;
  final int lineTotalMinor;

  const PharmacyOrderItemModel({
    required this.id,
    required this.productNameSnap,
    required this.skuSnap,
    required this.unitPriceSnap,
    required this.quantity,
    required this.lineTotalMinor,
  });

  factory PharmacyOrderItemModel.fromJson(Map<String, dynamic> json) {
    return PharmacyOrderItemModel(
      id: json['id'] as String,
      productNameSnap: json['productNameSnap'] as String? ?? '',
      skuSnap: json['skuSnap'] as String? ?? '',
      unitPriceSnap: (json['unitPriceSnap'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      lineTotalMinor: (json['lineTotalMinor'] as num?)?.toInt() ?? 0,
    );
  }
}
