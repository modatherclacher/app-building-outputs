import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:b3_verification/main.dart';

void main() {
  testWidgets('tip calculator renders and updates totals', (tester) async {
    await tester.pumpWidget(const TipCalculatorApp());

    expect(find.text('Tip Calculator'), findsOneWidget);
    expect(find.text('Bill amount'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('\$0.00'), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), '40');
    await tester.pump();

    expect(find.text('\$6.00'), findsOneWidget);
    expect(find.text('\$46.00'), findsOneWidget);
  });
}
