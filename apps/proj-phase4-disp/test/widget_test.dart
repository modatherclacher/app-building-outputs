import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dispatch_probe/main.dart';

void main() {
  testWidgets('smoke test: app pumps, counter taps and resets', (
    tester,
  ) async {
    await tester.pumpWidget(const DispatchProbeApp());

    expect(find.byKey(const Key('counter_value')), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tap_area')));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('reset_button')));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  });
}
