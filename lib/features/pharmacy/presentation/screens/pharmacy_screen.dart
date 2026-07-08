import 'package:flutter/material.dart';

import '../../../../core/layout/app_layout.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../domain/entities/medicine.dart';
import '../controllers/pharmacy_controller.dart';
import '../widgets/medicine_card.dart';
import 'cart_screen.dart';
import 'medicine_detail_screen.dart';
import 'medicine_search_screen.dart';
import 'order_tracking_screen.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key, required this.controller});

  final PharmacyController controller;

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    widget.controller.load();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }

  void _openSearch({MedicineCategory? category}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => MedicineSearchScreen(
          controller: widget.controller,
          initialCategory: category,
        ),
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

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CartScreen(controller: widget.controller),
      ),
    );
  }

  void _openTracking() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            OrderTrackingScreen(controller: widget.controller),
      ),
    );
  }

  void _handleNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(AppRoutes.patientHome);
        return;
      case 1:
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.doctorDetail, arguments: 'doctor_ali');
        return;
      case 2:
        return;
      case 3:
        Navigator.of(context).pushNamed(AppRoutes.medicalRecords);
        return;
      case 4:
        _showMessage('Profile and wallet modules are scheduled next.');
        return;
    }
  }

  Future<void> _selectCity() async {
    const cities = [
      'Lahore',
      'Karachi',
      'Islamabad',
      'Rawalpindi',
      'Multan',
      'Faisalabad',
      'Hyderabad',
      'Peshawar',
    ];

    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
            children: [
              const Text(
                'Select delivery city',
                style: TextStyle(
                  color: Color(0xFF07132D),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              for (final city in cities)
                ListTile(
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: AppTheme.primary,
                  ),
                  title: Text(city),
                  trailing: city == widget.controller.selectedCity
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(city),
                ),
            ],
          ),
        );
      },
    );

    if (selected == null || !mounted) return;
    widget.controller.selectCity(selected);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final popular = controller.medicines.take(8).toList(growable: false);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        onTap: _handleNavTap,
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxMobileContentWidth,
            ),
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: controller.isLoading && controller.medicines.isEmpty
                  ? const _LoadingView()
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        AppLayout.horizontalPadding(context),
                        14,
                        AppLayout.horizontalPadding(context),
                        26,
                      ),
                      children: [
                        _Header(
                          city: controller.selectedCity,
                          cartCount: controller.cartCount,
                          hasActiveOrder: controller.activeOrder != null,
                          onCityTap: _selectCity,
                          onCartTap: _openCart,
                          onOrderTap: _openTracking,
                        ),
                        const SizedBox(height: 18),
                        _SearchBox(onTap: _openSearch),
                        if (controller.hasError) ...[
                          const SizedBox(height: 12),
                          _ErrorBanner(
                            message:
                                controller.errorMessage ??
                                'Failed to load pharmacy.',
                            onRetry: controller.refresh,
                          ),
                        ],
                        const SizedBox(height: 18),
                        _HeroBanner(onOrderTap: _openSearch),
                        const SizedBox(height: 18),
                        _QuickActions(
                          onUploadPrescription: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.medicalRecords);
                          },
                          onQuickOrder: _openSearch,
                          onReminder: () {
                            _showMessage(
                              'Medicine reminders will connect to notifications.',
                            );
                          },
                          onOffers: _openSearch,
                        ),
                        const SizedBox(height: 24),
                        _SectionHeader(
                          title: 'Shop by Category',
                          onViewAll: _openSearch,
                        ),
                        const SizedBox(height: 12),
                        _CategoryStrip(
                          onTap: (category) {
                            _openSearch(category: category);
                          },
                        ),
                        const SizedBox(height: 22),
                        _OfferBanner(onTap: _openSearch),
                        const SizedBox(height: 24),
                        _SectionHeader(
                          title: 'Top Picks for You',
                          onViewAll: _openSearch,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 314,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: popular.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final medicine = popular[index];

                              return MedicineCard(
                                medicine: medicine,
                                isFavorite: controller.isFavorite(medicine.id),
                                onFavoriteTap: () {
                                  controller.toggleFavorite(medicine.id);
                                },
                                onTap: () => _openMedicine(medicine),
                                onAddTap: () {
                                  controller.addToCart(medicine);
                                  _showMessage(
                                    '${medicine.brandName} added to cart.',
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _TrustStrip(),
                        const SizedBox(height: 24),
                        const _SectionHeader(title: 'Nearby Pharmacies'),
                        const SizedBox(height: 12),
                        _NearbyPharmacyCard(
                          pharmacyName: controller.selectedPharmacy,
                          onOrderTap: _openSearch,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.city,
    required this.cartCount,
    required this.hasActiveOrder,
    required this.onCityTap,
    required this.onCartTap,
    required this.onOrderTap,
  });

  final String city;
  final int cartCount;
  final bool hasActiveOrder;
  final VoidCallback onCityTap;
  final VoidCallback onCartTap;
  final VoidCallback onOrderTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 350;

        return Row(
          children: [
            Expanded(child: _BrandMark(compact: compact)),
            if (compact)
              IconButton(
                tooltip: city,
                onPressed: onCityTap,
                icon: const Icon(
                  Icons.location_on_outlined,
                  color: AppTheme.primary,
                ),
              )
            else
              ActionChip(
                avatar: const Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: AppTheme.primary,
                ),
                label: Text(city),
                onPressed: onCityTap,
              ),
            if (hasActiveOrder)
              IconButton(
                tooltip: 'Track order',
                onPressed: onOrderTap,
                icon: const Icon(Icons.local_shipping_outlined),
              ),
            _CartButton(count: cartCount, onTap: onCartTap),
          ],
        );
      },
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.primary,
          child: Icon(Icons.health_and_safety_rounded, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AsaanCare',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (!compact)
                const Text(
                  'Health for Everyone',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFF657386), fontSize: 10),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Cart',
          onPressed: onTap,
          icon: const Icon(Icons.shopping_cart_outlined),
        ),
        if (count > 0)
          Positioned(
            right: 2,
            top: 1,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: Color(0xFF657386)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search medicines, health products...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFF657386)),
                ),
              ),
              Icon(Icons.document_scanner_outlined),
              SizedBox(width: 12),
              Icon(Icons.mic_none_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onOrderTap});

  final VoidCallback onOrderTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 202,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF006E73), Color(0xFF0A958B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -8,
            bottom: -2,
            child: Icon(
              Icons.shopping_basket_rounded,
              color: Color(0x55FFFFFF),
              size: 150,
            ),
          ),
          const Positioned(
            right: 48,
            top: 12,
            child: Icon(
              Icons.medication_rounded,
              color: Color(0xAAFFFFFF),
              size: 38,
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Health,\nOur Priority',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Order medicines from verified\npharmacy partners.',
                style: TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: FilledButton.icon(
              onPressed: onOrderTap,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primary,
              ),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Order Now'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onUploadPrescription,
    required this.onQuickOrder,
    required this.onReminder,
    required this.onOffers,
  });

  final VoidCallback onUploadPrescription;
  final VoidCallback onQuickOrder;
  final VoidCallback onReminder;
  final VoidCallback onOffers;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.upload_file_rounded, 'Upload\nPrescription', onUploadPrescription),
      (Icons.flash_on_rounded, 'Quick\nOrder', onQuickOrder),
      (Icons.alarm_rounded, 'Medicine\nReminder', onReminder),
      (Icons.local_offer_rounded, 'Offers &\nDeals', onOffers),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 350;

        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: compact ? 2 : 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: compact ? 1.5 : 0.82,
          ),
          itemBuilder: (context, index) {
            final item = items[index];

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: item.$3,
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.softTeal,
                      child: Icon(item.$1, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.$2,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Color(0xFF07132D),
                        fontSize: 11,
                        height: 1.14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.onTap});

  final ValueChanged<MedicineCategory?> onTap;

  @override
  Widget build(BuildContext context) {
    final categories = MedicineCategory.values;

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = index == categories.length
              ? null
              : categories[index];

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onTap(category),
            child: SizedBox(
              width: 76,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 29,
                    backgroundColor: AppTheme.softTeal,
                    child: Icon(
                      category == null
                          ? Icons.grid_view_rounded
                          : _categoryIcon(category),
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category?.label ?? 'More',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF07132D),
                      fontSize: 11.5,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OfferBanner extends StatelessWidget {
  const _OfferBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 150),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE9FAF7), Color(0xFFCFF2EC)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Flat 20% OFF',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'On selected vitamins and supplements',
                  style: TextStyle(color: Color(0xFF07132D), height: 1.35),
                ),
                const SizedBox(height: 12),
                FilledButton(onPressed: onTap, child: const Text('Shop Now')),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.shopping_basket_rounded,
            color: AppTheme.primary,
            size: 78,
          ),
        ],
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.verified_outlined, 'Genuine', '100% Original'),
      (Icons.delivery_dining_outlined, 'Fast Delivery', 'Quick & Safe'),
      (Icons.shield_outlined, 'Secure', 'Protected flow'),
      (Icons.assignment_return_outlined, 'Easy Returns', 'Policy based'),
    ];

    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];

          return Container(
            width: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.softTeal,
                  child: Icon(item.$1, color: AppTheme.primary),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF07132D),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        item.$3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF657386),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NearbyPharmacyCard extends StatelessWidget {
  const _NearbyPharmacyCard({
    required this.pharmacyName,
    required this.onOrderTap,
  });

  final String pharmacyName;
  final VoidCallback onOrderTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppTheme.primary,
                child: Icon(
                  Icons.local_pharmacy_rounded,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pharmacyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF07132D),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Open â€¢ 0.8 km â€¢ Rating 4.7',
                      style: TextStyle(color: Color(0xFF657386)),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Free delivery above Rs. 500',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onOrderTap,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Order from this pharmacy'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onViewAll});

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF07132D),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (onViewAll != null)
          TextButton(onPressed: onViewAll, child: const Text('View all')),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppTheme.danger),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

IconData _categoryIcon(MedicineCategory category) {
  return switch (category) {
    MedicineCategory.painRelief => Icons.medication_rounded,
    MedicineCategory.coldAndFlu => Icons.air_rounded,
    MedicineCategory.diabetesCare => Icons.bloodtype_outlined,
    MedicineCategory.heartCare => Icons.favorite_rounded,
    MedicineCategory.vitamins => Icons.local_drink_outlined,
    MedicineCategory.babyCare => Icons.child_care_rounded,
    MedicineCategory.skinCare => Icons.spa_outlined,
    MedicineCategory.personalCare => Icons.clean_hands_outlined,
    MedicineCategory.firstAid => Icons.medical_services_outlined,
    MedicineCategory.digestiveCare => Icons.health_and_safety_outlined,
  };
}
