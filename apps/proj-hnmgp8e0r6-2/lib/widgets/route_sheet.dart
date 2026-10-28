import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/parking_spot.dart';

void showRouteSheet(BuildContext context, ParkingSpot spot) {
  final latitude = spot.latitude.toStringAsFixed(6);
  final longitude = spot.longitude.toStringAsFixed(6);
  final googleMapsUrl =
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=walking';
  final appleMapsUrl =
      'https://maps.apple.com/?daddr=$latitude,$longitude&dirflg=w';

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Guide me back',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Pick a service and its walking link is copied to your clipboard — paste it into any browser to start turn-by-turn directions.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              _RouteTile(
                icon: Icons.map,
                title: 'Google Maps',
                url: googleMapsUrl,
              ),
              _RouteTile(
                icon: Icons.phone_iphone,
                title: 'Apple Maps',
                url: appleMapsUrl,
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _RouteTile extends StatelessWidget {
  const _RouteTile({
    required this.icon,
    required this.title,
    required this.url,
  });

  final IconData icon;
  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.copy),
      onTap: () => _copy(context),
    );
  }

  void _copy(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    Clipboard.setData(ClipboardData(text: url));
    Navigator.of(context).maybePop();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Link copied — open it in your maps app or browser.'),
      ),
    );
  }
}
