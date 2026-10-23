import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class DashedBox extends StatelessWidget {
  const DashedBox({
    required this.child,
    this.height = 200,
    this.radius = 16,
    this.backgroundColor,
    this.borderColor,
    this.strokeWidth = 1.5,
    this.dashLength = 6,
    this.gapLength = 5,
    super.key,
  });

  final Widget child;
  final double height;
  final double radius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          radius: radius,
          backgroundColor:
              backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
          borderColor: borderColor ?? theme.dividerColor,
          strokeWidth: strokeWidth,
          dashLength: dashLength,
          gapLength: gapLength,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.radius,
    required this.backgroundColor,
    required this.borderColor,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  final double radius;
  final Color backgroundColor;
  final Color borderColor;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    canvas.drawRRect(rrect, Paint()..color = backgroundColor);

    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return radius != oldDelegate.radius ||
        backgroundColor != oldDelegate.backgroundColor ||
        borderColor != oldDelegate.borderColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashLength != oldDelegate.dashLength ||
        gapLength != oldDelegate.gapLength;
  }
}
