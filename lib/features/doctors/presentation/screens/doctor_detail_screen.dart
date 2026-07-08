import 'package:flutter/material.dart';

import '../../../../core/layout/app_layout.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../appointments/domain/entities/consultation_type.dart';
import '../../../appointments/presentation/controllers/appointment_booking_controller.dart';
import '../../domain/entities/doctor.dart';
import '../controllers/doctor_detail_controller.dart';

class DoctorDetailScreen extends StatefulWidget {
  const DoctorDetailScreen({
    super.key,
    required this.doctorId,
    required this.doctorDetailController,
    required this.bookingController,
  });

  final String doctorId;
  final DoctorDetailController doctorDetailController;
  final AppointmentBookingController bookingController;

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.doctorDetailController.addListener(_refresh);
    widget.bookingController.addListener(_refresh);
    widget.doctorDetailController.loadDoctor(widget.doctorId);
  }

  @override
  void dispose() {
    widget.doctorDetailController.removeListener(_refresh);
    widget.bookingController.removeListener(_refresh);
    widget.doctorDetailController.dispose();
    widget.bookingController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _bookAppointment(Doctor doctor) async {
    final success = await widget.bookingController.book(
      doctorId: doctor.id,
      totalFee: doctor.consultationFee,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.danger,
          content: Text(
            widget.bookingController.errorMessage ?? 'Booking failed.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Appointment booked with ${doctor.name} at ${widget.bookingController.selectedTime}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.doctorDetailController;
    final doctor = controller.doctor;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxMobileContentWidth,
            ),
            child: Builder(
              builder: (context) {
                if (controller.isLoading && doctor == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage != null && doctor == null) {
                  return _ErrorState(
                    message: controller.errorMessage!,
                    onRetry: () => controller.loadDoctor(widget.doctorId),
                  );
                }

                if (doctor == null) {
                  return _ErrorState(
                    message: 'Doctor not found.',
                    onRetry: () => controller.loadDoctor(widget.doctorId),
                  );
                }

                return Stack(
                  children: [
                    ListView(
                      padding: EdgeInsets.fromLTRB(
                        AppLayout.horizontalPadding(context),
                        18,
                        AppLayout.horizontalPadding(context),
                        132,
                      ),
                      children: [
                        _TopBar(
                          isFavorite: controller.isFavorite,
                          onBackTap: () => Navigator.of(context).pop(),
                          onFavoriteTap: controller.toggleFavorite,
                          onShareTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Share option coming next.'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 22),
                        _DoctorProfileHeader(doctor: doctor),
                        const SizedBox(height: 22),
                        _StatsCard(doctor: doctor),
                        const SizedBox(height: 26),
                        _AboutSection(
                          doctor: doctor,
                          expanded: controller.isAboutExpanded,
                          onToggle: controller.toggleAboutExpanded,
                        ),
                        const SizedBox(height: 26),
                        _ConsultationTypeSection(
                          selectedType:
                              widget.bookingController.selectedConsultationType,
                          onSelected:
                              widget.bookingController.selectConsultationType,
                        ),
                        const SizedBox(height: 26),
                        _DateSelector(controller: widget.bookingController),
                        const SizedBox(height: 26),
                        _TimeSelector(controller: widget.bookingController),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _BookingBottomBar(
                        fee: doctor.consultationFee,
                        isBooking: widget.bookingController.isBooking,
                        onBookTap: () => _bookAppointment(doctor),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isFavorite,
    required this.onBackTap,
    required this.onFavoriteTap,
    required this.onShareTap,
  });

  final bool isFavorite;
  final VoidCallback onBackTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onShareTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconCircleButton(
          icon: Icons.arrow_back_rounded,
          onTap: onBackTap,
          plain: true,
        ),
        const Spacer(),
        _IconCircleButton(
          icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border,
          onTap: onFavoriteTap,
          plain: true,
          color: isFavorite ? AppTheme.danger : const Color(0xFF07132D),
        ),
        const SizedBox(width: 16),
        _IconCircleButton(
          icon: Icons.share_outlined,
          onTap: onShareTap,
          plain: true,
        ),
      ],
    );
  }
}

class _DoctorProfileHeader extends StatelessWidget {
  const _DoctorProfileHeader({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: AppLayout.isCompact(context) ? 46 : 54,
          backgroundColor: AppTheme.softTeal,
          backgroundImage: AssetImage(doctor.imageAsset),
        ),
        const SizedBox(width: 10),
        Expanded(
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
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.7,
                      ),
                    ),
                  ),
                  if (doctor.isVerified) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.verified_rounded,
                      color: AppTheme.primary,
                      size: 25,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                doctor.qualification,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF536078),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                doctor.specialty,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFB020),
                    size: 24,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    doctor.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Color(0xFF07132D),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '|',
                      style: TextStyle(color: Color(0xFFD4DAE1), fontSize: 18),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${_formatNumber(doctor.reviewCount)}+ Reviews',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF536078),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.softTeal,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.workspace_premium_outlined,
                        color: AppTheme.primary,
                        size: 17,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '${doctor.experienceYears}+ Years',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            blurRadius: 24,
            offset: Offset(0, 10),
            color: Color(0x0F000000),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatItem(
            label: 'Consultation Fee',
            value: 'Rs. ${doctor.consultationFee}',
          ),
          const _VerticalDivider(),
          _StatItem(
            label: 'Patients',
            value: '${_formatNumber(doctor.patientsCount)}+',
          ),
          const _VerticalDivider(),
          _StatItem(
            label: 'Experience',
            value: '${doctor.experienceYears}+ Years',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF536078),
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF07132D),
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 48, width: 1, color: AppTheme.border);
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({
    required this.doctor,
    required this.expanded,
    required this.onToggle,
  });

  final Doctor doctor;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'About Doctor',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            doctor.about,
            maxLines: expanded ? null : 3,
            overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF536078),
              fontSize: 17,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onToggle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  expanded ? 'Read less' : 'Read more',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.arrow_forward_ios_rounded,
                  color: AppTheme.primary,
                  size: expanded ? 22 : 15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsultationTypeSection extends StatelessWidget {
  const _ConsultationTypeSection({
    required this.selectedType,
    required this.onSelected,
  });

  final ConsultationType selectedType;
  final ValueChanged<ConsultationType> onSelected;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Consultation Type',
      child: Row(
        children: [
          Expanded(
            child: _ConsultationTypeCard(
              type: ConsultationType.video,
              selected: selectedType == ConsultationType.video,
              onTap: () => onSelected(ConsultationType.video),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ConsultationTypeCard(
              type: ConsultationType.audio,
              selected: selectedType == ConsultationType.audio,
              onTap: () => onSelected(ConsultationType.audio),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsultationTypeCard extends StatelessWidget {
  const _ConsultationTypeCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final ConsultationType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = type == ConsultationType.video
        ? Icons.videocam_outlined
        : Icons.call_outlined;

    return Material(
      color: selected ? AppTheme.softTeal : AppTheme.surface,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          constraints: const BoxConstraints(minHeight: 86),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? Colors.transparent : AppTheme.border,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: selected
                          ? AppTheme.primary
                          : const Color(0xFF07132D),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? AppTheme.primary
                                : const Color(0xFF07132D),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          type.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF536078),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (selected)
                const Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 13,
                    backgroundColor: AppTheme.primary,
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.controller});

  final AppointmentBookingController controller;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Select Date',
      child: SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.dateSlots.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final slot = controller.dateSlots[index];
            final selected = controller.selectedDateIndex == index;

            return _DateChip(
              day: slot.day,
              date: '${slot.date} ${slot.month}',
              selected: selected,
              onTap: () => controller.selectDate(index),
            );
          },
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.day,
    required this.date,
    required this.selected,
    required this.onTap,
  });

  final String day;
  final String date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? null : AppTheme.surface,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          width: 76,
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [AppTheme.primaryLight, AppTheme.primary],
                  )
                : null,
            color: selected ? null : AppTheme.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? Colors.transparent : AppTheme.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                day,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF536078),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                date,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF07132D),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  const _TimeSelector({required this.controller});

  final AppointmentBookingController controller;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Select Time',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(controller.timeSlots.length, (index) {
          final selected = controller.selectedTimeIndex == index;

          return _TimeChip(
            label: controller.timeSlots[index],
            selected: selected,
            onTap: () => controller.selectTime(index),
          );
        }),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? null : AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 86,
          height: 55,
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [AppTheme.primaryLight, AppTheme.primary],
                  )
                : null,
            color: selected ? null : AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? Colors.transparent : AppTheme.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF07132D),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingBottomBar extends StatelessWidget {
  const _BookingBottomBar({
    required this.fee,
    required this.isBooking,
    required this.onBookTap,
  });

  final int fee;
  final bool isBooking;
  final VoidCallback onBookTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      height: 86,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryLight, AppTheme.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 24,
            offset: Offset(0, 12),
            color: Color(0x220D5C63),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppLayout.isCompact(context) ? 92 : 112,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Fee',
                  style: TextStyle(
                    color: Color(0xE6FFFFFF),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'Rs. $fee',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppLayout.isCompact(context) ? 22 : 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 54,
            width: 1,
            color: Colors.white.withValues(alpha: 0.45),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: isBooking ? null : onBookTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.12),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: isBooking
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Book Appointment',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF07132D),
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFF07132D),
    this.plain = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final bool plain;

  @override
  Widget build(BuildContext context) {
    if (plain) {
      return GestureDetector(
        onTap: onTap,
        child: Icon(icon, color: color, size: 31),
      );
    }

    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppTheme.danger,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF07132D),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

String _formatNumber(int value) {
  if (value >= 1000) {
    final number = value / 1000;
    final text = number % 1 == 0
        ? number.toStringAsFixed(0)
        : number.toStringAsFixed(1);
    return '${text}k';
  }

  return value.toString();
}
