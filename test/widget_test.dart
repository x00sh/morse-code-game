import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_code_game/widgets/morse_visual.dart';

void main() {
  testWidgets('MorseVisual renders dots and dashes as ·/−', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MorseVisual('... --- ...')),
      ),
    );
    expect(find.text('··· −−− ···'), findsOneWidget);
  });
}
