import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/geo_utils.dart';

class CompassNeedle extends StatelessWidget {
  const CompassNeedle({
    super.key,
    required this.relativeBearingDeg,
    required this.distanceMeters,
  });

  final double relativeBearingDeg;
  final double distanceMeters;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AspectRatio(
        aspectRatio: 1,
        child: CustomPaint(
          painter: _CompassPainter(
            angleRad: relativeBearingDeg * math.pi / 180,
            needleColor: scheme.primary,
            ringColor: scheme.outline.withValues(alpha: 0.35),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  GeoUtils.formatDistance(distanceMeters),
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
                Text('to your car', style: textTheme.bodyMedium),
                Text(
                  '≈ ${GeoUtils.walkingMinutes(distanceMeters)} min walk',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({
    required this.angleRad,
    required this.needleColor,
    required this.ringColor,
  });

  final double angleRad;
  final Color needleColor;
  final Color ringColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 8;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = ringColor;
    canvas.drawCircle(center, radius, ringPaint);

    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = ringColor;
    for (var i = 0; i < 12; i++) {
      final long = i % 3 == 0;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * math.pi / 6);
      canvas.drawLine(
        Offset(0, -radius + 14),
        Offset(0, -radius + (long ? 30 : 22)),
        tickPaint,
      );
      canvas.restore();
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angleRad);
    final needlePaint = Paint()..color = needleColor;
    final needle = Path()
      ..moveTo(0, -radius * 0.66)
      ..lineTo(-radius * 0.16, radius * 0.10)
      ..lineTo(radius * 0.16, radius * 0.10)
      ..close();
    canvas.drawPath(needle, needlePaint);
    canvas.drawCircle(Offset.zero, radius * 0.07, needlePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CompassPainter oldDelegate) {
    return oldDelegate.angleRad != angleRad ||
        oldDelegate.needleColor != needleColor ||
        oldDelegate.ringColor != ringColor;
  }
}
