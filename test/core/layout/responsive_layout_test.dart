import 'package:asaancare/core/layout/app_layout.dart';
import 'package:asaancare/core/widgets/responsive_grid.dart';
import 'package:asaancare/core/widgets/responsive_split.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLayout', () {
    test('classifies supported screen widths', () {
      expect(AppLayout.breakpointForWidth(320), AppBreakpoint.compactPhone);
      expect(AppLayout.breakpointForWidth(390), AppBreakpoint.phone);
      expect(AppLayout.breakpointForWidth(700), AppBreakpoint.tablet);
      expect(AppLayout.breakpointForWidth(1024), AppBreakpoint.desktop);
      expect(AppLayout.breakpointForWidth(1440), AppBreakpoint.wideDesktop);
    });

    test('uses progressively larger page padding', () {
      expect(AppLayout.horizontalPaddingForWidth(280), 12);
      expect(AppLayout.horizontalPaddingForWidth(340), 16);
      expect(AppLayout.horizontalPaddingForWidth(390), 20);
      expect(AppLayout.horizontalPaddingForWidth(700), 28);
      expect(AppLayout.horizontalPaddingForWidth(1024), 36);
      expect(AppLayout.horizontalPaddingForWidth(1440), 48);
    });

    test('returns suitable content width for device class', () {
      expect(AppLayout.contentMaxWidthForWidth(390), 460);
      expect(AppLayout.contentMaxWidthForWidth(700), 760);
      expect(AppLayout.contentMaxWidthForWidth(1200), 1180);
    });
  });

  testWidgets('ResponsiveGrid adapts its column count', (tester) async {
    Future<int> pumpGrid(double width) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: width,
              child: ResponsiveGrid(
                minimumItemWidth: 140,
                maximumColumns: 4,
                children: List.generate(
                  4,
                  (index) => SizedBox(key: ValueKey(index)),
                ),
              ),
            ),
          ),
        ),
      );

      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      return delegate.crossAxisCount;
    }

    expect(await pumpGrid(320), 2);
    expect(await pumpGrid(700), 4);
  });

  testWidgets('ResponsiveSplit switches between column and row', (
    tester,
  ) async {
    Future<void> pumpSplit(double width) {
      return tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: width,
              child: ResponsiveSplit(
                key: const Key('responsive-split'),
                first: const SizedBox(height: 40),
                second: const SizedBox(height: 40),
              ),
            ),
          ),
        ),
      );
    }

    await pumpSplit(500);

    expect(
      find.descendant(
        of: find.byKey(const Key('responsive-split')),
        matching: find.byType(Column),
      ),
      findsOneWidget,
    );

    await pumpSplit(900);

    expect(
      find.descendant(
        of: find.byKey(const Key('responsive-split')),
        matching: find.byType(Row),
      ),
      findsOneWidget,
    );
  });
}
