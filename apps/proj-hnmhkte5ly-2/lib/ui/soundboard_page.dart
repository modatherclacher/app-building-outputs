import 'package:flutter/material.dart';

import '../audio/engine.dart';
import '../data/catalog.dart';
import '../state/soundboard_model.dart';

class SoundboardPage extends StatefulWidget {
  const SoundboardPage({super.key});

  @override
  State<SoundboardPage> createState() => _SoundboardPageState();
}

class _SoundboardPageState extends State<SoundboardPage> {
  final _model = SoundboardModel(SoundEngine());
  CategoryFilter _filter = CategoryFilter.all;

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) {
        final active = _model.activeIds;
        final category = _filter.category;
        final visible =
            category == null ? sounds : sounds.where((s) => s.category == category).toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Acoustic Soundboard')),
          floatingActionButton: active.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: _model.stopAll,
                  icon: const Icon(Icons.stop),
                  label: Text('Stop all (${active.length})'),
                ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: SegmentedButton<CategoryFilter>(
                  segments: [
                    for (final filter in CategoryFilter.values)
                      ButtonSegment(
                        value: filter,
                        label: Text(filter.label),
                        icon: Icon(filter.icon),
                      ),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (selection) =>
                      setState(() => _filter = selection.first),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    mainAxisExtent: 150,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final sound = visible[index];
                    return SoundCard(
                      sound: sound,
                      playing: _model.isActive(sound.id),
                      onTap: () => _model.toggle(sound),
                    );
                  },
                ),
              ),
              if (active.isNotEmpty) NowPlayingPanel(model: _model),
            ],
          ),
        );
      },
    );
  }
}

class SoundCard extends StatelessWidget {
  const SoundCard({
    super.key,
    required this.sound,
    required this.playing,
    required this.onTap,
  });

  final Sound sound;
  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: playing ? colors.primaryContainer : colors.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                sound.icon,
                size: 32,
                color:
                    playing ? colors.onPrimaryContainer : colors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                sound.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 2),
              Text(
                playing ? 'Playing' : (sound.loop ? 'Loops' : 'Tap'),
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NowPlayingPanel extends StatelessWidget {
  const NowPlayingPanel({super.key, required this.model});

  final SoundboardModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final playing = sounds.where((s) => model.isActive(s.id)).toList();

    return Container(
      width: double.infinity,
      color: colors.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 210),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Text(
                  'Now playing (${playing.length})',
                  style: theme.textTheme.labelLarge,
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final sound in playing)
                      ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        leading: Icon(sound.icon, color: colors.primary),
                        title: Text(sound.name),
                        subtitle: Slider(
                          value: model.volumeOf(sound.id),
                          onChanged: (value) => model.setVolume(sound, value),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.stop),
                          tooltip: 'Stop ${sound.name}',
                          onPressed: () => model.stop(sound),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
