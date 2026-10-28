import 'package:flutter/material.dart';

import '../models/parking_spot.dart';
import '../state/carspot_controller.dart';
import '../utils/geo_utils.dart';
import '../widgets/compass_needle.dart';
import '../widgets/history_sheet.dart';
import '../widgets/route_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.controller});

  final CarSpotController? controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CarSpotController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    final injected = widget.controller;
    if (injected != null) {
      _controller = injected;
    } else {
      _ownsController = true;
      _controller = CarSpotController();
    }
    _controller.location.start();
  }

  @override
  void dispose() {
    _controller.location.stop();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final spot = _controller.currentSpot;
        return Scaffold(
          appBar: AppBar(
            title: const Text('CarSpot'),
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'History',
                onPressed: () => showHistorySheet(context, _controller),
              ),
            ],
          ),
          body: spot == null
              ? _EmptyState(onSave: _controller.saveCurrentLocation)
              : _GuideView(controller: _controller, spot: spot),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_car_filled_outlined,
              size: 96,
              color: scheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Where did you park?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap below the moment you leave the car — CarSpot remembers the spot and walks you back to it.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.local_parking),
              label: const Text('Save my parking spot'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideView extends StatelessWidget {
  const _GuideView({required this.controller, required this.spot});

  final CarSpotController controller;
  final ParkingSpot spot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final position = controller.location;
    final distance = GeoUtils.distanceMeters(
      position.latitude,
      position.longitude,
      spot.latitude,
      spot.longitude,
    );
    final bearing = GeoUtils.bearingDegrees(
      position.latitude,
      position.longitude,
      spot.latitude,
      spot.longitude,
    );

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: CompassNeedle(
              relativeBearingDeg: (bearing - position.headingDeg + 360) % 360,
              distanceMeters: distance,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Saved at ${TimeOfDay.fromDateTime(spot.savedAt).format(context)}',
                        ),
                      ],
                    ),
                    if (spot.note != null && spot.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.sticky_note_2_outlined,
                              size: 18,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(spot.note!)),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${spot.latitude.toStringAsFixed(5)}, ${spot.longitude.toStringAsFixed(5)}',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _editNote(context),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Note'),
                ),
                FilledButton.icon(
                  onPressed: () => showRouteSheet(context, spot),
                  icon: const Icon(Icons.navigation),
                  label: const Text('Guide me'),
                ),
                FilledButton.tonalIcon(
                  onPressed: controller.foundIt,
                  icon: const Icon(Icons.check),
                  label: const Text('Found it'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editNote(BuildContext context) async {
    final field = TextEditingController(text: spot.note ?? '');
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a note'),
        content: TextField(
          controller: field,
          autofocus: true,
          maxLength: 80,
          decoration: const InputDecoration(
            hintText: 'Level 3, next to the elevator',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(field.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    field.dispose();
    if (note != null) {
      controller.updateNote(note);
    }
  }
}
