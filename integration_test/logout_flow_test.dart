import 'package:daily_care/app/app.dart';
import 'package:daily_care/app/providers.dart';
import 'package:daily_care/core/result.dart';
import 'package:daily_care/domain/models/post.dart';
import 'package:daily_care/domain/repositories/feed_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

class _FakeFeedRepository implements FeedRepository {
  @override
  Future<Result<List<Post>>> loadPosts() async => const Success([]);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('logout from the compact shell opens the login placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [feedRepositoryProvider.overrideWithValue(_FakeFeedRepository())],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('app-menu-button')));
    await tester.pumpAndSettle();
    expect(find.text('Caro Giménez'), findsOneWidget);

    final logoutRect = tester.getRect(
      find.byKey(const Key('app-panel-logout')),
    );
    await tester.tapAt(logoutRect.topLeft + const Offset(3, 3));
    await tester.pumpAndSettle();

    expect(find.text('Inicio de sesión en preparación'), findsOneWidget);
    expect(find.byKey(const Key('app-drawer')), findsNothing);
  });
}
