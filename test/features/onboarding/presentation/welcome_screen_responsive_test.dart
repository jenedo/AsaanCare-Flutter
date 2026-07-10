import 'package:asaancare/features/onboarding/presentation/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sizes = <Size>[
    const Size(280, 640),
    const Size(320, 568),
    const Size(360, 640),
    const Size(430, 800),
    const Size(568, 280),
  ];

  for (final size in sizes) {
    testWidgets('WelcomeScreen avoids layout exceptions at '
        '${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;

      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      for (var page = 1; page < 4; page++) {
        await tester.fling(
          find.byType(PageView),
          Offset(-size.width * 0.8, 0),
          1200,
        );
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason:
              'Page $page failed at '
              '${size.width.toInt()}x${size.height.toInt()}',
        );
      }
    });
  }
}
