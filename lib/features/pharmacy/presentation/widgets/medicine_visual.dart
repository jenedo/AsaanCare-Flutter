import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/medicine.dart';

class MedicineVisual extends StatelessWidget {
  const MedicineVisual({super.key, required this.medicine, this.large = false});

  final Medicine medicine;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(medicine.category);
    final height = large ? 258.0 : 112.0;

    return Semantics(
      image: true,
      label: '${medicine.brandName} medicine pack illustration',
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.background, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: palette.border),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              right: large ? -34 : -18,
              top: large ? -38 : -18,
              child: Container(
                height: large ? 178 : 88,
                width: large ? 178 : 88,
                decoration: BoxDecoration(
                  color: palette.color.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: large ? 24 : 10,
              top: large ? 24 : 9,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: large ? 10 : 7,
                  vertical: large ? 6 : 4,
                ),
                decoration: BoxDecoration(
                  color: palette.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  medicine.category.label,
                  style: TextStyle(
                    color: palette.color,
                    fontSize: large ? 11 : 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            Center(
              child: Transform.rotate(
                angle: large ? -0.04 : -0.06,
                child: Container(
                  width: large ? 205 : 94,
                  height: large ? 132 : 66,
                  padding: EdgeInsets.all(large ? 17 : 9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(large ? 18 : 11),
                    border: Border.all(
                      color: palette.color.withValues(alpha: 0.30),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x16000000),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: large ? 47 : 24,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              palette.color,
                              palette.color.withValues(alpha: 0.72),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          palette.icon,
                          color: Colors.white,
                          size: large ? 29 : 15,
                        ),
                      ),
                      SizedBox(width: large ? 12 : 6),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicine.brandName,
                              maxLines: large ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xFF07132D),
                                fontSize: large ? 19 : 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: large ? 7 : 3),
                            Text(
                              medicine.strength,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.color,
                                fontSize: large ? 13 : 7.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (large) ...[
                              const SizedBox(height: 4),
                              Text(
                                medicine.manufacturer,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF657386),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: large ? 28 : 10,
              bottom: large ? 25 : 9,
              child: Row(
                children: [
                  _Capsule(color: palette.color, large: large),
                  SizedBox(width: large ? 8 : 4),
                  _Capsule(color: AppTheme.primaryLight, large: large),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Capsule extends StatelessWidget {
  const _Capsule({required this.color, required this.large});

  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.45,
      child: Container(
        height: large ? 15 : 8,
        width: large ? 34 : 18,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

class _MedicinePalette {
  const _MedicinePalette({
    required this.color,
    required this.background,
    required this.border,
    required this.icon,
  });

  final Color color;
  final Color background;
  final Color border;
  final IconData icon;
}

_MedicinePalette _paletteFor(MedicineCategory category) {
  return switch (category) {
    MedicineCategory.painRelief => const _MedicinePalette(
      color: Color(0xFF2563EB),
      background: Color(0xFFEEF4FF),
      border: Color(0xFFD7E4FF),
      icon: Icons.medication_rounded,
    ),
    MedicineCategory.coldAndFlu => const _MedicinePalette(
      color: Color(0xFF0F8C83),
      background: Color(0xFFEAF8F6),
      border: Color(0xFFCBEDE8),
      icon: Icons.air_rounded,
    ),
    MedicineCategory.diabetesCare => const _MedicinePalette(
      color: Color(0xFF7C3AED),
      background: Color(0xFFF4F0FF),
      border: Color(0xFFE4D8FF),
      icon: Icons.bloodtype_outlined,
    ),
    MedicineCategory.heartCare => const _MedicinePalette(
      color: Color(0xFFEF4444),
      background: Color(0xFFFFF0F0),
      border: Color(0xFFFFD5D5),
      icon: Icons.favorite_rounded,
    ),
    MedicineCategory.vitamins => const _MedicinePalette(
      color: Color(0xFFF59E0B),
      background: Color(0xFFFFF8E6),
      border: Color(0xFFFFE9AF),
      icon: Icons.local_drink_outlined,
    ),
    MedicineCategory.babyCare => const _MedicinePalette(
      color: Color(0xFFEC4899),
      background: Color(0xFFFFF0F8),
      border: Color(0xFFFFD5EA),
      icon: Icons.child_care_rounded,
    ),
    MedicineCategory.skinCare => const _MedicinePalette(
      color: Color(0xFFDB2777),
      background: Color(0xFFFFEFF7),
      border: Color(0xFFFFD3E8),
      icon: Icons.spa_outlined,
    ),
    MedicineCategory.personalCare => const _MedicinePalette(
      color: Color(0xFF0891B2),
      background: Color(0xFFECFBFF),
      border: Color(0xFFC9F3FC),
      icon: Icons.clean_hands_outlined,
    ),
    MedicineCategory.firstAid => const _MedicinePalette(
      color: Color(0xFFDC2626),
      background: Color(0xFFFFF1F1),
      border: Color(0xFFFFD6D6),
      icon: Icons.medical_services_outlined,
    ),
    MedicineCategory.digestiveCare => const _MedicinePalette(
      color: Color(0xFF16A34A),
      background: Color(0xFFF0FAF3),
      border: Color(0xFFD1F0DA),
      icon: Icons.health_and_safety_outlined,
    ),
  };
}
