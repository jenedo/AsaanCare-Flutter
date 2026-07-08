import 'package:flutter/material.dart';

import '../../../../core/layout/app_layout.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/medicine.dart';
import '../controllers/pharmacy_controller.dart';
import '../widgets/medicine_visual.dart';
import 'cart_screen.dart';

class MedicineDetailScreen extends StatefulWidget {
  const MedicineDetailScreen({
    super.key,
    required this.controller,
    required this.medicine,
  });

  final PharmacyController controller;
  final Medicine medicine;

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  int _quantity = 1;

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

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CartScreen(controller: widget.controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medicine = widget.medicine;
    final favorite = widget.controller.isFavorite(medicine.id);
    final similar = widget.controller.similarMedicines(medicine);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: favorite ? 'Remove favorite' : 'Favorite',
            onPressed: () {
              widget.controller.toggleFavorite(medicine.id);
            },
            icon: Icon(
              favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: favorite ? AppTheme.danger : null,
            ),
          ),
          IconButton(
            tooltip: 'Cart',
            onPressed: _openCart,
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final quantitySelector = Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            );

            final addButton = FilledButton.icon(
              onPressed: medicine.isInStock
                  ? () {
                      widget.controller.addToCart(
                        medicine,
                        quantity: _quantity,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '$_quantity × ${medicine.brandName} added.',
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.shopping_cart_rounded),
              label: Text(
                medicine.isInStock ? 'Add to Cart' : 'Out of Stock',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );

            if (constraints.maxWidth < 340) {
              final compactQuantitySelector = Container(
                height: 44,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints.tightFor(
                        width: 36,
                        height: 36,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      icon: const Icon(Icons.remove_rounded, size: 19),
                    ),
                    SizedBox(
                      width: 22,
                      child: Text(
                        '$_quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints.tightFor(
                        width: 36,
                        height: 36,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => setState(() => _quantity++),
                      icon: const Icon(Icons.add_rounded, size: 19),
                    ),
                  ],
                ),
              );

              return Row(
                children: [
                  compactQuantitySelector,
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: medicine.isInStock
                            ? () {
                                widget.controller.addToCart(
                                  medicine,
                                  quantity: _quantity,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '$_quantity × ${medicine.brandName} added.',
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Text(
                          medicine.isInStock ? 'Add to Cart' : 'Out of Stock',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                quantitySelector,
                const SizedBox(width: 10),
                Expanded(child: addButton),
              ],
            );
          },
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxMobileContentWidth,
            ),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppLayout.horizontalPadding(context),
                10,
                AppLayout.horizontalPadding(context),
                110,
              ),
              children: [
                MedicineVisual(medicine: medicine, large: true),
                const SizedBox(height: 20),
                Text(
                  medicine.brandName,
                  style: const TextStyle(
                    color: Color(0xFF07132D),
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  medicine.manufacturer,
                  style: const TextStyle(color: Color(0xFF657386)),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB020),
                        ),
                        Text(
                          ' ${medicine.rating.toStringAsFixed(1)} '
                          '(${medicine.reviewCount} reviews)',
                          style: const TextStyle(
                            color: Color(0xFF536078),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    _StockChip(inStock: medicine.isInStock),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    Text(
                      'Rs. ${medicine.price}',
                      style: const TextStyle(
                        color: Color(0xFF07132D),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (medicine.isOnSale)
                      Text(
                        'Rs. ${medicine.originalPrice}',
                        style: const TextStyle(
                          color: Color(0xFF8A95A6),
                          fontSize: 15,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    if (medicine.isOnSale)
                      Text(
                        '${medicine.discountPercent}% OFF',
                        style: const TextStyle(
                          color: AppTheme.danger,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.medication_outlined,
                        title: medicine.genericName,
                        subtitle: medicine.strength,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.inventory_2_outlined,
                        title: medicine.dosageForm,
                        subtitle: medicine.packSize,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionTitle('About this medicine'),
                const SizedBox(height: 10),
                Text(
                  medicine.description,
                  style: const TextStyle(
                    color: Color(0xFF536078),
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: medicine.prescriptionRequired
                        ? const Color(0xFFFFF6E6)
                        : const Color(0xFFF0F8F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        medicine.prescriptionRequired
                            ? Icons.receipt_long_outlined
                            : Icons.info_outline_rounded,
                        color: medicine.prescriptionRequired
                            ? const Color(0xFFB76A00)
                            : AppTheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          medicine.prescriptionRequired
                              ? 'Prescription required. The pharmacy must verify a valid prescription before fulfilment.'
                              : 'Catalog information is not medical advice. Follow the label and consult a pharmacist or clinician when needed.',
                          style: const TextStyle(
                            color: Color(0xFF33415C),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (similar.isNotEmpty) ...[
                  const SizedBox(height: 26),
                  const _SectionTitle('Similar medicines'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 122,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: similar.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final item = similar[index];

                        return SizedBox(
                          width: 156,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                  builder: (context) => MedicineDetailScreen(
                                    controller: widget.controller,
                                    medicine: item,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.border),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.brandName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF07132D),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Rs. ${item.price}',
                                    style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StockChip extends StatelessWidget {
  const _StockChip({required this.inStock});

  final bool inStock;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: inStock ? const Color(0xFFEAF7F5) : const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        inStock ? 'In Stock' : 'Out of Stock',
        style: TextStyle(
          color: inStock ? AppTheme.primary : AppTheme.danger,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF07132D),
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF657386), fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF07132D),
        fontSize: 19,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
