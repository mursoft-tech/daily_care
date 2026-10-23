import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/ui/features/login/views/login_placeholder_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('shows a placeholder without credential inputs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: appSupportedLocales,
        theme: buildAppTheme(),
        home: const LoginPlaceholderView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inicio de sesión en preparación'), findsOneWidget);
    expect(find.byKey(const Key('login-back')), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
  });
}
