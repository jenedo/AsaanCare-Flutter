import 'package:flutter/animation.dart';

abstract final class AppMotion {
  static const Duration press = Duration(milliseconds: 110);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 240);
  static const Duration route = Duration(milliseconds: 300);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;

  const AppMotion._();
}
