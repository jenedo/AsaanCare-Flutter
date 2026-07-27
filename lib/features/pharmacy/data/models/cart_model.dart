import 'cart_item_model.dart';

class CartModel {
  final String id;
  final String patientId;
  final String currency;
  final int subtotalMinor;
  final int deliveryFeeMinor;
  final int totalMinor;
  final List<CartItemModel> items;

  const CartModel({
    required this.id,
    required this.patientId,
    this.currency = 'PKR',
    required this.subtotalMinor,
    required this.deliveryFeeMinor,
    required this.totalMinor,
    required this.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems
        .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return CartModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String? ?? '',
      currency: json['currency'] as String? ?? 'PKR',
      subtotalMinor: (json['subtotalMinor'] as num?)?.toInt() ?? 0,
      deliveryFeeMinor: (json['deliveryFeeMinor'] as num?)?.toInt() ?? 0,
      totalMinor: (json['totalMinor'] as num?)?.toInt() ?? 0,
      items: itemsList,
    );
  }
}
