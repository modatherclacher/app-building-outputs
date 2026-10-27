import 'package:flutter/material.dart';

void main() {
  runApp(const WaterGoalApp());
}

class WaterGoalApp extends StatelessWidget {
  const WaterGoalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Goal',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue,
          brightness: Brightness.dark,
        ),
      ),
      home: const GoalPage(),
    );
  }
}

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  static const int _defaultGoal = 8;

  int _glasses = 0;
  int _goal = _defaultGoal;

  double get _progress => _goal <= 0 ? 1.0 : (_glasses / _goal).clamp(0.0, 1.0);

  void _addGlass() {
    setState(() => _glasses++);
  }

  void _undoGlass() {
    if (_glasses > 0) setState(() => _glasses--);
  }

  void _resetDay() {
    setState(() => _glasses = 0);
  }

  Future<void> _editGoal() async {
    final value = await showDialog<int>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: '$_goal');
        return AlertDialog(
          title: const Text('Daily goal'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Glasses per day',
              suffixText: '🥤',
            ),
            onSubmitted: Navigator.of(context).pop,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(int.tryParse(controller.text)),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (value != null && value > 0) {
      setState(() => _goal = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = _glasses >= _goal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Goal'),
        actions: [
          IconButton(
            tooltip: 'Set daily goal',
            icon: const Icon(Icons.flag_outlined),
            onPressed: _editGoal,
          ),
          IconButton(
            tooltip: 'Reset day',
            icon: const Icon(Icons.refresh),
            onPressed: _resetDay,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              done ? 'Goal reached! 🎉' : 'Glasses of water today',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 14,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$_glasses',
                      style: theme.textTheme.displayMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '/ $_goal glasses',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (done)
                      Icon(
                        Icons.water_drop,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '💧' * _glasses,
              textAlign: TextAlign.center,
              overflow: TextOverflow.clip,
              maxLines: 1,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Row(
            children: [
              IconButton.filledTonal(
                tooltip: 'Undo last glass',
                icon: const Icon(Icons.remove),
                onPressed: _glasses > 0 ? _undoGlass : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.water_drop),
                  label: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('+ Add a glass'),
                  ),
                  onPressed: _addGlass,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
