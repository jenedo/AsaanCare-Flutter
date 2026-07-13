import 'package:flutter/material.dart';

import '../../../../core/layout/app_layout.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../controllers/find_doctors_controller.dart';
import '../widgets/find_doctors_widgets.dart';

class FindDoctorsScreen extends StatefulWidget {
  const FindDoctorsScreen({super.key, required this.controller});

  final FindDoctorsController controller;

  @override
  State<FindDoctorsScreen> createState() => _FindDoctorsScreenState();
}

class _FindDoctorsScreenState extends State<FindDoctorsScreen> {
  String _location = 'Karachi';

  @override
  void initState() {
    super.initState();
    widget.controller.load();

    // Apply pre-selected specialty from route arguments (e.g. from Categories)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && args.isNotEmpty) {
        widget.controller.setSpecialty(args);
      }
    });
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

  Future<void> _showLocation() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              title: Text(
                'Choose your city',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              subtitle: Text('Showing doctors available in your area'),
            ),
            for (final city in const ['Karachi', 'Lahore', 'Islamabad'])
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text(city),
                trailing: _location == city
                    ? const Icon(Icons.check_rounded, color: AppTheme.primary)
                    : null,
                onTap: () => Navigator.pop(context, city),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (!mounted || selected == null) return;
    setState(() => _location = selected);
  }

  Future<void> _showFilters() async {
    final selected = await showModalBottomSheet<(String?, DoctorSort)>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 18),
          children: [
            const ListTile(
              title: Text(
                'Filter doctors',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              subtitle: Text('Choose a specialty or change the result order'),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Text(
                'SPECIALTY',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
            ListTile(
              title: const Text('All specialties'),
              trailing: widget.controller.specialty == null
                  ? const Icon(Icons.check_rounded, color: AppTheme.primary)
                  : null,
              onTap: () =>
                  Navigator.pop(context, (null, widget.controller.sort)),
            ),
            ...widget.controller.specialties.map(
              (specialty) => ListTile(
                title: Text(specialty),
                trailing: widget.controller.specialty == specialty
                    ? const Icon(Icons.check_rounded, color: AppTheme.primary)
                    : null,
                onTap: () =>
                    Navigator.pop(context, (specialty, widget.controller.sort)),
              ),
            ),
            const Divider(height: 24),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Text(
                'SORT BY',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
            for (final sort in DoctorSort.values)
              ListTile(
                title: Text(_sortLabel(sort)),
                trailing: widget.controller.sort == sort
                    ? const Icon(Icons.check_rounded, color: AppTheme.primary)
                    : null,
                onTap: () =>
                    Navigator.pop(context, (widget.controller.specialty, sort)),
              ),
          ],
        ),
      ),
    );

    if (!mounted || selected == null) return;
    widget.controller
      ..setSpecialty(selected.$1)
      ..setSort(selected.$2);
  }

  String _sortLabel(DoctorSort sort) => switch (sort) {
    DoctorSort.recommended => 'Recommended',
    DoctorSort.ratingHigh => 'Highest rated',
    DoctorSort.feeLow => 'Lowest fee',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
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
                            FindDoctorsHeader(
                              onBack: () => Navigator.maybePop(context),
                            ),
                            const SizedBox(height: 24),
                            DoctorSearchField(
                              onChanged: widget.controller.setQuery,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${doctors.length} ${doctors.length == 1 ? 'Doctor' : 'Doctors'} found',
                                    style: const TextStyle(
                                      color: AppTheme.textDark,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                ),
                                FindDoctorsRoundAction(
                                  icon: Icons.location_on_outlined,
                                  label: 'Location: $_location',
                                  onTap: _showLocation,
                                ),
                                const SizedBox(width: 10),
                                FindDoctorsRoundAction(
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
                        child: FindDoctorsMessageState(
                          icon: Icons.cloud_off_rounded,
                          message: widget.controller.errorMessage!,
                          action: widget.controller.load,
                        ),
                      )
                    else if (doctors.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: FindDoctorsMessageState(
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
                          itemBuilder: (context, index) => DoctorBookingCard(
                            doctor: doctors[index],
                            bookingDates: widget.controller.bookingDates,
                            dark: index.isOdd,
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
