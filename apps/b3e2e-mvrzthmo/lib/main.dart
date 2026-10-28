import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const TipCalculatorApp());
}

class TipCalculatorApp extends StatelessWidget {
  const TipCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Colors.teal;
    return MaterialApp(
      title: 'B3 Verification',
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
      home: const TipCalculatorPage(title: 'Tip Calculator'),
    );
  }
}

class TipCalculatorPage extends StatefulWidget {
  const TipCalculatorPage({super.key, required this.title});

  final String title;

  @override
  State<TipCalculatorPage> createState() => _TipCalculatorPageState();
}

class _TipCalculatorPageState extends State<TipCalculatorPage> {
  final TextEditingController _billController = TextEditingController();

  static const List<double> _quickTips = [10, 15, 18, 20];

  double _tipPercent = 15;

  double get _bill {
    final raw = _billController.text.trim().replaceAll(',', '.');
    final value = double.tryParse(raw);
    return (value == null || value < 0) ? 0 : value;
  }

  double get _tip => _bill * _tipPercent / 100;
  double get _total => _bill + _tip;

  String _money(double value) => '\$${value.toStringAsFixed(2)}';

  @override
  void dispose() {
    _billController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _billController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*[.,]?\d*'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Bill amount',
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.receipt_long),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tip percentage',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      '${_tipPercent.round()}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                Slider(
                  value: _tipPercent,
                  min: 0,
                  max: 50,
                  divisions: 50,
                  label: '${_tipPercent.round()}%',
                  onChanged: (value) => setState(() => _tipPercent = value),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final percent in _quickTips)
                      ChoiceChip(
                        label: Text('${percent.round()}%'),
                        selected: _tipPercent.round() == percent.round(),
                        onSelected: (_) =>
                            setState(() => _tipPercent = percent),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _resultRow(
                          'Tip (${_tipPercent.round()}%)',
                          _money(_tip),
                          emphasized: false,
                        ),
                        const Divider(),
                        _resultRow('Total', _money(_total), emphasized: true),
                      ],
                    ),
                  ),
                ),
                if (_bill == 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Enter a bill amount to see the tip and total.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, {required bool emphasized}) {
    final theme = Theme.of(context);
    final style = emphasized
        ? theme.textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)
        : theme.textTheme.titleMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
