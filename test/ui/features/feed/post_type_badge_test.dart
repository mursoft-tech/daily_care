import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/domain/models/post_type.dart';
import 'package:daily_care/ui/features/feed/widgets/post_type_badge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('renders a label for all seven post types', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: appSupportedLocales,
        theme: buildAppTheme(),
        home: const Scaffold(
          body: Wrap(
            children: [
              PostTypeBadge(type: PostType.food),
              PostTypeBadge(type: PostType.nap),
              PostTypeBadge(type: PostType.activity),
              PostTypeBadge(type: PostType.achievement),
              PostTypeBadge(type: PostType.mood),
              PostTypeBadge(type: PostType.photo),
              PostTypeBadge(type: PostType.announcement),
            ],
          ),
        ),
      ),
    );

    expect(find.text('COMIDA'), findsOneWidget);
    expect(find.text('SIESTA'), findsOneWidget);
    expect(find.text('ACTIVIDAD'), findsOneWidget);
    expect(find.text('LOGRO'), findsOneWidget);
    expect(find.text('ÁNIMO'), findsOneWidget);
    expect(find.text('FOTO'), findsOneWidget);
    expect(find.text('ANUNCIO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
