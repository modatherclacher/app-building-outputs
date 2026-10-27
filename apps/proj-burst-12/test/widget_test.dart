import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak_days/main.dart';

void main() {
  testWidgets('renders flame indicator and streak UI, and records a check-in',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StreakDaysApp());

    expect(find.text('Streak Days'), findsOneWidget);
    expect(find.byKey(const Key('flame-indicator')), findsOneWidget);
    expect(find.text('day streak'), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('1 day'), findsOneWidget);
  });
}
