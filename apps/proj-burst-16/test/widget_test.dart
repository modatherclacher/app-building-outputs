import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:water_goal/main.dart';

void main() {
  testWidgets('app shows add button and tracks glasses', (tester) async {
    await tester.pumpWidget(const WaterGoalApp());

    expect(find.text('Water Goal'), findsOneWidget);
    expect(find.text('+ Add a glass'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('/ 8 glasses'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.water_drop));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
