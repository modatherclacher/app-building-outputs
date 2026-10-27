import 'dart:math';

import 'package:flutter/foundation.dart';

class PickerState extends ChangeNotifier {
  PickerState({List<String>? seedNames})
      : _names = List<String>.of(seedNames ?? defaultNames);

  static const List<String> defaultNames = [
    'Ada Lovelace',
    'Grace Hopper',
    'Alan Turing',
    'Marie Curie',
    'Katherine Johnson',
  ];

  final Random _random = Random();
  final List<String> _names;

  List<String> _results = const [];
  int _pickCount = 2;

  List<String> get names => List.unmodifiable(_names);

  List<String> get results => List.unmodifiable(_results);

  int get pickCount => _pickCount;

  int get nameCount => _names.length;

  bool get canPick => _names.isNotEmpty;

  void setPickCount(int value) {
    if (_names.isEmpty) return;
    final next = max(1, min(value, _names.length));
    if (next == _pickCount) return;
    _pickCount = next;
    notifyListeners();
  }

  bool addName(String raw) => _upsert(_names.length, raw, replace: false);

  bool editName(int index, String raw) => _upsert(index, raw, replace: true);

  void removeName(int index) {
    if (index < 0 || index >= _names.length) return;
    _names.removeAt(index);
    if (_names.isEmpty) {
      _results = const [];
    }
    _clampPickCount();
    notifyListeners();
  }

  void pick() {
    if (_names.isEmpty) return;
    final pool = List<String>.of(_names)..shuffle(_random);
    _results = pool.take(_pickCount).toList(growable: false);
    notifyListeners();
  }

  void clearResults() {
    if (_results.isEmpty) return;
    _results = const [];
    notifyListeners();
  }

  void _clampPickCount() {
    if (_names.isEmpty) return;
    final clamped = max(1, min(_pickCount, _names.length));
    if (clamped != _pickCount) {
      _pickCount = clamped;
    }
  }

  bool _upsert(int index, String raw, {required bool replace}) {
    final name = raw.trim();
    if (name.isEmpty) return false;
    if (replace && _names[index] == name) return true;
    for (var i = 0; i < _names.length; i++) {
      if (replace && i == index) continue;
      if (_names[i].toLowerCase() == name.toLowerCase()) return false;
    }
    if (replace) {
      _names[index] = name;
    } else {
      _names.insert(index, name);
    }
    _clampPickCount();
    notifyListeners();
    return true;
  }
}
