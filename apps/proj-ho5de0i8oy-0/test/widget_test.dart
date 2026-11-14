import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/main.dart';

void main() {
  testWidgets('app boots and shows the product catalog', (tester) async {
    await tester.pumpWidget(const StoreApp());

    expect(find.text('متجري الصغير'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('الكل'), findsOneWidget);
    expect(find.text('المتوفر: 20'), findsOneWidget);
  });
}
