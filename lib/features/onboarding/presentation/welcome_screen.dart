import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/layout/app_layout.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();

  int _currentIndex = 0;

  bool get _isLastPage => _currentIndex == 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLastPage) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.register);
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _goLogin() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            children: [
              _SplashPage(currentIndex: _currentIndex),
              _OnboardingContentPage(
                currentIndex: _currentIndex,
                title: 'Book appointments\nwith ease',
                subtitle:
                    'Choose verified specialists, pick your preferred time, and consult from anywhere.',
                visualType: _VisualType.appointment,
                features: const [
                  _FeatureItem(
                    icon: Icons.calendar_month_outlined,
                    title: 'Easy Appointment Booking',
                    subtitle: 'Find the right doctor in minutes',
                  ),
                  _FeatureItem(
                    icon: Icons.videocam_outlined,
                    title: 'Video & Audio Consult',
                    subtitle: 'Talk to doctors from anywhere',
                  ),
                  _FeatureItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Verified Specialists',
                    subtitle: 'Trusted and experienced care',
                  ),
                ],
                primaryButtonText: 'Next',
                showLoginButton: false,
                onPrimaryTap: _next,
                onLoginTap: _goLogin,
              ),
              _OnboardingContentPage(
                currentIndex: _currentIndex,
                title: 'Medicines and\nrecords in one place',
                subtitle:
                    'Order genuine medicines, upload prescriptions, and access your reports anytime.',
                visualType: _VisualType.medicine,
                features: const [
                  _FeatureItem(
                    icon: Icons.local_shipping_outlined,
                    title: 'Medicine Delivery',
                    subtitle: 'Get genuine medicines at your doorstep',
                  ),
                  _FeatureItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Upload Prescription',
                    subtitle: 'Send your doctor prescription easily',
                  ),
                  _FeatureItem(
                    icon: Icons.folder_shared_outlined,
                    title: 'Health Records',
                    subtitle: 'Keep all reports in one secure place',
                  ),
                ],
                primaryButtonText: 'Next',
                showLoginButton: false,
                onPrimaryTap: _next,
                onLoginTap: _goLogin,
              ),
              _OnboardingContentPage(
                currentIndex: _currentIndex,
                title: 'Ready to take\ncontrol of your\nhealth?',
                subtitle:
                    'Consult doctors, order medicines, and manage your care with AsaanCare — all in one secure app.',
                visualType: _VisualType.control,
                features: const [
                  _FeatureItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Trusted Care',
                    subtitle: 'Verified doctors and secure support',
                  ),
                  _FeatureItem(
                    icon: Icons.grid_view_rounded,
                    title: 'All-in-One Access',
                    subtitle: 'Consult, pharmacy, and records together',
                  ),
                  _FeatureItem(
                    icon: Icons.groups_2_outlined,
                    title: 'Made for You',
                    subtitle: 'Simple, fast, and easy to use',
                  ),
                ],
                primaryButtonText: 'Get Started',
                showLoginButton: true,
                onPrimaryTap: _next,
                onLoginTap: _goLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            AppAssets.splashLahoreBg,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryDark.withValues(alpha: 0.96),
                  AppTheme.primary.withValues(alpha: 0.72),
                  AppTheme.primaryDark.withValues(alpha: 0.96),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              final veryCompactHeight = height < 420;
              final logoHeight = veryCompactHeight
                  ? 80.0
                  : height < 720
                  ? 130.0
                  : 165.0;

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  AppLayout.horizontalPaddingForWidth(constraints.maxWidth),
                  veryCompactHeight ? 14 : 34,
                  AppLayout.horizontalPaddingForWidth(constraints.maxWidth),
                  veryCompactHeight ? 14 : 28,
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 4),
                    Image.asset(
                      AppAssets.logo,
                      height: logoHeight,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                      fit: BoxFit.contain,
                    ),
                    const Spacer(flex: 5),
                    Text(
                      'Your health. Our priority.\nAlways here for you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: veryCompactHeight ? 16 : 21,
                        height: 1.35,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: veryCompactHeight ? 10 : 28),
                    _DotsIndicator(
                      count: 4,
                      currentIndex: currentIndex,
                      lightMode: true,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OnboardingContentPage extends StatelessWidget {
  const _OnboardingContentPage({
    required this.currentIndex,
    required this.title,
    required this.subtitle,
    required this.visualType,
    required this.features,
    required this.primaryButtonText,
    required this.showLoginButton,
    required this.onPrimaryTap,
    required this.onLoginTap,
  });

  final int currentIndex;
  final String title;
  final String subtitle;
  final _VisualType visualType;
  final List<_FeatureItem> features;
  final String primaryButtonText;
  final bool showLoginButton;
  final VoidCallback onPrimaryTap;
  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxHeight < 760 || constraints.maxWidth < 360;
          final veryNarrow = constraints.maxWidth < 320;
          final horizontalPadding = AppLayout.horizontalPaddingForWidth(
            constraints.maxWidth,
          );
          final topPadding = compact ? 18.0 : 32.0;
          const bottomPadding = 22.0;
          final minimumContentHeight =
              constraints.maxHeight > topPadding + bottomPadding
              ? constraints.maxHeight - topPadding - bottomPadding
              : 0.0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              topPadding,
              horizontalPadding,
              bottomPadding,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minimumContentHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF07132D),
                      fontSize: veryNarrow
                          ? 28
                          : compact
                          ? 33
                          : 38,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.1,
                    ),
                  ),
                  SizedBox(height: compact ? 14 : 20),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: const Color(0xFF33415C),
                      fontSize: veryNarrow
                          ? 15
                          : compact
                          ? 17
                          : 20,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: compact ? 10 : 18),
                  _HeroVisual(type: visualType, compact: compact),
                  SizedBox(height: compact ? 8 : 12),
                  _FeaturePanel(features: features, compact: compact),
                  SizedBox(height: compact ? 16 : 24),
                  _PrimaryOnboardingButton(
                    text: primaryButtonText,
                    onTap: onPrimaryTap,
                    compact: compact,
                  ),
                  if (showLoginButton) ...[
                    const SizedBox(height: 13),
                    _SecondaryLoginButton(onTap: onLoginTap),
                  ],
                  const SizedBox(height: 18),
                  Center(
                    child: _DotsIndicator(
                      count: 4,
                      currentIndex: currentIndex,
                      lightMode: false,
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

class _HeroVisual extends StatelessWidget {
  const _HeroVisual({required this.type, required this.compact});

  final _VisualType type;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 245.0 : 310.0;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: switch (type) {
          _VisualType.appointment => _appointmentLayers(height),
          _VisualType.medicine => _medicineLayers(height),
          _VisualType.control => _controlLayers(height),
        },
      ),
    );
  }

  List<Widget> _appointmentLayers(double height) {
    return [
      Positioned(
        right: -12,
        top: height * 0.06,
        child: _SoftBlob(size: height * 0.86),
      ),
      Positioned(
        right: 8,
        bottom: 0,
        child: Image.asset(
          AppAssets.doctorAppointment,
          height: height * 0.9,
          fit: BoxFit.contain,
        ),
      ),
      Positioned(
        left: 2,
        bottom: height * 0.12,
        child: Image.asset(
          AppAssets.calendarBookingCard,
          width: height * 0.56,
          fit: BoxFit.contain,
        ),
      ),
      Positioned(
        left: 2,
        top: height * 0.12,
        child: const _FloatingIcon(icon: Icons.videocam_outlined),
      ),
      Positioned(
        right: 12,
        top: height * 0.08,
        child: const _FloatingIcon(icon: Icons.verified_user_outlined),
      ),
    ];
  }

  List<Widget> _medicineLayers(double height) {
    return [
      Positioned(
        right: -10,
        top: height * 0.04,
        child: _SoftBlob(size: height * 0.86),
      ),
      Positioned(
        right: 4,
        bottom: 0,
        child: Image.asset(
          AppAssets.medicineRecords,
          height: height * 0.94,
          fit: BoxFit.contain,
        ),
      ),
      Positioned(
        left: 4,
        top: height * 0.16,
        child: const _FloatingIcon(icon: Icons.receipt_long_outlined),
      ),
      Positioned(
        left: 0,
        bottom: height * 0.08,
        child: const _FloatingIcon(icon: Icons.medical_services_outlined),
      ),
      Positioned(
        right: 10,
        top: height * 0.08,
        child: const _FloatingIcon(icon: Icons.local_shipping_outlined),
      ),
    ];
  }

  List<Widget> _controlLayers(double height) {
    return [
      Positioned(
        right: -12,
        top: height * 0.02,
        child: _SoftBlob(size: height * 0.9),
      ),
      Positioned(
        right: -4,
        bottom: 0,
        child: Image.asset(
          AppAssets.patientPhone,
          height: height * 0.86,
          fit: BoxFit.contain,
        ),
      ),
      Positioned(
        right: 2,
        top: height * 0.02,
        child: Image.asset(
          AppAssets.doctorSupportCircle,
          height: height * 0.34,
          fit: BoxFit.contain,
        ),
      ),
      Positioned(
        left: 6,
        top: height * 0.25,
        child: const _FloatingIcon(icon: Icons.favorite_border_outlined),
      ),
      Positioned(
        left: 64,
        bottom: height * 0.08,
        child: const _FloatingIcon(icon: Icons.phone_iphone_outlined),
      ),
    ];
  }
}

class _SoftBlob extends StatelessWidget {
  const _SoftBlob({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE3F5F2),
        borderRadius: BorderRadius.circular(size * 0.48),
      ),
    );
  }
}

class _FeaturePanel extends StatelessWidget {
  const _FeaturePanel({required this.features, required this.compact});

  final List<_FeatureItem> features;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 20,
        vertical: compact ? 14 : 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int index = 0; index < features.length; index++) ...[
            _FeatureRow(item: features[index], compact: compact),
            if (index != features.length - 1)
              Padding(
                padding: EdgeInsets.symmetric(vertical: compact ? 11 : 15),
                child: const Divider(height: 1, color: Color(0xFFE8EEF0)),
              ),
          ],
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.item, required this.compact});

  final _FeatureItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackVertically = constraints.maxWidth < 220;
        final iconSize = stackVertically
            ? 42.0
            : compact
            ? 50.0
            : 58.0;

        final icon = Container(
          height: iconSize,
          width: iconSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryLight, AppTheme.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(stackVertically ? 14 : 18),
          ),
          child: Icon(
            item.icon,
            color: Colors.white,
            size: stackVertically
                ? 22
                : compact
                ? 26
                : 30,
          ),
        );

        final text = Column(
          crossAxisAlignment: stackVertically
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              textAlign: stackVertically ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                color: const Color(0xFF07132D),
                fontSize: stackVertically
                    ? 14
                    : compact
                    ? 16
                    : 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.subtitle,
              textAlign: stackVertically ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                color: const Color(0xFF3E4A63),
                fontSize: stackVertically
                    ? 12
                    : compact
                    ? 13
                    : 15,
                height: 1.25,
              ),
            ),
          ],
        );

        if (stackVertically) {
          return Column(children: [icon, const SizedBox(height: 9), text]);
        }

        return Row(
          children: [
            icon,
            SizedBox(width: compact ? 15 : 20),
            Expanded(child: text),
          ],
        );
      },
    );
  }
}

class _PrimaryOnboardingButton extends StatelessWidget {
  const _PrimaryOnboardingButton({
    required this.text,
    required this.onTap,
    required this.compact,
  });

  final String text;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: compact ? 56 : 62,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryLight, AppTheme.primary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showArrow = constraints.maxWidth >= 150;
              final textPadding = showArrow ? 52.0 : 8.0;

              return Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: textPadding),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        text,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 19 : 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  if (showArrow)
                    const Positioned(
                      right: 16,
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 23,
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

class _SecondaryLoginButton extends StatelessWidget {
  const _SecondaryLoginButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 56),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        side: const BorderSide(color: AppTheme.primary, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'Login',
          maxLines: 1,
          style: TextStyle(
            color: AppTheme.primary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.currentIndex,
    required this.lightMode,
  });

  final int count;
  final int currentIndex;
  final bool lightMode;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (index) {
          final isActive = index == currentIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            height: 10,
            width: isActive ? 25 : 10,
            decoration: BoxDecoration(
              color: isActive
                  ? (lightMode ? Colors.white : AppTheme.primary)
                  : (lightMode
                        ? Colors.white.withValues(alpha: 0.35)
                        : const Color(0xFFD6E1E4)),
              borderRadius: BorderRadius.circular(99),
            ),
          );
        }),
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  const _FloatingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: AppTheme.primaryLight, size: 27),
    );
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

enum _VisualType { appointment, medicine, control }
