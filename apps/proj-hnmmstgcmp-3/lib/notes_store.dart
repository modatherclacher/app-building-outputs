import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'note.dart';

class NotesStore extends ChangeNotifier {
  NotesStore({SharedPreferences? prefs})
      : _prefsReady = prefs != null
            ? Future<SharedPreferences>.value(prefs)
            : SharedPreferences.getInstance() {
    _load();
  }

  static const String _storageKey = 'simple_notes.v1';

  final Future<SharedPreferences> _prefsReady;
  final List<Note> _notes = <Note>[];
  String _query = '';

  List<Note> get notes {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return List<Note>.unmodifiable(_notes);
    }
    return List<Note>.unmodifiable(
      _notes.where(
        (Note note) =>
            note.title.toLowerCase().contains(q) ||
            note.body.toLowerCase().contains(q),
      ),
    );
  }

  bool get isSearching => _query.trim().isNotEmpty;

  void search(String query) {
    if (query == _query) {
      return;
    }
    _query = query;
    notifyListeners();
  }

  Note add({required String title, required String body}) {
    final Note note = Note(
      id: 'note-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      body: body,
    );
    _notes.add(note);
    _sortAndPersist();
    return note;
  }

  void update(Note note, {required String title, required String body}) {
    note
      ..title = title
      ..body = body
      ..touch();
    _sortAndPersist();
  }

  void delete(Note note) {
    _notes.remove(note);
    _sortAndPersist();
  }

  void _sortAndPersist() {
    _notes.sort((Note a, Note b) => b.modified.compareTo(a.modified));
    notifyListeners();
    _persist();
  }

  Future<void> _load() async {
    try {
      final SharedPreferences prefs = await _prefsReady;
      final String? raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) {
        return;
      }
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      _notes
        ..clear()
        ..addAll(<Note>[
          for (final Object? item in decoded)
            if (item is Map<String, dynamic>) Note.fromJson(item),
        ]);
      _notes.sort((Note a, Note b) => b.modified.compareTo(a.modified));
      notifyListeners();
    } catch (_) {
      return;
    }
  }

  Future<void> _persist() async {
    try {
      final SharedPreferences prefs = await _prefsReady;
      await prefs.setString(
        _storageKey,
        jsonEncode(<Map<String, dynamic>>[
          for (final Note note in _notes) note.toJson(),
        ]),
      );
    } catch (_) {
      return;
    }
  }
}
