import 'package:flutter/material.dart';

import 'ui/soundboard_page.dart';

void main() => runApp(const AcousticSoundboardApp());

class AcousticSoundboardApp extends StatelessWidget {
  const AcousticSoundboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acoustic Soundboard',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const SoundboardPage(),
    );
  }
}
