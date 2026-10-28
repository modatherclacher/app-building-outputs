import 'package:flutter/material.dart';

import '../state/carspot_controller.dart';

void showHistorySheet(BuildContext context, CarSpotController controller) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final history = controller.history;
          return SafeArea(
            child: history.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No past spots yet.')),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final spot = history[index];
                      final coords =
                          '${spot.latitude.toStringAsFixed(5)}, ${spot.longitude.toStringAsFixed(5)}';
                      final note = spot.note;
                      return ListTile(
                        leading: const Icon(Icons.local_parking_outlined),
                        title: Text(
                          'Parked at ${TimeOfDay.fromDateTime(spot.savedAt).format(context)}',
                        ),
                        subtitle: Text(
                          note == null || note.isEmpty
                              ? coords
                              : '$note · $coords',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              controller.removeFromHistory(spot.id),
                        ),
                      );
                    },
                  ),
          );
        },
      );
    },
  );
}
