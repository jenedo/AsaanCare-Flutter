import 'package:flutter/material.dart';

import '../../../../core/layout/app_layout.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/medicine.dart';
import '../controllers/pharmacy_controller.dart';
import '../widgets/medicine_visual.dart';
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
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openSearch({MedicineCategory? category}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicineSearchScreen(
          controller: widget.controller,
          initialCategory: category,
        ),
      ),
    );
  }

  void _openMedicine(Medicine medicine) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicineDetailScreen(
          controller: widget.controller,
          medicine: medicine,
        ),
      ),
    );
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CartScreen(controller: widget.controller),
      ),
    );
  }

  void _openTracking() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderTrackingScreen(controller: widget.controller),
      ),
    );
  }

  void _handleNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(AppRoutes.patientHome);
      case 1:
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.doctorDetail, arguments: 'doctor_ali');
      case 2:
        return;
      case 3:
        Navigator.of(context).pushNamed(AppRoutes.medicalRecords);
      case 4:
        Navigator.of(context).pushReplacementNamed(AppRoutes.wallet);
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
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
          children: [
            const Text(
              'Select delivery city',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
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
      ),
    );
    if (selected != null && mounted) widget.controller.selectCity(selected);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final featured = controller.medicines.take(6).toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFA),
      bottomNavigationBar: _PharmacyNav(onTap: _handleNavTap),
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
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                      children: [
                        _Header(
                          city: controller.selectedCity,
                          cartCount: controller.cartCount,
                          hasActiveOrder: controller.activeOrder != null,
                          onCityTap: _selectCity,
                          onCartTap: _openCart,
                          onOrderTap: _openTracking,
                        ),
                        const SizedBox(height: 14),
                        _SearchBox(onTap: _openSearch),
                        if (controller.hasError) ...[
                          const SizedBox(height: 10),
                          _ErrorBanner(
                            message:
                                controller.errorMessage ??
                                'We could not load the pharmacy.',
                            onRetry: controller.refresh,
                          ),
                        ],
                        const SizedBox(height: 14),
                        _HeroBanner(onTap: _openSearch),
                        const SizedBox(height: 14),
                        _QuickActions(
                          onUpload: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.medicalRecords),
                          onQuickOrder: _openSearch,
                          onReminder: () => _showMessage(
                            'Medicine reminders will connect to notifications.',
                          ),
                          onOffers: _openSearch,
                        ),
                        const SizedBox(height: 18),
                        const _SectionTitle(title: 'Shop by Category'),
                        const SizedBox(height: 12),
                        _CategoryRow(
                          onTap: (value) => _openSearch(category: value),
                        ),
                        const SizedBox(height: 20),
                        _SectionTitle(
                          title: 'Featured Products',
                          onTap: _openSearch,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 218,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: featured.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 10),
                            itemBuilder: (_, index) {
                              final medicine = featured[index];
                              return _FeaturedMedicineCard(
                                medicine: medicine,
                                onTap: () => _openMedicine(medicine),
                                onAdd: () {
                                  controller.addToCart(medicine);
                                  _showMessage(
                                    '${medicine.brandName} added to cart.',
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        const _TrustStrip(),
                        const SizedBox(height: 20),
                        const _SectionTitle(title: 'Nearby Pharmacies'),
                        const SizedBox(height: 10),
                        _NearbyPharmacyCard(
                          name: controller.selectedPharmacy,
                          onTap: _openSearch,
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
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.health_and_safety_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'AsaanCare',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onCityTap,
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.textDark,
            minimumSize: const Size(72, 44),
            padding: const EdgeInsets.symmetric(horizontal: 7),
          ),
          icon: const Icon(Icons.location_on_outlined, size: 16),
          label: Text(
            city,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        if (hasActiveOrder)
          IconButton(
            onPressed: onOrderTap,
            tooltip: 'Track order',
            icon: const Icon(Icons.delivery_dining_outlined, size: 21),
          ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: onCartTap,
              tooltip: 'Shopping cart',
              icon: const Icon(Icons.shopping_cart_outlined, size: 22),
            ),
            if (cartCount > 0)
              Positioned(
                right: 4,
                top: 2,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE04444),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$cartCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4ECEA)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: Color(0xFF7A8D91), size: 21),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Search medicines, health products...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFF718287), fontSize: 12),
                ),
              ),
              Icon(Icons.tune_rounded, color: AppTheme.primary, size: 19),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 164),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF075B5F), Color(0xFF00877A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2A075B5F),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -26,
            top: -22,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0x1718D5B5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Positioned(right: 18, bottom: 18, child: _HeroMedicineArt()),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 130, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Medicines at\nyour doorstep',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    height: 1.03,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Quick, safe & reliable delivery\nfrom trusted pharmacies',
                  style: TextStyle(
                    color: Color(0xDFFFFFFF),
                    fontSize: 10.5,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 32,
                  child: FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      minimumSize: const Size(98, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    child: const Text('Order Medicines  →'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMedicineArt extends StatelessWidget {
  const _HeroMedicineArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 112,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            right: 2,
            bottom: 0,
            child: Container(
              width: 72,
              height: 92,
              decoration: BoxDecoration(
                color: const Color(0xFFE9FFFA),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 12),
                ],
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                color: Color(0xFF18B594),
                size: 38,
              ),
            ),
          ),
          Positioned(
            left: 3,
            bottom: 4,
            child: Container(
              width: 34,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.medication_rounded,
                color: Color(0xFF0B9385),
                size: 21,
              ),
            ),
          ),
          const Positioned(
            left: 22,
            top: 2,
            child: Icon(Icons.add_rounded, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onUpload,
    required this.onQuickOrder,
    required this.onReminder,
    required this.onOffers,
  });

  final VoidCallback onUpload;
  final VoidCallback onQuickOrder;
  final VoidCallback onReminder;
  final VoidCallback onOffers;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.upload_file_rounded, 'Upload\nPrescription', onUpload),
      (Icons.bolt_rounded, 'Quick\nOrder', onQuickOrder),
      (Icons.alarm_rounded, 'Medicine\nReminder', onReminder),
      (Icons.sell_outlined, 'Offers &\nDeals', onOffers),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: _ActionTile(
              icon: items[index].$1,
              label: items[index].$2,
              onTap: items[index].$3,
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(13),
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0xFFE5EFEC)),
              ),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F6F2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primary, size: 17),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 9.5,
            height: 1.15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.onTap});
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              minimumSize: const Size(54, 44),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            child: const Text('View all', style: TextStyle(fontSize: 10)),
          ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.onTap});
  final ValueChanged<MedicineCategory?> onTap;

  @override
  Widget build(BuildContext context) {
    const categories = [
      (MedicineCategory.painRelief, Icons.medication_rounded, 'Pain Relief'),
      (MedicineCategory.coldAndFlu, Icons.air_rounded, 'Cold & Flu'),
      (MedicineCategory.diabetesCare, Icons.bloodtype_outlined, 'Diabetes'),
      (MedicineCategory.heartCare, Icons.favorite_rounded, 'Heart Care'),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index <= categories.length; index++) ...[
          if (index > 0) const SizedBox(width: 5),
          Expanded(
            child: _CategoryItem(
              icon: index == categories.length
                  ? Icons.grid_view_rounded
                  : categories[index].$2,
              label: index == categories.length
                  ? 'View All'
                  : categories[index].$3,
              onTap: () => onTap(
                index == categories.length ? null : categories[index].$1,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFE7F6F1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 9,
              height: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedMedicineCard extends StatelessWidget {
  const _FeaturedMedicineCard({
    required this.medicine,
    required this.onTap,
    required this.onAdd,
  });
  final Medicine medicine;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE6EEEC)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      height: 84,
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: SizedBox(
                          width: 100,
                          height: 112,
                          child: MedicineVisual(medicine: medicine),
                        ),
                      ),
                    ),
                    if (medicine.isOnSale)
                      Positioned(
                        left: -3,
                        top: -3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEB),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '${medicine.discountPercent}% OFF',
                            style: const TextStyle(
                              color: Color(0xFFD93636),
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  medicine.brandName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 10.5,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  medicine.strength,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 8.5,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Rs. ${medicine.price}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Add ${medicine.brandName} to cart',
                      child: InkWell(
                        onTap: medicine.isInStock ? onAdd : null,
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: medicine.isInStock
                                ? AppTheme.primary
                                : const Color(0xFFCAD5D2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
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
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.verified_outlined, '100% Genuine', 'Medicines'),
      (Icons.schedule_rounded, 'Licensed', 'Pharmacies'),
      (Icons.shield_outlined, 'Secure', 'Payments'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xFFE3ECEA)),
        ),
      ),
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0)
              const SizedBox(
                height: 30,
                child: VerticalDivider(width: 12, color: Color(0xFFE3ECEA)),
              ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(items[index].$1, color: AppTheme.primary, size: 17),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      '${items[index].$2}\n${items[index].$3}',
                      maxLines: 2,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 8,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NearbyPharmacyCard extends StatelessWidget {
  const _NearbyPharmacyCard({required this.name, required this.onTap});
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 122,
      padding: const EdgeInsets.fromLTRB(13, 13, 8, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF159D76),
                      size: 13,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Open · 1.2 km · Rating 4.7',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 8.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  height: 32,
                  child: FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(150, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: const Text('Order from this pharmacy'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const SizedBox(
            width: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  right: 3,
                  bottom: 8,
                  child: Icon(
                    Icons.delivery_dining_rounded,
                    color: AppTheme.primary,
                    size: 66,
                  ),
                ),
                Positioned(
                  left: 2,
                  top: 6,
                  child: Icon(
                    Icons.local_pharmacy_rounded,
                    color: Color(0xFF20AE88),
                    size: 35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PharmacyNav extends StatelessWidget {
  const _PharmacyNav({required this.onTap});
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, 'Home'),
      (Icons.medical_services_outlined, 'Doctors'),
      (Icons.medication_rounded, 'Pharmacy'),
      (Icons.note_alt_outlined, 'Records'),
      (Icons.person_outline_rounded, 'Account'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE4ECEA))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 4),
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = index == 2;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: items[index].$2,
                  child: InkWell(
                    onTap: () => onTap(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          items[index].$1,
                          size: 21,
                          color: selected
                              ? AppTheme.primary
                              : const Color(0xFF8A999C),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[index].$2,
                          style: TextStyle(
                            color: selected
                                ? AppTheme.primary
                                : const Color(0xFF8A999C),
                            fontSize: 8.5,
                            fontWeight: selected
                                ? FontWeight.w900
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppTheme.danger),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12))),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
