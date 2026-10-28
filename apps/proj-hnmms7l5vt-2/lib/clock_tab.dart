import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'format.dart';

class ClockTab extends StatefulWidget {
  const ClockTab({super.key});

  @override
  State<ClockTab> createState() => _ClockTabState();
}

class _ClockTabState extends State<ClockTab> {
  late DateTime _now = DateTime.now();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Clock')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatClockDigits(_now),
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatDateLine(_now),
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
              ),
              const SizedBox(height: 24),
              AnalogClock(size: 240),
            ],
          ),
        ),
      ),
    );
  }
}

class AnalogClock extends StatelessWidget {
  const AnalogClock({super.key, this.size = 240});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: AnalogClockPainter(
          now: DateTime.now(),
          scheme: Theme.of(context).colorScheme,
        ),
      ),
    );
  }
}

class AnalogClockPainter extends CustomPainter {
  AnalogClockPainter({required this.now, required this.scheme});

  final DateTime now;
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2;

    final Paint face = Paint()
      ..color = scheme.surfaceContainerHighest.withValues(alpha: 0.6);
    canvas.drawCircle(center, radius, face);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = scheme.outlineVariant,
    );

    final Paint tick = Paint()
      ..strokeCap = StrokeCap.round
      ..color = scheme.onSurfaceVariant;
    for (var i = 0; i < 60; i++) {
      final double angle = i * 2 * pi / 60 - pi / 2;
      final bool isHourTick = i % 5 == 0;
      final double inner = radius * (isHourTick ? 0.82 : 0.90);
      tick.strokeWidth = isHourTick ? 3 : 1.5;
      canvas.drawLine(
        Offset(cos(angle) * inner, sin(angle) * inner) + center,
        Offset(cos(angle) * (radius * 0.96), sin(angle) * (radius * 0.96)) +
            center,
        tick,
      );
    }

    void hand(double angle, double length, double width, Color color) {
      final Paint paint = Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center,
        Offset(cos(angle) * length, sin(angle) * length) + center,
        paint,
      );
    }

    final double hourAngle =
        ((now.hour % 12) + now.minute / 60) * 2 * pi / 12 - pi / 2;
    final double minuteAngle =
        (now.minute + now.second / 60) * 2 * pi / 60 - pi / 2;
    final double secondAngle = now.second * 2 * pi / 60 - pi / 2;

    hand(hourAngle, radius * 0.50, 6, scheme.onSurface);
    hand(minuteAngle, radius * 0.72, 4, scheme.onSurface);
    hand(secondAngle, radius * 0.78, 2, scheme.primary);
    canvas.drawCircle(center, 4, Paint()..color = scheme.primary);
  }

  @override
  bool shouldRepaint(AnalogClockPainter oldDelegate) => oldDelegate.now != now;
}
