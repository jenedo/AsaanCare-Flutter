import 'package:flutter/widgets.dart';

enum AppBreakpoint { compactPhone, phone, tablet, desktop, wideDesktop }

abstract final class AppLayout {
  static const double compactPhoneBreakpoint = 360;
  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 900;
  static const double wideDesktopBreakpoint = 1200;

  static const double maxMobileContentWidth = 460;
  static const double maxFormContentWidth = 560;
  static const double maxTabletContentWidth = 760;
  static const double maxDetailContentWidth = 900;
  static const double maxDashboardContentWidth = 1180;

  static AppBreakpoint breakpointForWidth(double width) {
    if (width < compactPhoneBreakpoint) {
      return AppBreakpoint.compactPhone;
    }

    if (width < tabletBreakpoint) {
      return AppBreakpoint.phone;
    }

    if (width < desktopBreakpoint) {
      return AppBreakpoint.tablet;
    }

    if (width < wideDesktopBreakpoint) {
      return AppBreakpoint.desktop;
    }

    return AppBreakpoint.wideDesktop;
  }

  static AppBreakpoint breakpoint(BuildContext context) {
    return breakpointForWidth(MediaQuery.sizeOf(context).width);
  }

  static bool isCompact(BuildContext context) {
    return breakpoint(context) == AppBreakpoint.compactPhone;
  }

  static bool isPhone(BuildContext context) {
    final current = breakpoint(context);

    return current == AppBreakpoint.compactPhone ||
        current == AppBreakpoint.phone;
  }

  static bool isTablet(BuildContext context) {
    return breakpoint(context) == AppBreakpoint.tablet;
  }

  static bool isDesktop(BuildContext context) {
    final current = breakpoint(context);

    return current == AppBreakpoint.desktop ||
        current == AppBreakpoint.wideDesktop;
  }

  static bool isWideDesktop(BuildContext context) {
    return breakpoint(context) == AppBreakpoint.wideDesktop;
  }

  static double horizontalPaddingForWidth(double width) {
    if (width < 320) return 12;
    if (width < compactPhoneBreakpoint) return 16;
    if (width < tabletBreakpoint) return 20;
    if (width < desktopBreakpoint) return 28;
    if (width < wideDesktopBreakpoint) return 36;
    return 48;
  }

  static double horizontalPadding(BuildContext context) {
    return horizontalPaddingForWidth(MediaQuery.sizeOf(context).width);
  }

  static double spacingForWidth(double width) {
    if (width < compactPhoneBreakpoint) return 10;
    if (width < tabletBreakpoint) return 12;
    if (width < desktopBreakpoint) return 16;
    return 20;
  }

  static double spacing(BuildContext context) {
    return spacingForWidth(MediaQuery.sizeOf(context).width);
  }

  static double contentMaxWidthForWidth(
    double width, {
    double phone = maxMobileContentWidth,
    double tablet = maxTabletContentWidth,
    double desktop = maxDashboardContentWidth,
  }) {
    return switch (breakpointForWidth(width)) {
      AppBreakpoint.compactPhone || AppBreakpoint.phone => phone,
      AppBreakpoint.tablet => tablet,
      AppBreakpoint.desktop || AppBreakpoint.wideDesktop => desktop,
    };
  }

  static double contentMaxWidth(
    BuildContext context, {
    double phone = maxMobileContentWidth,
    double tablet = maxTabletContentWidth,
    double desktop = maxDashboardContentWidth,
  }) {
    return contentMaxWidthForWidth(
      MediaQuery.sizeOf(context).width,
      phone: phone,
      tablet: tablet,
      desktop: desktop,
    );
  }

  static int gridColumnsForWidth(
    double width, {
    int compactPhone = 2,
    int phone = 2,
    int tablet = 3,
    int desktop = 4,
    int wideDesktop = 5,
  }) {
    return switch (breakpointForWidth(width)) {
      AppBreakpoint.compactPhone => compactPhone,
      AppBreakpoint.phone => phone,
      AppBreakpoint.tablet => tablet,
      AppBreakpoint.desktop => desktop,
      AppBreakpoint.wideDesktop => wideDesktop,
    };
  }

  static int gridColumns(
    BuildContext context, {
    int compactPhone = 2,
    int phone = 2,
    int tablet = 3,
    int desktop = 4,
    int wideDesktop = 5,
  }) {
    return gridColumnsForWidth(
      MediaQuery.sizeOf(context).width,
      compactPhone: compactPhone,
      phone: phone,
      tablet: tablet,
      desktop: desktop,
      wideDesktop: wideDesktop,
    );
  }

  static EdgeInsets pagePadding(
    BuildContext context, {
    double top = 16,
    double bottom = 24,
  }) {
    final horizontal = horizontalPadding(context);

    return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
  }

  const AppLayout._();
}
