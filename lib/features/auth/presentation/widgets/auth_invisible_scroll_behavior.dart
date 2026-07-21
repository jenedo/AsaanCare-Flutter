import 'package:flutter/material.dart';

/// Scroll behavior that keeps scrolling available (ClampingScrollPhysics)
/// but hides the scrollbar and removes the overscroll glow/bounce so short
/// forms still look static when content already fits the viewport.
class AuthInvisibleScrollBehavior extends ScrollBehavior {
  const AuthInvisibleScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}
