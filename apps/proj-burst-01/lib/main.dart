import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const DiceRollerApp());
}

class DiceRollerApp extends StatelessWidget {
  const DiceRollerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dice Roller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const DiceRollerPage(),
    );
  }
}

@immutable
class RollResult {
  const RollResult({
    required this.sides,
    required this.value,
    required this.rolledAt,
  });

  final int sides;
  final int value;
  final DateTime rolledAt;

  String get label => 'd$sides';
}

class DiceRollerPage extends StatefulWidget {
  const DiceRollerPage({super.key});

  @override
  State<DiceRollerPage> createState() => _DiceRollerPageState();
}

class _DiceRollerPageState extends State<DiceRollerPage> {
  static const List<int> _dieTypes = <int>[4, 6, 8, 20];

  final Random _random = Random();
  final List<RollResult> _history = <RollResult>[];

  int _selectedSides = 6;
  int? _lastRoll;

  void _roll() {
    setState(() {
      _lastRoll = _random.nextInt(_selectedSides) + 1;
      _history.insert(
        0,
        RollResult(
          sides: _selectedSides,
          value: _lastRoll!,
          rolledAt: DateTime.now(),
        ),
      );
    });
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
      _lastRoll = null;
    });
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _formatTime(DateTime time) =>
      '${_twoDigits(time.hour)}:${_twoDigits(time.minute)}:${_twoDigits(time.second)}';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String dieLabel = 'd$_selectedSides';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dice Roller'),
        backgroundColor: colors.inversePrimary,
        actions: <Widget>[
          IconButton(
            tooltip: 'Clear history',
            icon: const Icon(Icons.delete_outline),
            onPressed: _history.isEmpty ? null : _clearHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SegmentedButton<int>(
                segments: <ButtonSegment<int>>[
                  for (final int sides in _dieTypes)
                    ButtonSegment<int>(value: sides, label: Text('d$sides')),
                ],
                selected: <int>{_selectedSides},
                onSelectionChanged: (Set<int> selection) {
                  setState(() => _selectedSides = selection.first);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                child: SizedBox(
                  height: 180,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _lastRoll?.toString() ?? dieLabel,
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _lastRoll == null
                              ? 'Tap Roll to throw a $dieLabel'
                              : 'You rolled $_lastRoll on a $dieLabel',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('History', style: theme.textTheme.titleMedium),
              ),
            ),
            Expanded(
              child: _history.isEmpty
                  ? Center(
                      child: Text(
                        'No rolls yet.',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: colors.outline),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: _history.length,
                      itemBuilder: (BuildContext context, int index) {
                        final RollResult roll = _history[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colors.primaryContainer,
                            child: Text('${roll.value}'),
                          ),
                          title: Text('${roll.label} roll'),
                          subtitle: Text(_formatTime(roll.rolledAt)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _roll,
        icon: const Icon(Icons.casino),
        label: const Text('Roll'),
      ),
    );
  }
}
