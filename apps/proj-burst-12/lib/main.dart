import 'package:flutter/material.dart';

void main() {
  runApp(const StreakDaysApp());
}

class StreakDaysApp extends StatelessWidget {
  const StreakDaysApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streak Days',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const StreakHomePage(),
    );
  }
}

class StreakState extends ChangeNotifier {
  final Set<DateTime> _completedDays = <DateTime>{};
  DateTime? _lastCheckIn;
  int _streak = 0;
  int _best = 0;

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime get _today => _dayOf(DateTime.now());

  int get bestStreak => _best;
  bool get isDoneToday => _lastCheckIn == _today;

  int get currentStreak {
    final last = _lastCheckIn;
    if (last == null) {
      return 0;
    }
    final yesterday = _dayOf(_today.subtract(const Duration(days: 1)));
    final alive = last == _today || last == yesterday;
    return alive ? _streak : 0;
  }

  bool isComplete(DateTime day) => _completedDays.contains(_dayOf(day));

  List<DateTime> get lastSevenDays {
    final today = _today;
    return List<DateTime>.generate(
      7,
      (i) => _dayOf(today.subtract(Duration(days: 6 - i))),
    );
  }

  void checkIn() {
    final today = _today;
    if (_lastCheckIn == today) {
      return;
    }
    final yesterday = _dayOf(today.subtract(const Duration(days: 1)));
    _streak = _lastCheckIn == yesterday ? _streak + 1 : 1;
    _lastCheckIn = today;
    _completedDays.add(today);
    if (_streak > _best) {
      _best = _streak;
    }
    notifyListeners();
  }

  void reset() {
    _completedDays.clear();
    _lastCheckIn = null;
    _streak = 0;
    _best = 0;
    notifyListeners();
  }
}

class StreakHomePage extends StatefulWidget {
  const StreakHomePage({super.key});

  @override
  State<StreakHomePage> createState() => _StreakHomePageState();
}

class _StreakHomePageState extends State<StreakHomePage> {
  final StreakState _state = StreakState();

  Future<void> _confirmReset() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset streak?'),
        content: const Text(
          'This clears your current streak, best record and history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) {
      return;
    }
    _state.reset();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Streak Days'),
            actions: [
              IconButton(
                tooltip: 'Reset streak',
                icon: const Icon(Icons.restart_alt),
                onPressed: _confirmReset,
              ),
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FlameIndicator(
                    key: const Key('flame-indicator'),
                    streak: _state.currentStreak,
                    done: _state.isDoneToday,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${_state.currentStreak}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    'day streak',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  WeekStrip(
                    days: _state.lastSevenDays,
                    isComplete: _state.isComplete,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: FilledButton.icon(
                      onPressed:
                          _state.isDoneToday ? null : _state.checkIn,
                      icon: Icon(
                        _state.isDoneToday
                            ? Icons.check_circle
                            : Icons.local_fire_department,
                      ),
                      label: Text(
                        _state.isDoneToday
                            ? "Today's done. See you tomorrow!"
                            : 'Mark today done',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 12),
                            const Text('Best streak'),
                            const SizedBox(width: 16),
                            Text(
                              '${_state.bestStreak} '
                              'day${_state.bestStreak == 1 ? '' : 's'}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class FlameIndicator extends StatelessWidget {
  const FlameIndicator({
    super.key,
    required this.streak,
    required this.done,
  });

  final int streak;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final double scale = 1.0 + streak.clamp(0, 12) * 0.05;
    final Color color = switch (streak) {
      0 => Colors.blueGrey,
      <= 2 => Colors.orange,
      <= 5 => Colors.deepOrange,
      <= 9 => Colors.red,
      _ => const Color(0xFFB71C1C),
    };

    return Center(
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 48,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Icon(
            streak > 0 || done
                ? Icons.local_fire_department
                : Icons.local_fire_department_outlined,
            size: 120,
            color: color,
          ),
        ),
      ),
    );
  }
}

class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.days,
    required this.isComplete,
  });

  final List<DateTime> days;
  final bool Function(DateTime) isComplete;

  static const List<String> _weekdayLabels = [
    'M', 'T', 'W', 'T', 'F', 'S', 'S',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final day in days)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              children: [
                Text(
                  _weekdayLabels[day.weekday - 1],
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isComplete(day)
                        ? colors.primary
                        : colors.surfaceContainerHighest,
                  ),
                  child: isComplete(day)
                      ? Icon(Icons.check, size: 18, color: colors.onPrimary)
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
