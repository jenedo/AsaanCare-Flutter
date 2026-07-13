import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/layout/app_layout.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/user_initials.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../widgets/patient_home_card.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentNavIndex = 0;

  static const String _bannerDoctor = 'assets/images/doctor_appointment.png';
  static const String _doctorSara = 'assets/images/doctor_sara.png';
  static const String _doctorAli = 'assets/images/doctor_ali.png';
  static const String _doctorMaheen = 'assets/images/doctor_maheen.png';

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label screen coming next.')));
  }

  void _openDoctor(String doctorId) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.doctorDetail, arguments: doctorId);
  }

  void _openPharmacy() {
    Navigator.of(context).pushNamed(AppRoutes.pharmacy);
  }

  void _openCategory(String specialty) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.findDoctors, arguments: specialty);
  }

  void _handleNavTap(int index) {
    switch (index) {
      case 0:
        if (_currentNavIndex != 0) {
          setState(() => _currentNavIndex = 0);
        }
        return;

      case 1:
        Navigator.of(context).pushNamed(AppRoutes.findDoctors);
        return;

      case 2:
        _openPharmacy();
        return;

      case 3:
        Navigator.of(context).pushNamed(AppRoutes.medicalRecords);
        return;

      case 4:
        Navigator.of(context).pushNamed(AppRoutes.wallet);
        return;

      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
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
                14,
                AppLayout.horizontalPadding(context),
                26,
              ),
              children: [
                _Header(
                  userName:
                      widget.authController.currentUser?.fullName ?? 'Patient',
                  onNotificationTap: () => _showComingSoon('Notifications'),
                  onProfileTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.profile),
                ),
                const SizedBox(height: 16),
                _SearchBar(
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.findDoctors),
                  onMicTap: () => _showComingSoon('Voice search'),
                ),
                const SizedBox(height: 14),
                _ConsultBanner(
                  doctorAsset: _bannerDoctor,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.findDoctors),
                ),
                const SizedBox(height: 18),
                _SectionHeader(
                  title: 'Categories',
                  actionText: 'View all',
                  onTap: () => _showComingSoon('All categories'),
                ),
                const SizedBox(height: 10),
                _CategoriesRow(onTap: _openCategory),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Featured Doctors',
                  actionText: 'View all',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.findDoctors),
                ),
                const SizedBox(height: 14),
                _FeaturedDoctorsRow(
                  doctorSara: _doctorSara,
                  doctorAli: _doctorAli,
                  doctorMaheen: _doctorMaheen,
                  onTap: _openDoctor,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 350;
                    final columns = compact ? 2 : 4;

                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: compact ? 1.35 : 0.82,
                      children: [
                        PatientHomeCard(
                          icon: Icons.calendar_month_outlined,
                          title: 'My\nAppointments',
                          iconColor: const Color(0xFF2563EB),
                          onTap: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.appointments),
                        ),
                        PatientHomeCard(
                          icon: Icons.medication_liquid_outlined,
                          title: 'Order\nMedicine',
                          onTap: _openPharmacy,
                        ),
                        PatientHomeCard(
                          icon: Icons.upload_file_outlined,
                          title: 'Upload\nPrescription',
                          onTap: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.medicalRecords),
                        ),
                        PatientHomeCard(
                          icon: Icons.health_and_safety_outlined,
                          title: 'Health\nTools',
                          onTap: () => _showComingSoon('Health tools'),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Upcoming Appointment',
                  actionText: 'View all',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.appointments),
                ),
                const SizedBox(height: 12),
                _UpcomingAppointmentCard(
                  doctorAsset: _doctorAli,
                  onTap: () => _openDoctor('doctor_ali'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.userName,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  final String userName;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  String _greetingForHour(int hour) {
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    if (hour < 21) return 'Good evening,';
    return 'Good night,';
  }

  @override
  Widget build(BuildContext context) {
    final compact = AppLayout.isCompact(context);
    final greeting = _greetingForHour(DateTime.now().hour);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: compact ? 15 : 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.25,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNotificationTap,
          tooltip: 'Notifications',
          visualDensity: VisualDensity.compact,
          icon: Badge(
            smallSize: 7,
            backgroundColor: AppTheme.primary,
            child: Icon(
              Icons.notifications_none_rounded,
              size: compact ? 22 : 24,
              color: AppTheme.textMuted,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Semantics(
          button: true,
          label: 'Open profile and settings',
          child: InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(40),
            child: CircleAvatar(
              radius: compact ? 18 : 20,
              backgroundColor: AppTheme.softTeal,
              child: Text(
                UserInitials.fromName(userName),
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap, required this.onMicTap});

  final VoidCallback onTap;
  final VoidCallback onMicTap;

  @override
  Widget build(BuildContext context) {
    final compact = AppLayout.isCompact(context);

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: compact ? 44 : 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(
                Icons.search_rounded,
                color: AppTheme.textMuted,
                size: compact ? 20 : 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Search doctors, symptoms, medicines...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: compact ? 10.5 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: onMicTap,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: const Icon(
                  Icons.mic_none_rounded,
                  color: AppTheme.textDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsultBanner extends StatelessWidget {
  const _ConsultBanner({required this.doctorAsset, required this.onTap});

  final String doctorAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = AppLayout.isCompact(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: compact ? 154 : 174,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [Color(0xFF075B5F), Color(0xFF008E83)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                right: -24,
                bottom: -18,
                child: Container(
                  height: 190,
                  width: 190,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: -6,
                bottom: -2,
                child: Image.asset(
                  doctorAsset,
                  height: compact ? 150 : 170,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                left: 14,
                top: compact ? 15 : 17,
                width: compact ? 160 : 190,
                child: Text(
                  'Talk to a Doctor\nAnytime, Anywhere',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 17 : 19,
                    height: 1.18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Positioned(
                left: 14,
                top: compact ? 61 : 69,
                width: compact ? 142 : 162,
                child: Text(
                  'Start a video consultation in minutes.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 10.5 : 12,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 14,
                bottom: compact ? 13 : 15,
                child: Container(
                  height: compact ? 32 : 36,
                  padding: EdgeInsets.symmetric(horizontal: compact ? 15 : 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Consult Now',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 96,
                top: 59,
                child: Icon(
                  Icons.health_and_safety_outlined,
                  color: Colors.white.withValues(alpha: 0.2),
                  size: 46,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onTap,
  });

  final String title;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  const _CategoriesRow({required this.onTap});

  final ValueChanged<String> onTap;

  static const List<_CategoryItem> _items = [
    _CategoryItem(
      imageAsset: AppAssets.generalDoctor,
      title: 'General\nDoctor',
      specialty: 'General Physician',
      bg: Color(0xFFEAF7F5),
    ),
    _CategoryItem(
      imageAsset: AppAssets.pediatrics,
      title: 'Pediatrics',
      specialty: 'Pediatrician',
      bg: Color(0xFFEAF7F5),
    ),
    _CategoryItem(
      imageAsset: AppAssets.gynecology,
      title: 'Gynecology',
      specialty: 'Gynecologist',
      bg: Color(0xFFFFEFEF),
    ),
    _CategoryItem(
      imageAsset: AppAssets.dermatology,
      title: 'Dermatology',
      specialty: 'Dermatologist',
      bg: Color(0xFFFFEFEF),
    ),
    _CategoryItem(
      imageAsset: AppAssets.dentistry,
      title: 'Dentistry',
      specialty: 'Dentist',
      bg: Color(0xFFEAF7F5),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = ((constraints.maxWidth - 24) / 4).clamp(64.0, 82.0);

        return SizedBox(
          height: 102,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = _items[index];

              return SizedBox(
                width: cardWidth,
                child: Material(
                  color: item.bg,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () => onTap(item.specialty),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 10, 5, 7),
                      child: Column(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              item.imageAsset,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.medium,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.medical_services_outlined,
                                    color: AppTheme.primary,
                                    size: 27,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(
                              item.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textDark,
                                fontSize: 9.5,
                                height: 1.08,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _FeaturedDoctorsRow extends StatelessWidget {
  const _FeaturedDoctorsRow({
    required this.doctorSara,
    required this.doctorAli,
    required this.doctorMaheen,
    required this.onTap,
  });

  final String doctorSara;
  final String doctorAli;
  final String doctorMaheen;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 186,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _DoctorCard(
            imageAsset: doctorSara,
            name: 'Dr. Sara Khan',
            specialty: 'General Physician',
            fee: 'Rs. 800',
            rating: '4.8',
            onTap: () => onTap('doctor_sara'),
          ),
          const SizedBox(width: 14),
          _DoctorCard(
            imageAsset: doctorAli,
            name: 'Dr. Ali Raza',
            specialty: 'Cardiologist',
            fee: 'Rs. 1,000',
            rating: '4.9',
            onTap: () => onTap('doctor_ali'),
          ),
          const SizedBox(width: 14),
          _DoctorCard(
            imageAsset: doctorMaheen,
            name: 'Dr. Maheen Fatima',
            specialty: 'Gynecologist',
            fee: 'Rs. 800',
            rating: '4.9',
            onTap: () => onTap('doctor_maheen'),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.imageAsset,
    required this.name,
    required this.specialty,
    required this.fee,
    required this.rating,
    required this.onTap,
  });

  final String imageAsset;
  final String name;
  final String specialty;
  final String fee;
  final String rating;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: 142,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(17),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: AppTheme.softTeal,
                backgroundImage: AssetImage(imageAsset),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                specialty,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFB020),
                    size: 17,
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      '$rating - $fee',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingAppointmentCard extends StatelessWidget {
  const _UpcomingAppointmentCard({
    required this.doctorAsset,
    required this.onTap,
  });

  final String doctorAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 82,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
            boxShadow: AppTheme.softShadow,
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: AppTheme.softTeal,
                    backgroundImage: AssetImage(doctorAsset),
                  ),
                  Positioned(
                    right: -5,
                    bottom: -2,
                    child: Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Icon(
                        Icons.call_outlined,
                        color: AppTheme.primary,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 17),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. Ali Raza',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Cardiologist',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.calendar_month_outlined,
                color: AppTheme.textDark,
                size: 22,
              ),
              const SizedBox(width: 7),
              const Text(
                'Tomorrow\n11:00 AM',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 14,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryItem {
  const _CategoryItem({
    required this.imageAsset,
    required this.title,
    required this.specialty,
    required this.bg,
  });

  final String imageAsset;
  final String title;
  final String specialty;
  final Color bg;
}
