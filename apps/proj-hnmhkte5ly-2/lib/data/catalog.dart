import 'package:flutter/material.dart';

import '../audio/synth.dart';

enum SoundCategory { funny, lofi, rain }

/// Grid filter shown in the category selector.
enum CategoryFilter {
  all('All', Icons.grid_view),
  funny('Funny', Icons.theater_comedy),
  lofi('Lo-fi', Icons.music_note),
  rain('Rain', Icons.cloud);

  const CategoryFilter(this.label, this.icon);

  final String label;
  final IconData icon;

  SoundCategory? get category => switch (this) {
        CategoryFilter.all => null,
        CategoryFilter.funny => SoundCategory.funny,
        CategoryFilter.lofi => SoundCategory.lofi,
        CategoryFilter.rain => SoundCategory.rain,
      };
}

class Sound {
  const Sound({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.loop,
    required this.render,
  });

  final String id;
  final String name;
  final IconData icon;
  final SoundCategory category;

  /// Whether the sound loops until stopped, or plays once per tap.
  final bool loop;
  final SoundRenderer render;
}

/// Every sound in the soundboard, synthesized on demand and cached by id.
const List<Sound> sounds = [
  // Funny one-shots
  Sound(
    id: 'boing',
    name: 'Boing',
    icon: Icons.emoji_emotions,
    category: SoundCategory.funny,
    loop: false,
    render: renderBoing,
  ),
  Sound(
    id: 'zap',
    name: 'Zap',
    icon: Icons.bolt,
    category: SoundCategory.funny,
    loop: false,
    render: renderZap,
  ),
  Sound(
    id: 'bloop',
    name: 'Bloop',
    icon: Icons.bubble_chart,
    category: SoundCategory.funny,
    loop: false,
    render: renderBloop,
  ),
  Sound(
    id: 'wobble',
    name: 'Wobble',
    icon: Icons.waves,
    category: SoundCategory.funny,
    loop: false,
    render: renderWobble,
  ),
  Sound(
    id: 'tada',
    name: 'Tada',
    icon: Icons.celebration,
    category: SoundCategory.funny,
    loop: false,
    render: renderTada,
  ),
  // Lo-fi loops
  Sound(
    id: 'chill-keys',
    name: 'Chill Keys',
    icon: Icons.piano,
    category: SoundCategory.lofi,
    loop: true,
    render: renderChillKeys,
  ),
  Sound(
    id: 'beat-loop',
    name: 'Beat Loop',
    icon: Icons.graphic_eq,
    category: SoundCategory.lofi,
    loop: true,
    render: renderBeatLoop,
  ),
  Sound(
    id: 'bassline',
    name: 'Bassline',
    icon: Icons.speaker,
    category: SoundCategory.lofi,
    loop: true,
    render: renderBassline,
  ),
  Sound(
    id: 'vinyl-crackle',
    name: 'Vinyl',
    icon: Icons.album,
    category: SoundCategory.lofi,
    loop: true,
    render: renderVinylCrackle,
  ),
  // Ambient rain
  Sound(
    id: 'rain-shower',
    name: 'Rain Shower',
    icon: Icons.water_drop,
    category: SoundCategory.rain,
    loop: true,
    render: renderRainShower,
  ),
  Sound(
    id: 'heavy-rain',
    name: 'Heavy Rain',
    icon: Icons.umbrella,
    category: SoundCategory.rain,
    loop: true,
    render: renderHeavyRain,
  ),
  Sound(
    id: 'rain-window',
    name: 'Rain on Window',
    icon: Icons.window,
    category: SoundCategory.rain,
    loop: true,
    render: renderRainWindow,
  ),
  Sound(
    id: 'thunder',
    name: 'Distant Thunder',
    icon: Icons.thunderstorm,
    category: SoundCategory.rain,
    loop: true,
    render: renderThunder,
  ),
];
