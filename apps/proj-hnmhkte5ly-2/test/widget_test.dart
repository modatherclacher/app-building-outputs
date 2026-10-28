import 'package:acoustic_soundboard/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the app bar and the sound grid', (tester) async {
    await tester.pumpWidget(const AcousticSoundboardApp());

    expect(find.text('Acoustic Soundboard'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('Boing'), findsOneWidget);
    expect(find.text('Lo-fi'), findsOneWidget);
  });
}
