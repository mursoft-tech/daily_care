import 'package:daily_care/app/providers.dart';
import 'package:daily_care/core/result.dart';
import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/domain/repositories/kids_repository.dart';
import 'package:daily_care/ui/features/kids/view_models/child_profile_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _mateo = Child(
  id: 'mateo-fernandez',
  firstName: 'Mateo',
  lastName: 'Fernández',
  birthDate: DateTime(2023, 3, 12),
  room: 'Soles',
  enrolledAt: DateTime(2025, 2),
  colorToken: 'blue',
);

class _FakeKidsRepository implements KidsRepository {
  _FakeKidsRepository({this.failing = false});

  bool failing;
  int childCalls = 0;

  @override
  Future<Result<List<Child>>> loadChildren() async => Success([_mateo]);

  @override
  Future<Result<Child?>> loadChild(String id) async {
    childCalls++;
    if (failing) return const Failure(DataFailure());
    return Success(id == _mateo.id ? _mateo : null);
  }

  @override
  Future<Result<Child>> addChild(Child child) async => Success(child);
}

void main() {
  group('ChildProfileViewModel', () {
    test('loads a child and derives the age', () async {
      final container = _container(repository: _FakeKidsRepository());
      addTearDown(container.dispose);
      final subscription = container.listen(
        childProfileViewModelProvider(_mateo.id),
        (_, _) {},
      );
      addTearDown(subscription.close);

      final state = await container.read(
        childProfileViewModelProvider(_mateo.id).future,
      );

      expect(state.notFound, isFalse);
      expect(state.child!.fullName, 'Mateo Fernández');
      expect(state.ageYears, 3);
    });

    test('reports an unknown child as not found', () async {
      final container = _container(
        repository: _FakeKidsRepository(),
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        childProfileViewModelProvider('inexistente'),
        (_, _) {},
      );
      addTearDown(subscription.close);

      final state = await container.read(
        childProfileViewModelProvider('inexistente').future,
      );

      expect(state.notFound, isTrue);
      expect(state.child, isNull);
      expect(state.ageYears, isNull);
    });

    test('throws the failure and retries after an error', () async {
      final repository = _FakeKidsRepository(failing: true);
      final container = _container(repository: repository);
      addTearDown(container.dispose);
      final subscription = container.listen(
        childProfileViewModelProvider(_mateo.id),
        (_, _) {},
      );
      addTearDown(subscription.close);

      await expectLater(
        container.read(childProfileViewModelProvider(_mateo.id).future),
        throwsA(isA<DataFailure>()),
      );

      repository.failing = false;
      container.read(childProfileViewModelProvider(_mateo.id).notifier).retry();

      final state = await container.read(
        childProfileViewModelProvider(_mateo.id).future,
      );
      expect(state.child!.fullName, 'Mateo Fernández');
      expect(repository.childCalls, 2);
    });
  });
}

ProviderContainer _container({required _FakeKidsRepository repository}) {
  return ProviderContainer.test(
    overrides: [
      kidsRepositoryProvider.overrideWithValue(repository),
      todayProvider.overrideWithValue(() => DateTime(2026, 10, 24)),
    ],
  );
}
