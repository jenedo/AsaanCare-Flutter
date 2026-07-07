import 'package:flutter/foundation.dart';

class PlatformInfo {
  const PlatformInfo._();

  static bool get isWeb => kIsWeb;

  static bool get isMobileRuntime => !kIsWeb;

  static String get currentRuntime {
    if (kIsWeb) {
      return 'web';
    }

    return defaultTargetPlatform.name;
  }
}
