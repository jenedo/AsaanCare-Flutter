import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../appointments/domain/entities/consultation_type.dart';
import '../../domain/entities/doctor.dart';

class DoctorProfileBody extends StatelessWidget {
  const DoctorProfileBody({
    super.key,
    required this.doctor,
    required this.isFavorite,
    required this.selectedTab,
    required this.selectedMode,
    required this.isBooking,
    required this.onBack,
    required this.onFavorite,
    required this.onShare,
    required this.onTabSelected,
    required this.onModeSelected,
    required this.onBook,
  });

  final Doctor doctor;
  final bool isFavorite;
  final int selectedTab;
  final ConsultationType selectedMode;
  final bool isBooking;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final VoidCallback onShare;
  final ValueChanged<int> onTabSelected;
  final ValueChanged<ConsultationType> onModeSelected;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HeroHeader(
                doctor: doctor,
                isFavorite: isFavorite,
                onBack: onBack,
                onFavorite: onFavorite,
                onShare: onShare,
              ),
            ),
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(34),
                    ),
                  ),
                  child: Column(
                    children: [
                      _Identity(doctor: doctor),
                      _Stats(doctor: doctor),
                      _Tabs(selected: selectedTab, onSelected: onTabSelected),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _TabContent(
                          key: ValueKey(selectedTab),
                          tab: selectedTab,
                          doctor: doctor,
                          selectedMode: selectedMode,
                          onModeSelected: onModeSelected,
                        ),
                      ),
                      const SizedBox(height: 116),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 14,
          child: _BookButton(isBooking: isBooking, onTap: onBook),
        ),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.doctor,
    required this.isFavorite,
    required this.onBack,
    required this.onFavorite,
    required this.onShare,
  });

  final Doctor doctor;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFD7E0E8), Color(0xFFBFD8E2)],
              ),
            ),
          ),
          Positioned(
            left: -30,
            top: 80,
            child: _BlurBubble(size: 150, color: Color(0x556EB6D0)),
          ),
          Positioned(
            right: -10,
            top: 48,
            child: _BlurBubble(size: 110, color: Color(0x44FFFFFF)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              doctor.imageAsset,
              height: 294,
              width: 330,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (_, _, _) => const Icon(
                Icons.person_rounded,
                size: 190,
                color: Color(0xFF7CA7AF),
              ),
            ),
          ),
          Positioned(
            left: 22,
            top: 22,
            child: _RoundAction(
              icon: Icons.arrow_back_ios_new_rounded,
              label: 'Back',
              onTap: onBack,
            ),
          ),
          Positioned(
            right: 76,
            top: 22,
            child: _RoundAction(
              icon: isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              iconColor: isFavorite ? AppTheme.danger : null,
              label: isFavorite ? 'Remove favorite' : 'Add favorite',
              onTap: onFavorite,
            ),
          ),
          Positioned(
            right: 18,
            top: 22,
            child: _RoundAction(
              icon: Icons.share_outlined,
              label: 'Share profile',
              onTap: onShare,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurBubble extends StatelessWidget {
  const _BlurBubble({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    height: size,
    width: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .9),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Semantics(
          button: true,
          label: label,
          child: SizedBox(
            width: 50,
            height: 50,
            child: Icon(
              icon,
              size: 25,
              color: iconColor ?? const Color(0xFF45566E),
            ),
          ),
        ),
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.doctor});
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  doctor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF07132D),
                    fontSize: 28,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.7,
                  ),
                ),
              ),
              if (doctor.isVerified) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF0A8584),
                  size: 27,
                ),
              ],
            ],
          ),
          const SizedBox(height: 9),
          Text(
            '${doctor.specialty}  •  ${doctor.experienceYears}+ Years Experience',
            style: const TextStyle(
              color: Color(0xFF53627A),
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            doctor.qualification,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF53627A),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.doctor});
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xFFE2E9ED)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              icon: Icons.star_rounded,
              iconColor: Color(0xFFFFA500),
              title: doctor.rating.toStringAsFixed(1),
              subtitle: '(${doctor.reviewCount} reviews)',
            ),
          ),
          const _Divider(),
          const Expanded(
            child: _Stat(
              icon: Icons.verified_user_rounded,
              title: 'Verified',
              subtitle: 'PMDC Doctor',
            ),
          ),
          const _Divider(),
          Expanded(
            child: _Stat(
              icon: Icons.people_alt_rounded,
              title: '${_formatNumber(doctor.patientsCount)}+',
              subtitle: 'Patients treated',
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      Container(height: 40, width: 1, color: const Color(0xFFE2E9ED));
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor = const Color(0xFF07827E),
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 23),
          const SizedBox(width: 7),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF07132D),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Color(0xFF68758C),
                    fontSize: 11.5,
                    height: 1.2,
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

class _Tabs extends StatelessWidget {
  const _Tabs({required this.selected, required this.onSelected});
  final int selected;
  final ValueChanged<int> onSelected;
  static const labels = ['About', 'Services', 'Reviews', 'Experience'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5EBEF))),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final active = selected == index;
          return Expanded(
            child: InkWell(
              onTap: () => onSelected(index),
              child: Container(
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: active
                          ? const Color(0xFF07827E)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: active
                        ? const Color(0xFF07827E)
                        : const Color(0xFF718097),
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({
    super.key,
    required this.tab,
    required this.doctor,
    required this.selectedMode,
    required this.onModeSelected,
  });
  final int tab;
  final Doctor doctor;
  final ConsultationType selectedMode;
  final ValueChanged<ConsultationType> onModeSelected;

  @override
  Widget build(BuildContext context) {
    if (tab == 1) {
      return const _SimpleTab(
        icon: Icons.medical_services_outlined,
        title: 'Medical Services',
        text:
            'Consultation, diagnosis, follow-up care and preventive health guidance.',
      );
    }
    if (tab == 2) {
      return _SimpleTab(
        icon: Icons.star_outline_rounded,
        title: '${doctor.reviewCount} Patient Reviews',
        text:
            'Patients appreciate ${doctor.name} for clear advice, attentive care and helpful follow-ups.',
      );
    }
    if (tab == 3) {
      return _SimpleTab(
        icon: Icons.workspace_premium_outlined,
        title: '${doctor.experienceYears}+ Years Experience',
        text:
            '${doctor.qualification} with extensive clinical and patient-care experience.',
      );
    }
    return _AboutTab(
      doctor: doctor,
      selectedMode: selectedMode,
      onModeSelected: onModeSelected,
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({
    required this.doctor,
    required this.selectedMode,
    required this.onModeSelected,
  });
  final Doctor doctor;
  final ConsultationType selectedMode;
  final ValueChanged<ConsultationType> onModeSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consultation Modes',
            style: TextStyle(
              color: Color(0xFF07132D),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 12) / 2;
              const modes = [
                (
                  ConsultationType.audio,
                  Icons.call_rounded,
                  'Audio',
                  'Consultation',
                ),
                (
                  ConsultationType.video,
                  Icons.videocam_rounded,
                  'Video',
                  'Consultation',
                ),
                (
                  ConsultationType.chat,
                  Icons.chat_bubble_rounded,
                  'Chat',
                  'Session',
                ),
                (
                  ConsultationType.clinic,
                  Icons.local_hospital_rounded,
                  'Clinic',
                  'Visit',
                ),
              ];
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(modes.length, (index) {
                  final mode = modes[index];
                  return SizedBox(
                    width: width,
                    child: _ModeCard(
                      icon: mode.$2,
                      title: mode.$3,
                      subtitle: mode.$4,
                      selected: mode.$1 == selectedMode,
                      onTap: () => onModeSelected(mode.$1),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 24),
          _InfoRow(
            icon: Icons.info_outline_rounded,
            title: 'About',
            text: doctor.about,
          ),
          const _InfoRow(
            icon: Icons.language_rounded,
            title: 'Languages',
            text: 'English, Urdu, Punjabi',
          ),
          _InfoRow(
            icon: Icons.monitor_heart_outlined,
            title: 'Conditions Treated',
            text: _conditionsFor(doctor.specialty),
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFF4FBFA) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 82,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected
                  ? const Color(0xFF07827E)
                  : const Color(0xFFBFDCDD),
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F4F4),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Color(0xFF07827E), size: 27),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF07132D),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF53627A),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF7A8798),
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.text,
    this.showDivider = true,
  });
  final IconData icon;
  final String title;
  final String text;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: Color(0xFFE3E9ED)))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F4F4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(0xFF07827E), size: 26),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF07132D),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF53627A),
                    fontSize: 14.5,
                    height: 1.5,
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

class _SimpleTab extends StatelessWidget {
  const _SimpleTab({
    required this.icon,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: _InfoRow(icon: icon, title: title, text: text, showDivider: false),
    );
  }
}

class _BookButton extends StatelessWidget {
  const _BookButton({required this.isBooking, required this.onTap});
  final bool isBooking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF078E88), Color(0xFF087570)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33076562),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: isBooking ? null : onTap,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 62,
            child: Center(
              child: isBooking
                  ? const SizedBox(
                      height: 23,
                      width: 23,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.white,
                          size: 27,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Book Appointment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
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

class DoctorDetailErrorState extends StatelessWidget {
  const DoctorDetailErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.danger, size: 42),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

String _formatNumber(int value) {
  if (value < 1000) return value.toString();
  final number = value / 1000;
  return '${number % 1 == 0 ? number.toStringAsFixed(0) : number.toStringAsFixed(1)}K';
}

String _conditionsFor(String specialty) {
  final value = specialty.toLowerCase();
  if (value.contains('cardio')) {
    return 'Hypertension, Chest Pain, Arrhythmia, Heart Failure, Cholesterol';
  }
  if (value.contains('gyne')) {
    return 'Women’s health, Pregnancy care, PCOS, Menstrual disorders';
  }
  if (value.contains('derma')) {
    return 'Acne, Eczema, Allergies, Hair loss, Skin infections';
  }
  return 'General illness, Preventive care, Diagnosis and follow-up treatment';
}
