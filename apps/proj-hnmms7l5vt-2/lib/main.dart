import 'dart:async';

import 'package:flutter/material.dart';

import 'alarms_tab.dart';
import 'clock_tab.dart';
import 'stopwatch_tab.dart';
import 'timer_tab.dart';

void main() {
  runApp(const ClockApp());
}

class ClockApp extends StatelessWidget {
  const ClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clock App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  final AlarmStore _alarmStore = AlarmStore();
  final Set<String> _firedAlarms = <String>{};
  Timer? _alarmWatcher;

  @override
  void initState() {
    super.initState();
    _alarmWatcher = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _checkAlarms(),
    );
  }

  void _checkAlarms() {
    if (!mounted || _alarmStore.alarms.isEmpty) return;
    final TimeOfDay now = TimeOfDay.now();
    for (final Alarm alarm in _alarmStore.alarms) {
      if (!alarm.enabled ||
          alarm.time.hour != now.hour ||
          alarm.time.minute != now.minute) {
        continue;
      }
      final String key = '${alarm.id}-${now.hour}-${now.minute}';
      if (_firedAlarms.add(key)) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            icon: const Icon(Icons.alarm_on),
            title: Text(alarm.label),
            content: Text(
              'It is ${alarm.time.format(dialogContext)} — time for your alarm.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _alarmWatcher?.cancel();
    _alarmStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          const ClockTab(),
          AlarmsTab(store: _alarmStore),
          const StopwatchTab(),
          const TimerTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (int index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Clock',
          ),
          NavigationDestination(
            icon: Icon(Icons.alarm_outlined),
            selectedIcon: Icon(Icons.alarm),
            label: 'Alarms',
          ),
          NavigationDestination(
            icon: Icon(Icons.av_timer_outlined),
            selectedIcon: Icon(Icons.av_timer),
            label: 'Stopwatch',
          ),
          NavigationDestination(
            icon: Icon(Icons.hourglass_bottom_outlined),
            selectedIcon: Icon(Icons.hourglass_bottom),
            label: 'Timer',
          ),
        ],
      ),
    );
  }
}
