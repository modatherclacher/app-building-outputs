import 'dart:async';

import 'package:flutter/material.dart';

import 'format.dart';

class StopwatchTab extends StatefulWidget {
  const StopwatchTab({super.key});

  @override
  State<StopwatchTab> createState() => _StopwatchTabState();
}

class _StopwatchTabState extends State<StopwatchTab> {
  final Stopwatch _stopwatch = Stopwatch();
  final List<Duration> _laps = <Duration>[];
  Timer? _uiTicker;

  bool get _running => _stopwatch.isRunning;

  void _toggle() {
    if (_running) {
      _stopwatch.stop();
      _uiTicker?.cancel();
      _uiTicker = null;
      setState(() {});
    } else {
      _stopwatch.start();
      _uiTicker = Timer.periodic(const Duration(milliseconds: 50), (_) {
        if (mounted) setState(() {});
      });
      setState(() {});
    }
  }

  void _lap() {
    setState(() => _laps.insert(0, _stopwatch.elapsed));
  }

  void _reset() {
    _stopwatch
      ..stop()
      ..reset();
    _uiTicker?.cancel();
    _uiTicker = null;
    setState(() => _laps.clear());
  }

  @override
  void dispose() {
    _uiTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatStopwatch(_stopwatch.elapsed),
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: _stopwatch.elapsed == Duration.zero
                            ? null
                            : _reset,
                        child: const Text('Reset'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _toggle,
                        child: Text(_running ? 'Pause' : 'Start'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: _running ? _lap : null,
                        child: const Text('Lap'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _laps.isEmpty
                ? Center(
                    child: Text(
                      'No laps yet',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    itemCount: _laps.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Duration lap = _laps[index];
                      final Duration previous = index + 1 < _laps.length
                          ? _laps[index + 1]
                          : Duration.zero;
                      final Duration split = lap - previous;
                      return ListTile(
                        leading: Text('Lap ${_laps.length - index}'),
                        title: Text(
                          formatStopwatch(split),
                          style: const TextStyle(
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        trailing: Text(
                          formatStopwatch(lap),
                          style: const TextStyle(
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
