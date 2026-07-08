import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../controllers/pharmacy_controller.dart';
import '../widgets/medicine_card.dart';
import '../widgets/pharmacy_category_card.dart';
import '../widgets/prescription_banner.dart';

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
    widget.controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label coming next.')));
  }

  void _handleNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.patientHome);
      return;
    }

    if (index == 1) {
      Navigator.of(
        context,
      ).pushNamed(AppRoutes.doctorDetail, arguments: 'doctor_ali');
      return;
    }

    if (index == 2) return;

    const labels = ['Home', 'Consult', 'Pharmacy', 'Records', 'Wallet'];
    _showComingSoon(labels[index]);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final prescription = controller.recentPrescription;

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
            constraints: const BoxConstraints(maxWidth: 430),
            child: controller.isLoading && controller.popularMedicines.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
                    children: [
                      _PharmacyHeader(
                        onSearchTap: () => _showComingSoon('Search'),
                        onCartTap: () => _showComingSoon('Cart'),
                      ),
                      const SizedBox(height: 22),
                      _SearchBox(
                        onTap: () => _showComingSoon('Medicine search'),
                        onMicTap: () => _showComingSoon('Voice search'),
                      ),
                      const SizedBox(height: 24),
                      PrescriptionBanner(
                        onUploadTap: () =>
                            _showComingSoon('Upload prescription'),
                      ),
                      const SizedBox(height: 26),
                      _SectionHeader(
                        title: 'Medicine Categories',
                        onTap: () => _showComingSoon('All categories'),
                      ),
                      const SizedBox(height: 16),
                      _MedicineCategories(onTap: _showComingSoon),
                      const SizedBox(height: 24),
                      if (prescription != null)
                        _RecentPrescriptionCard(
                          title: prescription.title,
                          uploadedDate: prescription.uploadedDate,
                          imageAsset: prescription.imageAsset,
                          isVerified: prescription.isVerified,
                          onOrderAgainTap: () => _showComingSoon('Order again'),
                        ),
                      const SizedBox(height: 26),
                      _SectionHeader(
                        title: 'Popular Medicines',
                        onTap: () => _showComingSoon('All medicines'),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 128,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.popularMedicines.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final medicine = controller.popularMedicines[index];

                            return MedicineCard(
                              medicine: medicine,
                              onAddTap: () => _showComingSoon(
                                '${medicine.name} added to cart',
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _BenefitsPanel(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _PharmacyHeader extends StatelessWidget {
  const _PharmacyHeader({required this.onSearchTap, required this.onCartTap});

  final VoidCallback onSearchTap;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pharmacy',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.primary,
                    size: 28,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF07132D),
                    size: 21,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Lahore',
                    style: TextStyle(
                      color: Color(0xFF07132D),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF07132D),
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onSearchTap,
          icon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF07132D),
            size: 34,
          ),
        ),
        IconButton(
          onPressed: onCartTap,
          icon: const Icon(
            Icons.shopping_cart_outlined,
            color: Color(0xFF07132D),
            size: 32,
          ),
        ),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.onTap, required this.onMicTap});

  final VoidCallback onTap;
  final VoidCallback onMicTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border, width: 1.4),
          ),
          child: Row(
            children: [
              const SizedBox(width: 18),
              const Icon(
                Icons.search_rounded,
                color: Color(0xFF657386),
                size: 30,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Search medicines, brands...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF667386),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: onMicTap,
                icon: const Icon(
                  Icons.mic_none_rounded,
                  color: Color(0xFF07132D),
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicineCategories extends StatelessWidget {
  const _MedicineCategories({required this.onTap});

  final ValueChanged<String> onTap;

  static const _items = [
    _CategoryData(Icons.medication_outlined, 'All Medicines'),
    _CategoryData(Icons.sanitizer_outlined, 'Personal Care'),
    _CategoryData(Icons.local_florist_outlined, 'Vitamins'),
    _CategoryData(Icons.bloodtype_outlined, 'Diabetes Care'),
    _CategoryData(Icons.child_care_outlined, 'Baby Care'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = _items[index];

          return PharmacyCategoryCard(
            icon: item.icon,
            title: item.title,
            onTap: () => onTap(item.title),
          );
        },
      ),
    );
  }
}

class _RecentPrescriptionCard extends StatelessWidget {
  const _RecentPrescriptionCard({
    required this.title,
    required this.uploadedDate,
    required this.imageAsset,
    required this.isVerified,
    required this.onOrderAgainTap,
  });

  final String title;
  final String uploadedDate;
  final String imageAsset;
  final bool isVerified;
  final VoidCallback onOrderAgainTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 108),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2FBFA),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFD4EFEC)),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 58,
            width: 58,
            child: Image.asset(imageAsset, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF07132D),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  uploadedDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF536078),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.softTeal,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'Verified',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(99),
                child: InkWell(
                  onTap: onOrderAgainTap,
                  borderRadius: BorderRadius.circular(99),
                  child: Ink(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryLight, AppTheme.primary],
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Center(
                      child: Text(
                        'Order Again',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BenefitsPanel extends StatelessWidget {
  const _BenefitsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F7),
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _BenefitItem(
              icon: Icons.verified_user_outlined,
              title: '100% Genuine',
              subtitle: 'Medicines',
            ),
          ),
          _SmallDivider(),
          Expanded(
            child: _BenefitItem(
              icon: Icons.delivery_dining_outlined,
              title: 'Fast & Safe',
              subtitle: 'Delivery',
            ),
          ),
          _SmallDivider(),
          Expanded(
            child: _BenefitItem(
              icon: Icons.currency_exchange_rounded,
              title: 'Easy Returns',
              subtitle: 'Policy',
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 28),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            '$title\n$subtitle',
            style: const TextStyle(
              color: AppTheme.primaryDark,
              fontSize: 12.2,
              height: 1.25,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SmallDivider extends StatelessWidget {
  const _SmallDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 46, width: 1, color: AppTheme.border);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

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
              letterSpacing: -0.3,
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: const Text(
            'View all',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryData {
  const _CategoryData(this.icon, this.title);

  final IconData icon;
  final String title;
}
