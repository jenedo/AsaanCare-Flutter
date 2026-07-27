import 'pharmacy_product_model.dart';

class CartItemModel {
  final String id;
  final String? cartId;
  final String productId;
  final PharmacyProductModel product;
  final int quantity;
  final int lineTotalMinor;

  const CartItemModel({
    required this.id,
    this.cartId,
    required this.productId,
    required this.product,
    required this.quantity,
    this.lineTotalMinor = 0,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      cartId: json['cartId'] as String?,
      productId: json['productId'] as String? ?? '',
      product: PharmacyProductModel.fromJson(
        json['product'] as Map<String, dynamic>? ?? {},
      ),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      lineTotalMinor: (json['lineTotalMinor'] as num?)?.toInt() ?? 0,
    );
  }
}
