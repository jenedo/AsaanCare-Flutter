import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/doctor.dart';

class SpecialtyChips extends StatelessWidget {
  const SpecialtyChips({
    super.key,
    required this.specialties,
    required this.selected,
    required this.onSelected,
  });

  final List<String> specialties;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = ['All', ...specialties];
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = items[index];
          final value = index == 0 ? null : label;
          final isSelected = selected == value;
          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: () => onSelected(value),
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : AppTheme.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : AppTheme.border,
                  ),
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textDark,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DoctorBookingCard extends StatefulWidget {
  const DoctorBookingCard({
    super.key,
    required this.doctor,
    required this.bookingDates,
    required this.onTap,
    this.dark = false,
  }) : assert(bookingDates.length >= 3);

  final Doctor doctor;
  final List<DateTime> bookingDates;
  final VoidCallback onTap;
  final bool dark;

  @override
  State<DoctorBookingCard> createState() => _DoctorBookingCardState();
}

class _DoctorBookingCardState extends State<DoctorBookingCard> {
  int _selectedDay = 2;

  @override
  Widget build(BuildContext context) {
    final slotCount = 4 + (widget.doctor.id.hashCode.abs() % 5);
    final foreground = widget.dark ? Colors.white : AppTheme.textDark;
    final muted = widget.dark ? const Color(0xFFD3D5D7) : AppTheme.textMuted;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          constraints: const BoxConstraints(minHeight: 286),
          decoration: BoxDecoration(
            gradient: widget.dark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF132D31), Color(0xFF081B1E)],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFEDF6F4)],
                  ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: widget.dark ? const Color(0xFF29474A) : AppTheme.border,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A075B5F),
                blurRadius: 26,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 310;
              return Stack(
                children: [
                  Positioned(
                    right: compact ? -16 : -4,
                    top: 30,
                    child: Semantics(
                      image: true,
                      label: 'Portrait of ${widget.doctor.name}',
                      child: SizedBox(
                        width: compact ? 138 : 164,
                        height: 170,
                        child: Image.asset(
                          widget.doctor.imageAsset,
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.person_rounded,
                            size: 112,
                            color: widget.dark
                                ? Colors.white54
                                : AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 12 : 16,
                      14,
                      compact ? 12 : 16,
                      12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _Pill(
                              icon: Icons.star_rounded,
                              text: widget.doctor.rating.toStringAsFixed(1),
                              iconColor: const Color(0xFFFFC83D),
                              dark: widget.dark,
                            ),
                            const SizedBox(width: 7),
                            _Pill(
                              icon: Icons.payments_rounded,
                              text: 'Rs. ${widget.doctor.consultationFee}',
                              iconColor: const Color(0xFF66C56C),
                              dark: widget.dark,
                            ),
                            if (widget.doctor.isVerified) ...[
                              const Spacer(),
                              Icon(
                                Icons.verified_rounded,
                                color: widget.dark
                                    ? const Color(0xFF5FE0D2)
                                    : AppTheme.primary,
                                size: 21,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: compact ? 130 : 160,
                          child: Text(
                            widget.doctor.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: foreground,
                              fontSize: compact ? 18 : 21,
                              height: 1.12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: compact ? 126 : 150,
                          child: Text(
                            widget.doctor.specialty,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          '$slotCount Slots Available',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _AvailabilityStrip(
                          doctorId: widget.doctor.id,
                          dates: widget.bookingDates,
                          selectedDay: _selectedDay,
                          dark: widget.dark,
                          onSelected: (index) {
                            setState(() => _selectedDay = index);
                          },
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

class _AvailabilityStrip extends StatelessWidget {
  const _AvailabilityStrip({
    required this.doctorId,
    required this.dates,
    required this.selectedDay,
    required this.dark,
    required this.onSelected,
  });

  final String doctorId;
  final List<DateTime> dates;
  final int selectedDay;
  final bool dark;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: dark ? const Color(0x4DFFFFFF) : const Color(0xBFFFFFFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: dark ? const Color(0x33FFFFFF) : Colors.white,
        ),
      ),
      child: Row(
        children: List.generate(dates.length, (index) {
          final selected = selectedDay == index;
          final date = dates[index];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == dates.length - 1 ? 0 : 3,
              ),
              child: Semantics(
                button: true,
                selected: selected,
                label: selected
                    ? 'Selected appointment day, ${_weekdayLabel(date.weekday)} ${date.day}'
                    : 'Choose appointment day, ${_weekdayLabel(date.weekday)} ${date.day}',
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    key: ValueKey('$doctorId-day-$index'),
                    onTap: () => onSelected(index),
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: selected
                            ? (dark
                                  ? const Color(0xFF091719)
                                  : AppTheme.primary)
                            : (dark ? const Color(0xFFF8FBFA) : Colors.white),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected
                              ? (dark ? Colors.white70 : AppTheme.primary)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _weekdayLabel(date.weekday),
                            maxLines: 1,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppTheme.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppTheme.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
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

String _weekdayLabel(int weekday) {
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[weekday - 1];
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.text,
    required this.iconColor,
    required this.dark,
  });
  final IconData icon;
  final String text;
  final Color iconColor;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFFF5F7F6) : Colors.white,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFFE8EEEC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class FindDoctorsHeader extends StatelessWidget {
  const FindDoctorsHeader({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 320;
      return Row(
        children: [
          Material(
            color: AppTheme.surface,
            shape: const CircleBorder(side: BorderSide(color: AppTheme.border)),
            child: IconButton(
              onPressed: onBack,
              tooltip: 'Back',
              constraints: const BoxConstraints.tightFor(width: 50, height: 50),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Find Doctor',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: compact ? 25 : 29,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class DoctorSearchField extends StatelessWidget {
  const DoctorSearchField({super.key, required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    onChanged: onChanged,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: 'Doctor, specialty, or condition',
      prefixIcon: const Icon(Icons.search_rounded),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xFFE4E5E8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xFFE4E5E8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
      ),
    ),
  );
}

class FindDoctorsRoundAction extends StatelessWidget {
  const FindDoctorsRoundAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: Material(
      color: active ? AppTheme.softTeal : AppTheme.surface,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 50,
          width: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: active ? AppTheme.primary : AppTheme.border,
            ),
          ),
          child: Icon(
            icon,
            color: active ? AppTheme.primary : AppTheme.textDark,
            size: 21,
          ),
        ),
      ),
    ),
  );
}

class FindDoctorsMessageState extends StatelessWidget {
  const FindDoctorsMessageState({
    super.key,
    required this.icon,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String message;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: const Color(0xFF8A9099)),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: action, child: const Text('Try again')),
          ],
        ],
      ),
    ),
  );
}
