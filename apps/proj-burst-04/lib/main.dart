import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const RingTimerApp());
}

class RingTimerApp extends StatelessWidget {
  const RingTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ring Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const TimerScreen(),
    );
  }
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final CountdownController _controller = CountdownController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(Duration duration) {
    final int minutes = duration.inMinutes;
    final int seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String _statusLabel(CountdownController controller) {
    if (controller.finished) {
      return 'Done!';
    }
    if (controller.running) {
      return 'Running';
    }
    if (controller.remaining != controller.total) {
      return 'Paused';
    }
    return 'Ready';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Ring Timer')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? _) {
            final CountdownController controller = _controller;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CustomPaint(
                      key: const ValueKey<String>('progress_ring'),
                      painter: RingPainter(
                        progress: controller.progress,
                        color: colors.primary,
                        trackColor: colors.surfaceContainerHighest,
                      ),
                      child: SizedBox(
                        width: 280,
                        height: 280,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                _format(controller.remaining),
                                key: const ValueKey<String>('time_display'),
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(
                                      fontFeatures: const <FontFeature>[
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _statusLabel(controller),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: <Widget>[
                        for (final Duration preset in controller.presets)
                          ChoiceChip(
                            label: Text(_format(preset)),
                            selected: controller.total == preset,
                            onSelected: (bool _) => controller.select(preset),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FilledButton.icon(
                          onPressed: controller.finished
                              ? null
                              : controller.toggle,
                          icon: Icon(
                            controller.running
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          label: Text(
                            controller.running
                                ? 'Pause'
                                : (controller.remaining == controller.total
                                    ? 'Start'
                                    : 'Resume'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.tonalIcon(
                          onPressed: controller.reset,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CountdownController extends ChangeNotifier {
  static const Duration _tickInterval = Duration(milliseconds: 100);

  final List<Duration> presets = const <Duration>[
    Duration(minutes: 1),
    Duration(minutes: 3),
    Duration(minutes: 5),
    Duration(minutes: 10),
  ];

  Timer? _timer;
  Duration _total = const Duration(minutes: 5);
  Duration _remaining = const Duration(minutes: 5);
  bool _running = false;
  Duration get total => _total;
  Duration get remaining => _remaining;
  bool get running => _running;
  bool get finished => _remaining == Duration.zero;
  double get progress =>
      _total.inMilliseconds <= 0
          ? 0.0
          : (_remaining.inMilliseconds / _total.inMilliseconds).clamp(0.0, 1.0);

  void select(Duration duration) {
    _stopTimer();
    _total = duration;
    _remaining = duration;
    _running = false;
    notifyListeners();
  }

  void toggle() {
    if (finished) {
      return;
    }
    if (_running) {
      _stopTimer();
      _running = false;
    } else {
      _running = true;
      _timer = Timer.periodic(_tickInterval, (Timer _) => _tick());
    }
    notifyListeners();
  }

  void reset() {
    _stopTimer();
    _remaining = _total;
    _running = false;
    notifyListeners();
  }

  void _tick() {
    if (_remaining <= _tickInterval) {
      _remaining = Duration.zero;
      _stopTimer();
      _running = false;
    } else {
      _remaining -= _tickInterval;
    }
    notifyListeners();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

class RingPainter extends CustomPainter {
  RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  static const double strokeThickness = 16;

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide - strokeThickness) / 2;

    final Paint trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeThickness
      ..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    final double sweep = 2 * math.pi * progress;
    if (sweep > 0) {
      final Paint progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeThickness
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweep,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}
