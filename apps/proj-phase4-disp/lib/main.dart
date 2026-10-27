import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const DispatchProbeApp());
}

class DispatchProbeApp extends StatelessWidget {
  const DispatchProbeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dispatch Probe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const TapCounterPage(),
    );
  }
}

class TapCounterPage extends StatefulWidget {
  const TapCounterPage({super.key});

  @override
  State<TapCounterPage> createState() => _TapCounterPageState();
}

class _TapCounterPageState extends State<TapCounterPage> {
  int _count = 0;

  void _increment() {
    HapticFeedback.lightImpact();
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
      appBar: AppBar(title: const Text('Dispatch Probe')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tap the number',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _increment,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                child: Text(
                  '$_count',
                  style: TextStyle(
                    fontSize: 140,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: _reset,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
