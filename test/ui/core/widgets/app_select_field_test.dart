import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/ui/core/widgets/app_select_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('shows the preselected room and its options', (tester) async {
    var selected = 'Soles';
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: AppSelectField(
              label: 'SALA',
              value: selected,
              items: const ['Soles', 'Luna'],
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    expect(find.text('SALA'), findsOneWidget);
    expect(find.text('Soles'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    expect(find.text('Luna'), findsOneWidget);

    await tester.tap(find.text('Luna').last);
    await tester.pumpAndSettle();

    expect(selected, 'Luna');
    expect(find.text('Luna'), findsOneWidget);
    expect(find.text('Soles'), findsNothing);
  });
}
