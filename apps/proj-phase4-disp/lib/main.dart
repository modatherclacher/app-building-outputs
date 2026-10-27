import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const DispatchProbeApp());
}

class DispatchProbeApp extends StatelessWidget {
  const DispatchProbeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF4F46E5);
    return MaterialApp(
      title: 'Dispatch Probe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const TapCounterScreen(),
    );
  }
}

class TapCounterScreen extends StatefulWidget {
  const TapCounterScreen({super.key});

  @override
  State<TapCounterScreen> createState() => _TapCounterScreenState();
}

class _TapCounterScreenState extends State<TapCounterScreen> {
  int _count = 0;

  void _increment() {
    HapticFeedback.mediumImpact();
    setState(() => _count++);
  }

  void _reset() {
    HapticFeedback.heavyImpact();
    setState(() => _count = 0);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          key: const Key('tap_area'),
          behavior: HitTestBehavior.opaque,
          onTap: _increment,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$_count',
                          key: const Key('counter_value'),
                          style: TextStyle(
                            fontSize: 140,
                            fontWeight: FontWeight.w900,
                            color: scheme.primary,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _count == 1 ? 'tap' : 'taps',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: TextButton.icon(
                  key: const Key('reset_button'),
                  onPressed: _count == 0 ? null : _reset,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
