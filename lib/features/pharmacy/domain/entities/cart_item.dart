import 'medicine.dart';

class CartItem {
  const CartItem({required this.medicine, required this.quantity});

  final Medicine medicine;
  final int quantity;

  int get lineTotal => medicine.price * quantity;
}
