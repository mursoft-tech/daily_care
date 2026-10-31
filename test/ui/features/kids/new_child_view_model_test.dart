import 'package:daily_care/app/providers.dart';
import 'package:daily_care/core/result.dart';
import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/domain/repositories/kids_repository.dart';
import 'package:daily_care/domain/use_cases/create_child.dart';
import 'package:daily_care/domain/value_objects/child_draft.dart';
import 'package:daily_care/ui/features/kids/view_models/new_child_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeKidsRepository implements KidsRepository {
  _FakeKidsRepository({this.saveFailure});

  final AppFailure? saveFailure;
  final List<Child> children = <Child>[];

  @override
  Future<Result<List<Child>>> loadChildren() async =>
      Success(List.unmodifiable(children));

  @override
  Future<Result<Child?>> loadChild(String id) async => const Success(null);

  @override
  Future<Result<Child>> addChild(Child child) async {
    final failure = saveFailure;
    if (failure != null) return Failure(failure);
    children.add(child);
    return Success(child);
  }
}

const _draft = ChildDraft(
  fullName: 'Martina López',
  birthDateText: '12/03/2023',
  room: 'Soles',
);

ProviderContainer _container(_FakeKidsRepository repository) {
  return ProviderContainer.test(
    overrides: [
      kidsRepositoryProvider.overrideWithValue(repository),
      todayProvider.overrideWithValue(() => DateTime(2026, 10, 24)),
    ],
  );
}

void main() {
  test('starts idle', () {
    final container = _container(_FakeKidsRepository());
    final state = container.read(newChildViewModelProvider);

    expect(state.isSaving, isFalse);
    expect(state.errors, isEmpty);
    expect(state.saved, isFalse);
  });

  test('saves a valid draft and exposes the child', () async {
    final repository = _FakeKidsRepository();
    final container = _container(repository);

    final child = await container
        .read(newChildViewModelProvider.notifier)
        .submit(_draft);

    expect(child, isNotNull);
    expect(child!.fullName, 'Martina López');
    expect(container.read(newChildViewModelProvider).saved, isTrue);
    expect(container.read(newChildViewModelProvider).isSaving, isFalse);
    expect(repository.children, hasLength(1));
  });

  test('exposes the validation error', () async {
    final container = _container(_FakeKidsRepository());

    final child = await container
        .read(newChildViewModelProvider.notifier)
        .submit(
          const ChildDraft(
            fullName: 'Martina López',
            birthDateText: '31/02/2023',
            room: 'Soles',
          ),
        );

    expect(child, isNull);
    expect(
      container.read(newChildViewModelProvider).errors,
      contains(RegistrationError.birthDateInvalid),
    );
  });

  test('maps a storage failure to the generic save error', () async {
    final container = _container(
      _FakeKidsRepository(saveFailure: const DataFailure()),
    );

    final child = await container
        .read(newChildViewModelProvider.notifier)
        .submit(_draft);

    expect(child, isNull);
    expect(
      container.read(newChildViewModelProvider).errors,
      [RegistrationError.saveFailed],
    );
  });

  test('clears the error and resets the state', () async {
    final container = _container(_FakeKidsRepository());
    final notifier = container.read(newChildViewModelProvider.notifier);

    await notifier.submit(
      const ChildDraft(
        fullName: '',
        birthDateText: '',
        room: 'Soles',
      ),
    );
    expect(container.read(newChildViewModelProvider).errors, isNotEmpty);

    notifier.clearErrors();
    expect(container.read(newChildViewModelProvider).errors, isEmpty);

    await notifier.submit(_draft);
    notifier.reset();
    expect(container.read(newChildViewModelProvider).saved, isFalse);
  });
}
