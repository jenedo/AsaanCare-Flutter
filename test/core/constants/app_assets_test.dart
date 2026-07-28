import 'dart:io';

import 'package:asaancare/core/constants/app_assets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('category asset constants reference files with exact paths', () {
    const categoryAssets = [
      AppAssets.generalDoctor,
      AppAssets.pediatrics,
      AppAssets.gynecology,
      AppAssets.dermatology,
      AppAssets.dentistry,
    ];

    for (final asset in categoryAssets) {
      expect(File(asset).existsSync(), isTrue, reason: 'Missing asset: $asset');
    }
  });
}
