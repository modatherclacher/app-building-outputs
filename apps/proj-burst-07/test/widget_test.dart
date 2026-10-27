import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:random_picker/main.dart';

void main() {
  testWidgets('renders the random picker screen', (tester) async {
    await tester.pumpWidget(const RandomPickerApp());

    expect(find.text('Random Picker'), findsOneWidget);
    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
