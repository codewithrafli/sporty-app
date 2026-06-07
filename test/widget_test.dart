import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportly_app/presentation/widgets/primary_button.dart';

void main() {
  testWidgets('primary button renders its action', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'Join Event',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Join Event'), findsOneWidget);
    await tester.tap(find.text('Join Event'));
    expect(pressed, isTrue);
  });
}
