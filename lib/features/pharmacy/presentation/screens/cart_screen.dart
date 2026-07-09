import 'package:flutter/material.dart';

import '../../../../core/layout/app_layout.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/pharmacy_controller.dart';
import '../widgets/medicine_visual.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.controller});

  final PharmacyController controller;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _checkout() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CheckoutScreen(controller: widget.controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.controller.cartItems;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text('Your Cart (${widget.controller.cartCount})'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: widget.controller.clearCart,
              child: const Text('Clear'),
            ),
        ],
      ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton(
                onPressed: _checkout,
                child: Text(
                  'Proceed to Checkout • Rs. ${widget.controller.payableTotal}',
                ),
              ),
            ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxMobileContentWidth,
            ),
            child: items.isEmpty
                ? const _EmptyCart()
                : ListView(
                    padding: EdgeInsets.fromLTRB(
                      AppLayout.horizontalPadding(context),
                      10,
                      AppLayout.horizontalPadding(context),
                      110,
                    ),
                    children: [
                      for (final item in items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final compact = constraints.maxWidth < 330;

                              return Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.border),
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                child: compact
                                    ? Column(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 82,
                                                child: MedicineVisual(
                                                  medicine: item.medicine,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _CartItemInfo(
                                                  name: item.medicine.brandName,
                                                  subtitle:
                                                      item.medicine.subtitle,
                                                  lineTotal: item.lineTotal,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          _QuantityControls(
                                            quantity: item.quantity,
                                            onRemove: () {
                                              widget.controller.removeFromCart(
                                                item.medicine.id,
                                              );
                                            },
                                            onDecrease: () {
                                              widget.controller.setQuantity(
                                                item.medicine.id,
                                                item.quantity - 1,
                                              );
                                            },
                                            onIncrease: () {
                                              widget.controller.setQuantity(
                                                item.medicine.id,
                                                item.quantity + 1,
                                              );
                                            },
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          SizedBox(
                                            width: 82,
                                            child: MedicineVisual(
                                              medicine: item.medicine,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _CartItemInfo(
                                              name: item.medicine.brandName,
                                              subtitle: item.medicine.subtitle,
                                              lineTotal: item.lineTotal,
                                            ),
                                          ),
                                          _QuantityControls(
                                            quantity: item.quantity,
                                            onRemove: () {
                                              widget.controller.removeFromCart(
                                                item.medicine.id,
                                              );
                                            },
                                            onDecrease: () {
                                              widget.controller.setQuantity(
                                                item.medicine.id,
                                                item.quantity - 1,
                                              );
                                            },
                                            onIncrease: () {
                                              widget.controller.setQuantity(
                                                item.medicine.id,
                                                item.quantity + 1,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 10),
                      _PriceSummary(controller: widget.controller),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _CartItemInfo extends StatelessWidget {
  const _CartItemInfo({
    required this.name,
    required this.subtitle,
    required this.lineTotal,
  });

  final String name;
  final String subtitle;
  final int lineTotal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF07132D),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF657386), fontSize: 11.5),
        ),
        const SizedBox(height: 8),
        Text(
          'Rs. $lineTotal',
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _QuantityControls extends StatelessWidget {
  const _QuantityControls({
    required this.quantity,
    required this.onRemove,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback onRemove;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: onRemove,
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppTheme.danger,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onDecrease,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              '$quantity',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onIncrease,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceSummary extends StatelessWidget {
  const _PriceSummary({required this.controller});

  final PharmacyController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFA),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          _PriceRow(label: 'Subtotal', value: controller.subtotal),
          _PriceRow(label: 'Delivery', value: controller.deliveryFee),
          _PriceRow(
            label: 'Coupon discount',
            value: -controller.discount,
            valueColor: AppTheme.primary,
          ),
          const Divider(height: 24),
          _PriceRow(
            label: 'Total Amount',
            value: controller.payableTotal,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final int value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final valueText = value < 0 ? '-Rs. ${value.abs()}' : 'Rs. $value';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFF536078),
                fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            valueText,
            style: TextStyle(
              color: valueColor ?? const Color(0xFF07132D),
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined, color: AppTheme.primary, size: 62),
          SizedBox(height: 14),
          Text(
            'Your cart is empty',
            style: TextStyle(
              color: Color(0xFF07132D),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
