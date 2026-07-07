import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/medicine.dart';

class MedicineCard extends StatelessWidget {
  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onAddTap,
    this.width = 132,
  });

  final Medicine medicine;
  final VoidCallback onAddTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    return SizedBox(
      width: width,
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Later: open medicine details screen.
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MedicineTopBar(),

                const SizedBox(height: 14),

                Text(
                  medicine.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaler: textScaler.clamp(
                    minScaleFactor: 1,
                    maxScaleFactor: 1.15,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF07132D),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  medicine.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textScaler: textScaler.clamp(
                    minScaleFactor: 1,
                    maxScaleFactor: 1.1,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF657386),
                    fontSize: 11.5,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatPrice(medicine.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF07132D),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    _AddToCartButton(
                      medicineName: medicine.name,
                      onTap: onAddTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(num price) {
    if (price % 1 == 0) {
      return 'Rs. ${price.toInt()}';
    }

    return 'Rs. ${price.toStringAsFixed(2)}';
  }
}

class _MedicineTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      width: 34,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({required this.medicineName, required this.onTap});

  final String medicineName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add $medicineName to cart',
      child: Tooltip(
        message: 'Add to cart',
        child: Material(
          color: AppTheme.softTeal,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: const SizedBox(
              height: 40,
              width: 40,
              child: Icon(
                Icons.shopping_cart_outlined,
                color: AppTheme.primary,
                size: 19,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
