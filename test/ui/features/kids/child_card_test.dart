import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/ui/features/kids/widgets/child_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _pumpCard(Child child) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: appSupportedLocales,
    theme: buildAppTheme(),
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 360, child: ChildCard(child: child)),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the allergy badge instead of VINCULAR', (tester) async {
    await tester.pumpWidget(
      _pumpCard(
        const Child(
          id: 'mateo',
          firstName: 'Mateo',
          lastName: 'Fernández',
          ageYears: 3,
          linkedParents: 0,
          colorToken: 'blue',
          allergyLabel: 'MANÍ',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MANÍ'), findsOneWidget);
    expect(find.text('VINCULAR'), findsNothing);
    expect(find.text('3 años · sin padres vinculados'), findsOneWidget);
  });

  testWidgets('shows VINCULAR when there are no linked parents', (
    tester,
  ) async {
    await tester.pumpWidget(
      _pumpCard(
        const Child(
          id: 'valentina',
          firstName: 'Valentina',
          lastName: 'Soto',
          ageYears: 2,
          linkedParents: 0,
          colorToken: 'yellow',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('VINCULAR'), findsOneWidget);
    expect(find.text('2 años · sin padres vinculados'), findsOneWidget);
  });
}
