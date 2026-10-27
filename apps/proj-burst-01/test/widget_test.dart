import 'package:flutter_test/flutter_test.dart';

import 'package:dice_roller/main.dart';

void main() {
  testWidgets('app builds and a roll lands in history', (tester) async {
    await tester.pumpWidget(const DiceRollerApp());

    expect(find.text('Dice Roller'), findsOneWidget);
    expect(find.text('Roll'), findsOneWidget);

    await tester.tap(find.text('Roll'));
    await tester.pump();

    expect(find.text('d6 roll'), findsOneWidget);
  });
}
