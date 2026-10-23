import 'package:daily_care/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('starts the app on the home route', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    expect(find.text('Buenas, Caro'), findsOneWidget);
    expect(find.text('PUBLICADO HOY'), findsOneWidget);
  });
}
