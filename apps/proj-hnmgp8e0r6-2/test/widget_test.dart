import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:carspot/main.dart';

void main() {
  testWidgets('smoke test: the app renders and a spot can be saved',
      (tester) async {
    await tester.pumpWidget(const CarSpotApp());

    expect(find.text('CarSpot'), findsOneWidget);
    expect(find.text('Where did you park?'), findsOneWidget);

    await tester.tap(find.text('Save my parking spot'));
    await tester.pump();

    expect(find.text('Guide me'), findsOneWidget);
    expect(find.text('Found it'), findsOneWidget);
    expect(find.textContaining('min walk'), findsOneWidget);

    // Unmount the tree so the simulated GPS timer is cancelled and no
    // timers are left pending when the test ends.
    await tester.pumpWidget(const SizedBox());
  });
}
