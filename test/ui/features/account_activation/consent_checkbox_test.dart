import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/theme/app_colors.dart';
import 'package:daily_care/ui/features/account_activation/widgets/consent_checkbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _buildConsent({
  required bool value,
  required ValueChanged<bool> onChanged,
  String? errorText,
}) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: appSupportedLocales,
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ConsentCheckbox(
          value: value,
          onChanged: onChanged,
          errorText: errorText,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('starts unchecked and exposes the accessible state', (
    tester,
  ) async {
    await tester.pumpWidget(_buildConsent(value: false, onChanged: (_) {}));

    expect(find.byIcon(Icons.check), findsNothing);

    final semantics = tester.widget<Semantics>(
      find.byKey(const Key('consent-semantics')),
    );
    expect(semantics.properties.checked, isFalse);
  });

  testWidgets('toggles when tapped and shows the check', (tester) async {
    var value = false;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return _buildConsent(
            value: value,
            onChanged: (next) => setState(() => value = next),
          );
        },
      ),
    );

    expect(find.byIcon(Icons.check), findsNothing);

    await tester.tap(find.textContaining('Autorizo a la guardería'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(
      tester
          .widget<Semantics>(find.byKey(const Key('consent-semantics')))
          .properties
          .checked,
      isTrue,
    );

    await tester.tap(find.textContaining('Autorizo a la guardería'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('renders the consent error in coral', (tester) async {
    await tester.pumpWidget(
      _buildConsent(
        value: false,
        onChanged: (_) {},
        errorText: 'Necesitamos tu autorización para continuar',
      ),
    );

    final error = tester.widget<Text>(
      find.text('Necesitamos tu autorización para continuar'),
    );
    expect(error.style?.color, AppColors.primaryDark);
  });
}
