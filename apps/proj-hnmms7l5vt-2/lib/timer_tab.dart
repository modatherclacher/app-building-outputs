import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'format.dart';

class TimerTab extends StatefulWidget {
  const TimerTab({super.key});

  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab> {
  int _total = 300;
  int _remaining = 300;
  bool _running = false;
  Timer? _ticker;

  void _applyTotal(int seconds) {
    final int clamped = math.max(0, math.min(99 * 60 + 59, seconds));
    setState(() {
      _total = clamped;
      _remaining = clamped;
    });
  }

  void _adjustMinutes(int delta) {
    _applyTotal(((_total ~/ 60) + delta) * 60 + (_total % 60));
  }

  void _adjustSeconds(int delta) {
    _applyTotal(((_total ~/ 60)) * 60 + math.max(0, math.min(59, (_total % 60) + delta)));
  }

  void _reset() {
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _running = false;
      _remaining = _total;
    });
  }

  void _startPause() {
    if (_running) {
      _ticker?.cancel();
      _ticker = null;
      setState(() => _running = false);
      return;
    }
    if (_remaining == 0) return;
    setState(() => _running = true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    final bool finished = _remaining <= 1;
    setState(() {
      _remaining = finished ? 0 : _remaining - 1;
      if (finished) _running = false;
    });
    if (finished) {
      _ticker?.cancel();
      _ticker = null;
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          icon: const Icon(Icons.notifications_active),
          title: const Text("Time's up!"),
          content: const Text('The countdown timer finished.'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _stepper({
    required String label,
    required int value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: _running ? null : onMinus,
              icon: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 48,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            IconButton(
              onPressed: _running ? null : onPlus,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Timer')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _total > 0 ? _remaining / _total : 0,
                      strokeWidth: 10,
                    ),
                    Text(
                      formatCountdown(_remaining),
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _stepper(
                    label: 'Minutes',
                    value: _total ~/ 60,
                    onMinus: () => _adjustMinutes(-1),
                    onPlus: () => _adjustMinutes(1),
                  ),
                  const SizedBox(width: 24),
                  _stepper(
                    label: 'Seconds',
                    value: _total % 60,
                    onMinus: () => _adjustSeconds(-5),
                    onPlus: () => _adjustSeconds(5),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final int minutes in const [1, 3, 5, 10, 25])
                    OutlinedButton(
                      onPressed: _running
                          ? null
                          : () => _applyTotal(minutes * 60),
                      child: Text('$minutes min'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: _reset,
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _remaining == 0 ? null : _startPause,
                    child: Text(_running ? 'Pause' : 'Start'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
