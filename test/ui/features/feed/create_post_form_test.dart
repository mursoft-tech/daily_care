import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/providers.dart';
import 'package:daily_care/app/theme/app_colors.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/core/result.dart';
import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/domain/models/guardian.dart';
import 'package:daily_care/domain/models/post.dart';
import 'package:daily_care/domain/models/post_type.dart';
import 'package:daily_care/domain/repositories/feed_repository.dart';
import 'package:daily_care/domain/repositories/kids_repository.dart';
import 'package:daily_care/domain/use_cases/create_post.dart';
import 'package:daily_care/domain/value_objects/post_draft.dart';
import 'package:daily_care/ui/features/feed/widgets/create_post_form.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _FakeKidsRepository implements KidsRepository {
  _FakeKidsRepository(this.children);

  final List<Child> children;

  @override
  Future<Result<List<Child>>> loadChildren() async =>
      Success(List.unmodifiable(children));

  @override
  Future<Result<Child?>> loadChild(String id) async => const Success(null);

  @override
  Future<Result<Child>> addChild(Child child) async => Success(child);

  @override
  Future<Result<Guardian>> linkGuardian({
    required String childId,
    required String fullName,
    required String email,
    required GuardianRelationship relationship,
    required String invitationCode,
  }) async {
    throw UnimplementedError();
  }
}

class _FakeFeedRepository implements FeedRepository {
  @override
  Future<Result<List<Post>>> loadPosts() async => const Success(<Post>[]);

  @override
  Future<Result<Post>> createPost(Post post) async => Success(post);
}

Child _child(String id, String name, String token) => Child(
  id: id,
  firstName: name,
  lastName: 'Test',
  birthDate: DateTime(2023, 1, 1),
  room: 'Soles',
  enrolledAt: DateTime(2025, 1),
  colorToken: token,
);

Widget _pumpForm({
  List<PostDraftError> errors = const [],
  Future<void> Function(PostDraft draft)? onSubmit,
  VoidCallback? onCancel,
}) {
  return ProviderScope(
    overrides: [
      kidsRepositoryProvider.overrideWithValue(
        _FakeKidsRepository([
          _child('mateo-fernandez', 'Mateo', 'blue'),
          _child('sofia-mendez', 'Sofía', 'pink'),
        ]),
      ),
      feedRepositoryProvider.overrideWithValue(_FakeFeedRepository()),
    ],
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      theme: buildAppTheme(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: CreatePostForm(
            isSaving: false,
            errors: errors,
            onSubmit: onSubmit ?? (_) async {},
            onCancel: onCancel ?? () {},
          ),
        ),
      ),
    ),
  );
}

Color _chipColor(WidgetTester tester, Key key) {
  final container = tester.widget<Container>(
    find.descendant(of: find.byKey(key), matching: find.byType(Container)).first,
  );
  return (container.decoration! as BoxDecoration).color!;
}

Future<void> _tapChild(WidgetTester tester, String id) async {
  await tester.tap(find.byKey(Key('composer-recipient-$id')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the seven types with the room selected by default', (
    tester,
  ) async {
    await tester.pumpWidget(_pumpForm());
    await tester.pumpAndSettle();

    expect(find.text('COMIDA'), findsOneWidget);
    expect(find.text('SIESTA'), findsOneWidget);
    expect(find.text('ACTIVIDAD'), findsOneWidget);
    expect(find.text('LOGRO'), findsOneWidget);
    expect(find.text('ÁNIMO'), findsOneWidget);
    expect(find.text('FOTO'), findsOneWidget);
    expect(find.text('ANUNCIO'), findsOneWidget);
    expect(find.text('Toda la sala'), findsOneWidget);
    expect(find.text('Mateo'), findsOneWidget);
    expect(find.text('Sofía'), findsOneWidget);
    expect(
      _chipColor(tester, const Key('composer-recipient-room')),
      AppColors.textStrong,
    );
    expect(
      _chipColor(tester, const Key('composer-recipient-mateo-fernandez')),
      AppColors.surface,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('composer-type-activity')),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('selecting a child deselects the room', (tester) async {
    await tester.pumpWidget(_pumpForm());
    await tester.pumpAndSettle();

    await _tapChild(tester, 'mateo-fernandez');

    expect(
      _chipColor(tester, const Key('composer-recipient-room')),
      AppColors.surface,
    );
    expect(
      _chipColor(tester, const Key('composer-recipient-mateo-fernandez')),
      AppColors.textStrong,
    );
  });

  testWidgets('keeps several children selected at once', (tester) async {
    await tester.pumpWidget(_pumpForm());
    await tester.pumpAndSettle();

    await _tapChild(tester, 'mateo-fernandez');
    await _tapChild(tester, 'sofia-mendez');

    expect(
      _chipColor(tester, const Key('composer-recipient-mateo-fernandez')),
      AppColors.textStrong,
    );
    expect(
      _chipColor(tester, const Key('composer-recipient-sofia-mendez')),
      AppColors.textStrong,
    );
    expect(
      _chipColor(tester, const Key('composer-recipient-room')),
      AppColors.surface,
    );
  });

  testWidgets('removing one of several keeps the others selected', (
    tester,
  ) async {
    await tester.pumpWidget(_pumpForm());
    await tester.pumpAndSettle();

    await _tapChild(tester, 'mateo-fernandez');
    await _tapChild(tester, 'sofia-mendez');
    await _tapChild(tester, 'mateo-fernandez');

    expect(
      _chipColor(tester, const Key('composer-recipient-mateo-fernandez')),
      AppColors.surface,
    );
    expect(
      _chipColor(tester, const Key('composer-recipient-sofia-mendez')),
      AppColors.textStrong,
    );
  });

  testWidgets('removing the last child selects the room again', (tester) async {
    await tester.pumpWidget(_pumpForm());
    await tester.pumpAndSettle();

    await _tapChild(tester, 'mateo-fernandez');
    await _tapChild(tester, 'mateo-fernandez');

    expect(
      _chipColor(tester, const Key('composer-recipient-room')),
      AppColors.textStrong,
    );
  });

  testWidgets('selecting the room clears every child', (tester) async {
    await tester.pumpWidget(_pumpForm());
    await tester.pumpAndSettle();

    await _tapChild(tester, 'mateo-fernandez');
    await _tapChild(tester, 'sofia-mendez');
    await tester.tap(find.byKey(const Key('composer-recipient-room')));
    await tester.pumpAndSettle();

    expect(
      _chipColor(tester, const Key('composer-recipient-room')),
      AppColors.textStrong,
    );
    expect(
      _chipColor(tester, const Key('composer-recipient-mateo-fernandez')),
      AppColors.surface,
    );
    expect(
      _chipColor(tester, const Key('composer-recipient-sofia-mendez')),
      AppColors.surface,
    );
  });

  testWidgets('only one type stays selected', (tester) async {
    await tester.pumpWidget(_pumpForm());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('composer-type-food')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('composer-type-food')),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('composer-type-activity')),
        matching: find.byIcon(Icons.check),
      ),
      findsNothing,
    );
  });

  testWidgets('shows the required description error', (tester) async {
    await tester.pumpWidget(
      _pumpForm(errors: const [PostDraftError.bodyRequired]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Contá cómo le fue hoy'), findsWidgets);
  });

  testWidgets('publishes every selected recipient with the type and text', (
    tester,
  ) async {
    PostDraft? captured;
    await tester.pumpWidget(
      _pumpForm(onSubmit: (draft) async => captured = draft),
    );
    await tester.pumpAndSettle();

    await _tapChild(tester, 'mateo-fernandez');
    await _tapChild(tester, 'sofia-mendez');
    await tester.enterText(
      find.byKey(const Key('composer-description')),
      'Almorzaron guiso',
    );
    await tester.tap(find.byKey(const Key('composer-type-food')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('composer-publish')));
    await tester.pumpAndSettle();

    expect(captured?.childIds, ['mateo-fernandez', 'sofia-mendez']);
    expect(captured?.type, PostType.food);
    expect(captured?.body, 'Almorzaron guiso');
  });

  testWidgets('publishes to the room when no child is selected', (
    tester,
  ) async {
    PostDraft? captured;
    await tester.pumpWidget(
      _pumpForm(onSubmit: (draft) async => captured = draft),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('composer-description')),
      'Aviso general',
    );
    await tester.tap(find.byKey(const Key('composer-publish')));
    await tester.pumpAndSettle();

    expect(captured?.childIds, isEmpty);
  });

  testWidgets('adding a photo shows the coming soon notice', (tester) async {
    await tester.pumpWidget(_pumpForm());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('composer-add-photo')));
    await tester.pumpAndSettle();

    expect(find.text('Próximamente'), findsOneWidget);
  });

  testWidgets('cancel invokes the callback', (tester) async {
    var cancelled = 0;
    await tester.pumpWidget(_pumpForm(onCancel: () => cancelled++));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('composer-cancel')));
    await tester.pumpAndSettle();

    expect(cancelled, 1);
  });
}
