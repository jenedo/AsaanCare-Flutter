import 'package:flutter/widgets.dart';

class ResponsiveSplit extends StatelessWidget {
  const ResponsiveSplit({
    super.key,
    required this.first,
    required this.second,
    this.breakpoint = 720,
    this.spacing = 20,
    this.firstFlex = 1,
    this.secondFlex = 1,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  }) : assert(breakpoint > 0),
       assert(spacing >= 0),
       assert(firstFlex > 0),
       assert(secondFlex > 0);

  final Widget first;
  final Widget second;
  final double breakpoint;
  final double spacing;
  final int firstFlex;
  final int secondFlex;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              first,
              SizedBox(height: spacing),
              second,
            ],
          );
        }

        return Row(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Expanded(flex: firstFlex, child: first),
            SizedBox(width: spacing),
            Expanded(flex: secondFlex, child: second),
          ],
        );
      },
    );
  }
}
