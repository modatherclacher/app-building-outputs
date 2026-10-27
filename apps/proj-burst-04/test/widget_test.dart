import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ring_timer/main.dart';

void main() {
  testWidgets('smoke test: renders progress ring, time and controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RingTimerApp());

    expect(find.byKey(const ValueKey<String>('progress_ring')), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('time_display')),
      findsOneWidget,
    );
    expect(find.text('05:00'), findsNWidgets(2));
    expect(find.text('Ready'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}
