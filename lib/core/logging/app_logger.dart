import 'package:flutter/foundation.dart';

abstract final class AppLogger {
  const AppLogger._();

  static void info(String scope, String message) {
    if (!kDebugMode) return;
    debugPrint('[$scope] $message');
  }

  static void error(String scope, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;

    debugPrint('[$scope] $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
