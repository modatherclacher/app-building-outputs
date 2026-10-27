import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recipe_card/main.dart';

void main() {
  testWidgets('recipe card renders, scales servings and checks ingredients',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RecipeCardApp());

    expect(find.text('Recipe Card'), findsOneWidget);
    expect(find.text('Fluffy Buttermilk Pancakes'), findsOneWidget);

    await tester.tap(find.text('Fluffy Buttermilk Pancakes'));
    await tester.pumpAndSettle();

    expect(find.text('Servings'), findsOneWidget);
    expect(find.text('0 of 8 checked'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNWidgets(8));

    await tester.tap(find.byKey(const ValueKey('servings-plus')));
    await tester.pump();

    expect(
      tester.widget<Text>(find.byKey(const ValueKey('servings-count'))).data,
      '5',
    );
    expect(find.text('2½ cups all-purpose flour'), findsOneWidget);

    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pump();

    expect(find.text('1 of 8 checked'), findsOneWidget);
  });
}
