import 'package:flutter/material.dart';

import '../../../../core/layout/app_layout.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/medicine.dart';
import '../controllers/pharmacy_controller.dart';
import '../widgets/medicine_visual.dart';
import 'cart_screen.dart';
import 'medicine_detail_screen.dart';

enum _MedicineSort { relevance, priceLow, priceHigh, rating }

class MedicineSearchScreen extends StatefulWidget {
  const MedicineSearchScreen({
    super.key,
    required this.controller,
    this.initialQuery = '',
    this.initialCategory,
  });

  final PharmacyController controller;
  final String initialQuery;
  final MedicineCategory? initialCategory;

  @override
  State<MedicineSearchScreen> createState() => _MedicineSearchScreenState();
}

class _MedicineSearchScreenState extends State<MedicineSearchScreen> {
  late final TextEditingController _searchController;
  MedicineCategory? _selectedCategory;
  _MedicineSort _sort = _MedicineSort.relevance;
  bool _onlyInStock = false;

  List<Medicine> get _results {
    final result = widget.controller.searchMedicines(
      query: _searchController.text,
      category: _selectedCategory,
      onlyInStock: _onlyInStock,
    );

    switch (_sort) {
      case _MedicineSort.relevance:
        return result;
      case _MedicineSort.priceLow:
        return [...result]..sort((a, b) => a.price.compareTo(b.price));
      case _MedicineSort.priceHigh:
        return [...result]..sort((a, b) => b.price.compareTo(a.price));
      case _MedicineSort.rating:
        return [...result]..sort((a, b) => b.rating.compareTo(a.rating));
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _selectedCategory = widget.initialCategory;
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _searchController.dispose();
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

  void _openMedicine(Medicine medicine) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => MedicineDetailScreen(
          controller: widget.controller,
          medicine: medicine,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Pharmacy'),
        actions: [
          _SearchCartButton(
            count: widget.controller.cartCount,
            onTap: _openCart,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxMobileContentWidth,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppLayout.horizontalPadding(context),
                    8,
                    AppLayout.horizontalPadding(context),
                    8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search medicine or generic name',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(
                  height: 64,
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.horizontalPadding(context),
                    ),
                    scrollDirection: Axis.horizontal,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategory == null,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = null);
                        },
                      ),
                      const SizedBox(width: 8),
                      for (final category in MedicineCategory.values) ...[
                        FilterChip(
                          label: Text(category.label),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() => _selectedCategory = category);
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppLayout.horizontalPadding(context),
                    8,
                    AppLayout.horizontalPadding(context),
                    8,
                  ),
                  child: _SearchToolbar(
                    resultCount: results.length,
                    onlyInStock: _onlyInStock,
                    sort: _sort,
                    onStockChanged: (selected) {
                      setState(() => _onlyInStock = selected);
                    },
                    onSortChanged: (value) {
                      setState(() => _sort = value);
                    },
                  ),
                ),
                Expanded(
                  child: results.isEmpty
                      ? const _NoResults()
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            AppLayout.horizontalPadding(context),
                            6,
                            AppLayout.horizontalPadding(context),
                            24,
                          ),
                          itemCount: results.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final medicine = results[index];

                            return _SearchResultCard(
                              medicine: medicine,
                              quantity: widget.controller.quantityFor(
                                medicine.id,
                              ),
                              onTap: () => _openMedicine(medicine),
                              onAdd: () {
                                widget.controller.addToCart(medicine);
                              },
                              onDecrease: () {
                                widget.controller.setQuantity(
                                  medicine.id,
                                  widget.controller.quantityFor(medicine.id) -
                                      1,
                                );
                              },
                            );
                          },
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

class _SearchToolbar extends StatelessWidget {
  const _SearchToolbar({
    required this.resultCount,
    required this.onlyInStock,
    required this.sort,
    required this.onStockChanged,
    required this.onSortChanged,
  });

  final int resultCount;
  final bool onlyInStock;
  final _MedicineSort sort;
  final ValueChanged<bool> onStockChanged;
  final ValueChanged<_MedicineSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final countLabel = Text(
      '$resultCount results found',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xFF07132D),
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );

    final stockFilter = FilterChip(
      label: const Text('In stock'),
      selected: onlyInStock,
      onSelected: onStockChanged,
    );

    final sortButton = PopupMenuButton<_MedicineSort>(
      tooltip: 'Sort',
      initialValue: sort,
      onSelected: onSortChanged,
      itemBuilder: (context) => const [
        PopupMenuItem(value: _MedicineSort.relevance, child: Text('Relevance')),
        PopupMenuItem(
          value: _MedicineSort.priceLow,
          child: Text('Price: low to high'),
        ),
        PopupMenuItem(
          value: _MedicineSort.priceHigh,
          child: Text('Price: high to low'),
        ),
        PopupMenuItem(value: _MedicineSort.rating, child: Text('Rating')),
      ],
      icon: const Icon(Icons.tune_rounded),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 350) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: countLabel),
                  sortButton,
                ],
              ),
              Align(alignment: Alignment.centerLeft, child: stockFilter),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: countLabel),
            stockFilter,
            sortButton,
          ],
        );
      },
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.medicine,
    required this.quantity,
    required this.onTap,
    required this.onAdd,
    required this.onDecrease,
  });

  final Medicine medicine;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: AppTheme.border),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 300;

              if (compact) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 76,
                          child: MedicineVisual(medicine: medicine),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SearchResultInfo(
                            medicine: medicine,
                            compact: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _SearchQuantityAction(
                      medicine: medicine,
                      quantity: quantity,
                      onAdd: onAdd,
                      onDecrease: onDecrease,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 88,
                    child: MedicineVisual(medicine: medicine),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SearchResultInfo(medicine: medicine, compact: false),
                        const SizedBox(height: 8),
                        _SearchQuantityAction(
                          medicine: medicine,
                          quantity: quantity,
                          onAdd: onAdd,
                          onDecrease: onDecrease,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SearchResultInfo extends StatelessWidget {
  const _SearchResultInfo({required this.medicine, required this.compact});

  final Medicine medicine;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (medicine.isOnSale)
          Text(
            '${medicine.discountPercent}% OFF',
            style: const TextStyle(
              color: AppTheme.danger,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        Text(
          medicine.brandName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF07132D),
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          medicine.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF657386), fontSize: 11),
        ),
        const SizedBox(height: 5),
        Text(
          'Rs. ${medicine.price}',
          style: const TextStyle(
            color: Color(0xFF07132D),
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 10,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFB020),
                  size: 15,
                ),
                Text(
                  ' ${medicine.rating.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            Text(
              medicine.isInStock ? 'In Stock' : 'Out of Stock',
              style: TextStyle(
                color: medicine.isInStock ? AppTheme.primary : AppTheme.danger,
                fontSize: compact ? 10 : 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchQuantityAction extends StatelessWidget {
  const _SearchQuantityAction({
    required this.medicine,
    required this.quantity,
    required this.onAdd,
    required this.onDecrease,
  });

  final Medicine medicine;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: medicine.isInStock ? onAdd : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(42),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          icon: const Icon(Icons.add_shopping_cart_rounded, size: 17),
          label: const Text('Add to Cart'),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: onDecrease,
          icon: const Icon(Icons.remove_circle_outline_rounded),
        ),
        Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w900)),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_rounded, color: AppTheme.primary),
        ),
      ],
    );
  }
}

class _SearchCartButton extends StatelessWidget {
  const _SearchCartButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: const Icon(Icons.shopping_cart_outlined),
        ),
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: CircleAvatar(
              radius: 9,
              backgroundColor: AppTheme.primary,
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, color: AppTheme.primary, size: 50),
            SizedBox(height: 12),
            Text(
              'No matching medicines',
              style: TextStyle(
                color: Color(0xFF07132D),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
