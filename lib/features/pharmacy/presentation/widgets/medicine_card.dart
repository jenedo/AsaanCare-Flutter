import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/medicine.dart';
import 'medicine_visual.dart';

class MedicineCard extends StatelessWidget {
  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onAddTap,
    required this.onTap,
    required this.onFavoriteTap,
    required this.isFavorite,
    this.width = 176,
  });

  final Medicine medicine;
  final VoidCallback onAddTap;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final bool isFavorite;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    MedicineVisual(medicine: medicine),
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.94),
                        shape: const CircleBorder(),
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: isFavorite
                              ? 'Remove from favorites'
                              : 'Add to favorites',
                          onPressed: onFavoriteTap,
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 18,
                            color: isFavorite
                                ? AppTheme.danger
                                : const Color(0xFF657386),
                          ),
                        ),
                      ),
                    ),
                    if (medicine.isOnSale)
                      Positioned(
                        left: 5,
                        top: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F1),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '${medicine.discountPercent}% OFF',
                            style: const TextStyle(
                              color: AppTheme.danger,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  medicine.brandName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF07132D),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  medicine.genericName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF657386),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB020),
                      size: 15,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      medicine.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Color(0xFF536078),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (medicine.prescriptionRequired)
                      const Icon(
                        Icons.receipt_long_outlined,
                        color: AppTheme.primary,
                        size: 15,
                      ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        'Rs. ${medicine.price}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF07132D),
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (medicine.isOnSale)
                      Text(
                        'Rs. ${medicine.originalPrice}',
                        style: const TextStyle(
                          color: Color(0xFF8A95A6),
                          fontSize: 10,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 9),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: medicine.isInStock ? onAddTap : null,
                    icon: Icon(
                      medicine.isInStock
                          ? Icons.add_shopping_cart_rounded
                          : Icons.remove_shopping_cart_outlined,
                      size: 17,
                    ),
                    label: Text(
                      medicine.isInStock ? 'Add to Cart' : 'Out of Stock',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: Color(0xFF9ADBD4)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
