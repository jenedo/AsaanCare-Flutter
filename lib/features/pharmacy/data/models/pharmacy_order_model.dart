import 'pharmacy_order_item_model.dart';

class PharmacyOrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final int subtotalMinor;
  final int deliveryFeeMinor;
  final int totalMinor;
  final String currency;
  final DateTime createdAt;
  final List<PharmacyOrderItemModel> items;

  const PharmacyOrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.subtotalMinor,
    required this.deliveryFeeMinor,
    required this.totalMinor,
    this.currency = 'PKR',
    required this.createdAt,
    required this.items,
  });

  factory PharmacyOrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems
        .map(
          (item) =>
              PharmacyOrderItemModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return PharmacyOrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING_PAYMENT',
      subtotalMinor: (json['subtotalMinor'] as num?)?.toInt() ?? 0,
      deliveryFeeMinor: (json['deliveryFeeMinor'] as num?)?.toInt() ?? 0,
      totalMinor: (json['totalMinor'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'PKR',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      items: itemsList,
    );
  }
}
