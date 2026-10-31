import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/domain/value_objects/allergy.dart';
import 'package:daily_care/ui/features/kids/widgets/child_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _pumpCard(Child child, {required int ageYears}) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: appSupportedLocales,
    theme: buildAppTheme(),
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 360,
          child: ChildCard(child: child, ageYears: ageYears),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the allergy badge instead of VINCULAR', (tester) async {
    await tester.pumpWidget(
      _pumpCard(
        Child(
          id: 'mateo',
          firstName: 'Mateo',
          lastName: 'Fernández',
          birthDate: DateTime(2023, 3, 12),
          room: 'Soles',
          enrolledAt: DateTime(2025, 2),
          colorToken: 'blue',
          allergies: const [Allergy(label: 'MANÍ', notes: 'Alergia al maní.')],
        ),
        ageYears: 3,
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
        Child(
          id: 'valentina',
          firstName: 'Valentina',
          lastName: 'Soto',
          birthDate: DateTime(2024, 7, 1),
          room: 'Soles',
          enrolledAt: DateTime(2025, 1),
          colorToken: 'yellow',
        ),
        ageYears: 2,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('VINCULAR'), findsOneWidget);
    expect(find.text('2 años · sin padres vinculados'), findsOneWidget);
  });

  testWidgets('summarizes several allergies in one badge', (tester) async {
    await tester.pumpWidget(
      _pumpCard(
        Child(
          id: 'tomas',
          firstName: 'Tomás',
          lastName: 'Díaz',
          birthDate: DateTime(2023, 1, 30),
          room: 'Soles',
          enrolledAt: DateTime(2025, 2),
          colorToken: 'purple',
          allergies: const [
            Allergy(label: 'MANÍ', notes: ''),
            Allergy(label: 'LACTOSA', notes: ''),
          ],
        ),
        ageYears: 3,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MANÍ +1'), findsOneWidget);
    expect(find.text('LACTOSA'), findsNothing);
  });
}
