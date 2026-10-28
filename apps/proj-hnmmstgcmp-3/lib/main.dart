import 'package:flutter/material.dart';

import 'notes_page.dart';
import 'notes_store.dart';

void main() {
  runApp(const SimpleNotesApp());
}

class SimpleNotesApp extends StatefulWidget {
  const SimpleNotesApp({super.key, this.store});

  final NotesStore? store;

  @override
  State<SimpleNotesApp> createState() => _SimpleNotesAppState();
}

class _SimpleNotesAppState extends State<SimpleNotesApp> {
  late final NotesStore _store = widget.store ?? NotesStore();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Notes',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: NotesPage(store: _store),
    );
  }
}
