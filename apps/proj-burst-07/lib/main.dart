import 'package:flutter/material.dart';

import 'picker_screen.dart';
import 'picker_state.dart';

void main() {
  runApp(const RandomPickerApp());
}

class RandomPickerApp extends StatelessWidget {
  const RandomPickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Picker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: PickerScreen(state: PickerState()),
    );
  }
}
