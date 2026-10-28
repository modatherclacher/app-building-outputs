import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:simple_notes/main.dart';
import 'package:simple_notes/notes_store.dart';

void main() {
  testWidgets('home screen shows the app, empty state, and add button',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(SimpleNotesApp(store: NotesStore(prefs: prefs)));
    await tester.pump();

    expect(find.text('Simple Notes'), findsOneWidget);
    expect(find.text('No notes yet'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
