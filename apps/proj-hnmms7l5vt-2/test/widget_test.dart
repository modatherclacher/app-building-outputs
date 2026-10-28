import 'package:clock_app/clock_tab.dart';
import 'package:clock_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('clock app boots and shows all four tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const ClockApp());

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Clock'), findsWidgets);
    expect(find.text('Alarms'), findsWidgets);
    expect(find.text('Stopwatch'), findsWidgets);
    expect(find.text('Timer'), findsWidgets);
    expect(find.byType(AnalogClock), findsOneWidget);
  });
}
