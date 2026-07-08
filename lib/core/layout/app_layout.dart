import 'package:flutter/widgets.dart';

abstract final class AppLayout {
  static const double maxMobileContentWidth = 460;

  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 360;
  }

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 360) return 16;
    if (width < 430) return 20;
    return 24;
  }

  const AppLayout._();
}
