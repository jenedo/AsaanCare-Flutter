import 'package:flutter/material.dart';

import '../../../../core/layout/app_layout.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../domain/entities/doctor.dart';
import '../controllers/find_doctors_controller.dart';

class FindDoctorsScreen extends StatefulWidget {
  const FindDoctorsScreen({super.key, required this.controller});

  final FindDoctorsController controller;

  @override
  State<FindDoctorsScreen> createState() => _FindDoctorsScreenState();
}

class _FindDoctorsScreenState extends State<FindDoctorsScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  void _openRoute(String route) {
    Navigator.of(context).pushReplacementNamed(route);
  }

  void _handleNavTap(int index) {
    switch (index) {
      case 0:
        _openRoute(AppRoutes.patientHome);
        return;
      case 1:
        return;
      case 2:
        _openRoute(AppRoutes.pharmacy);
        return;
      case 3:
        _openRoute(AppRoutes.medicalRecords);
        return;
      case 4:
        _openRoute(AppRoutes.wallet);
        return;
    }
  }

  Future<void> _showFilters() async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 18),
          children: [
            const ListTile(
              title: Text(
                'Filter by specialty',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
            ListTile(
              title: const Text('All specialties'),
              trailing: widget.controller.specialty == null
                  ? const Icon(Icons.check_rounded, color: AppTheme.primary)
                  : null,
              onTap: () => Navigator.pop(context, ''),
            ),
            ...widget.controller.specialties.map(
              (specialty) => ListTile(
                title: Text(specialty),
                trailing: widget.controller.specialty == specialty
                    ? const Icon(Icons.check_rounded, color: AppTheme.primary)
                    : null,
                onTap: () => Navigator.pop(context, specialty),
              ),
            ),
          ],
        ),
      ),
    );

    if (!mounted || selected == null) return;
    widget.controller.setSpecialty(selected.isEmpty ? null : selected);
  }

  Future<void> _showSort() async {
    final selected = await showModalBottomSheet<DoctorSort>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: DoctorSort.values
              .map(
                (sort) => RadioListTile<DoctorSort>(
                  value: sort,
                  groupValue: widget.controller.sort,
                  title: Text(_sortLabel(sort)),
                  onChanged: (value) => Navigator.pop(context, value),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (!mounted || selected == null) return;
    widget.controller.setSort(selected);
  }

  String _sortLabel(DoctorSort sort) => switch (sort) {
    DoctorSort.recommended => 'Recommended',
    DoctorSort.ratingHigh => 'Highest rated',
    DoctorSort.feeLow => 'Lowest fee',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: _handleNavTap,
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxMobileContentWidth,
            ),
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                final doctors = widget.controller.visibleDoctors;
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppLayout.horizontalPadding(context),
                          12,
                          AppLayout.horizontalPadding(context),
                          18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Header(onBack: () => Navigator.maybePop(context)),
                            const SizedBox(height: 22),
                            _DoctorSearchField(
                              onChanged: widget.controller.setQuery,
                            ),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${doctors.length} Doctors found',
                                    style: const TextStyle(
                                      color: Color(0xFF14151A),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                _RoundAction(
                                  icon: Icons.swap_vert_rounded,
                                  label: 'Sort doctors',
                                  onTap: _showSort,
                                ),
                                const SizedBox(width: 10),
                                _RoundAction(
                                  icon: Icons.tune_rounded,
                                  label: 'Filter doctors',
                                  active: widget.controller.specialty != null,
                                  onTap: _showFilters,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.controller.isLoading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (widget.controller.errorMessage != null)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _MessageState(
                          icon: Icons.cloud_off_rounded,
                          message: widget.controller.errorMessage!,
                          action: widget.controller.load,
                        ),
                      )
                    else if (doctors.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _MessageState(
                          icon: Icons.search_off_rounded,
                          message: 'No doctors match your search.',
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          AppLayout.horizontalPadding(context),
                          0,
                          AppLayout.horizontalPadding(context),
                          28,
                        ),
                        sliver: SliverList.separated(
                          itemCount: doctors.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) => _DoctorBookingCard(
                            doctor: doctors[index],
                            dark: index % 4 == 1,
                            onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.doctorDetail,
                              arguments: doctors[index].id,
                            ),
                          ),
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

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: IconButton(
            onPressed: onBack,
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Find Doctor',
          style: TextStyle(
            color: Color(0xFF111217),
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _DoctorSearchField extends StatelessWidget {
  const _DoctorSearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search doctor or specialty',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
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
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
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
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: active ? AppTheme.softTeal : Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 42,
            width: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE3E4E7)),
            ),
            child: Icon(icon, color: const Color(0xFF15161B), size: 21),
          ),
        ),
      ),
    );
  }
}

class _DoctorBookingCard extends StatefulWidget {
  const _DoctorBookingCard({
    required this.doctor,
    required this.dark,
    required this.onTap,
  });

  final Doctor doctor;
  final bool dark;
  final VoidCallback onTap;

  @override
  State<_DoctorBookingCard> createState() => _DoctorBookingCardState();
}

class _DoctorBookingCardState extends State<_DoctorBookingCard> {
  int _selectedDay = 2;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _dates = ['12', '13', '14', '15', '16', '17'];

  @override
  Widget build(BuildContext context) {
    final foreground = widget.dark ? Colors.white : const Color(0xFF15161B);
    final muted = widget.dark
        ? const Color(0xFFBDB9B8)
        : const Color(0xFF777B84);
    final cardColor = widget.dark ? const Color(0xFF24201F) : Colors.white;
    final slotCount = 4 + (widget.doctor.id.hashCode.abs() % 5);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Pill(
                    icon: Icons.star_rounded,
                    text: widget.doctor.rating.toStringAsFixed(1),
                    iconColor: const Color(0xFFFFC83D),
                  ),
                  const SizedBox(width: 7),
                  _Pill(
                    icon: Icons.payments_outlined,
                    text: 'Rs. ${widget.doctor.consultationFee}',
                    iconColor: const Color(0xFF66C56C),
                  ),
                  if (widget.doctor.isVerified) ...[
                    const Spacer(),
                    const Icon(
                      Icons.verified_rounded,
                      color: AppTheme.primary,
                      size: 21,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 92,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.doctor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: foreground,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.doctor.specialty,
                            style: TextStyle(
                              color: muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$slotCount Slots Available',
                            style: TextStyle(
                              color: foreground,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 112,
                      child: Image.asset(
                        widget.doctor.imageAsset,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.person_rounded, size: 76, color: muted),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(_days.length, (index) {
                  final selected = _selectedDay == index;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == _days.length - 1 ? 0 : 6,
                      ),
                      child: InkWell(
                        onTap: () => setState(() => _selectedDay = index),
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 61,
                          decoration: BoxDecoration(
                            color: selected
                                ? (widget.dark
                                      ? Colors.white
                                      : const Color(0xFF24201F))
                                : (widget.dark
                                      ? const Color(0xFFF5F5F5)
                                      : const Color(0xFFF6F6F7)),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _days[index],
                                style: TextStyle(
                                  color: selected
                                      ? (widget.dark
                                            ? const Color(0xFF24201F)
                                            : Colors.white)
                                      : const Color(0xFF757982),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _dates[index],
                                style: TextStyle(
                                  color: selected
                                      ? (widget.dark
                                            ? const Color(0xFF24201F)
                                            : Colors.white)
                                      : const Color(0xFF202126),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.text,
    required this.iconColor,
  });

  final IconData icon;
  final String text;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F2),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF202126),
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return Center(
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
}
