import 'package:daily_care/app/app.dart';
import 'package:daily_care/ui/features/feed/widgets/composer_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('creates a post for a child and shows it first in the feed', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ComposerBar));
    await tester.pumpAndSettle();
    expect(find.text('PARA'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('composer-recipient-mateo-fernandez')),
    );
    await tester.tap(
      find.byKey(const Key('composer-recipient-sofia-mendez')),
    );
    await tester.tap(find.byKey(const Key('composer-type-mood')));
    await tester.enterText(
      find.byKey(const Key('composer-description')),
      'Leímos un cuento nuevo y Mateo eligió el final',
    );

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    final publishButton = find.byKey(const Key('composer-publish'));
    await tester.ensureVisible(publishButton);
    await tester.pumpAndSettle();
    await tester.tap(publishButton);
    await tester.pumpAndSettle();

    expect(find.text('PUBLICADO HOY'), findsOneWidget);
    expect(
      find.text('Leímos un cuento nuevo y Mateo eligió el final'),
      findsOneWidget,
    );
    expect(find.text('ÁNIMO'), findsOneWidget);
    expect(find.text('Para: familias de Mateo y Sofía'), findsOneWidget);
    expect(find.text('Próximamente'), findsNothing);
  });
}
