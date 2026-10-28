import 'package:flutter/material.dart';

class Alarm {
  Alarm({
    required this.id,
    required this.time,
    required this.label,
    this.enabled = true,
  });

  final int id;
  final TimeOfDay time;
  final String label;
  bool enabled;
}

class AlarmStore extends ChangeNotifier {
  final List<Alarm> _alarms = <Alarm>[];
  int _nextId = 1;

  List<Alarm> get alarms => List.unmodifiable(_alarms);

  void add(TimeOfDay time, String label) {
    _alarms.add(
      Alarm(id: _nextId++, time: time, label: label.trim().isEmpty
          ? 'Alarm'
          : label.trim()),
    );
    notifyListeners();
  }

  void setEnabled(int id, bool enabled) {
    for (final Alarm alarm in _alarms) {
      if (alarm.id == id) {
        alarm.enabled = enabled;
        break;
      }
    }
    notifyListeners();
  }

  void remove(int id) {
    _alarms.removeWhere((Alarm alarm) => alarm.id == id);
    notifyListeners();
  }
}

class AlarmsTab extends StatefulWidget {
  const AlarmsTab({super.key, required this.store});

  final AlarmStore store;

  @override
  State<AlarmsTab> createState() => _AlarmsTabState();
}

class _AlarmsTabState extends State<AlarmsTab> {
  Future<void> _addAlarm() async {
    TimeOfDay time = TimeOfDay.now();
    final TextEditingController labelController =
        TextEditingController(text: 'Alarm');
    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext builderContext, void Function(void Function())
              setDialogState) {
            return AlertDialog(
              title: const Text('New alarm'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: labelController,
                    maxLength: 30,
                    decoration: const InputDecoration(labelText: 'Label'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(time.format(builderContext)),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: builderContext,
                        initialTime: time,
                      );
                      if (picked != null) setDialogState(() => time = picked);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    if (saved == true && mounted) {
      widget.store.add(time, labelController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Alarms')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        child: const Icon(Icons.add_alarm),
      ),
      body: ListenableBuilder(
        listenable: widget.store,
        builder: (BuildContext context, Widget? _) {
          final List<Alarm> alarms = widget.store.alarms;
          if (alarms.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.alarm_off,
                      size: 48, color: scheme.onSurfaceVariant),
                  const SizedBox(height: 8),
                  Text('No alarms yet',
                      style: TextStyle(color: scheme.onSurfaceVariant)),
                  Text('Tap the + button to add one',
                      style: TextStyle(color: scheme.onSurfaceVariant)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: alarms.length,
            itemBuilder: (BuildContext context, int index) {
              final Alarm alarm = alarms[index];
              return Dismissible(
                key: ValueKey<int>(alarm.id),
                background: Container(
                  color: scheme.errorContainer,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Icon(Icons.delete,
                      color: scheme.onErrorContainer),
                ),
                onDismissed: (DismissDirection direction) {
                  widget.store.remove(alarm.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Alarm deleted')),
                    );
                  }
                },
                child: SwitchListTile(
                  secondary: Icon(
                    alarm.enabled ? Icons.alarm_on : Icons.alarm_off,
                  ),
                  title: Text(
                    alarm.time.format(context),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: alarm.enabled ? null : scheme.onSurfaceVariant,
                    ),
                  ),
                  subtitle: Text(alarm.label),
                  value: alarm.enabled,
                  onChanged: (bool value) =>
                      widget.store.setEnabled(alarm.id, value),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
