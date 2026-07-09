import 'package:flutter/widgets.dart';

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minimumItemWidth = 150,
    this.minimumColumns = 1,
    this.maximumColumns = 4,
    this.spacing = 12,
    this.childAspectRatio = 1,
    this.physics = const NeverScrollableScrollPhysics(),
    this.shrinkWrap = true,
  }) : assert(minimumItemWidth > 0),
       assert(minimumColumns > 0),
       assert(maximumColumns >= minimumColumns),
       assert(spacing >= 0),
       assert(childAspectRatio > 0);

  final List<Widget> children;
  final double minimumItemWidth;
  final int minimumColumns;
  final int maximumColumns;
  final double spacing;
  final double childAspectRatio;
  final ScrollPhysics physics;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : minimumItemWidth;

        final calculatedColumns =
            ((availableWidth + spacing) / (minimumItemWidth + spacing)).floor();

        final columns = calculatedColumns.clamp(minimumColumns, maximumColumns);

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: shrinkWrap,
          physics: physics,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
          children: children,
        );
      },
    );
  }
}
