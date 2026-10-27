import 'package:flutter_test/flutter_test.dart';

import 'package:dispatch_probe/main.dart';

void main() {
  testWidgets('smoke test: app renders and counter increments on tap',
      (tester) async {
    await tester.pumpWidget(const DispatchProbeApp());

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.text('0'));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
