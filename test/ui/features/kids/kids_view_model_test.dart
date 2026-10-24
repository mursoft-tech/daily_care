import 'package:daily_care/app/providers.dart';
import 'package:daily_care/core/result.dart';
import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/domain/repositories/kids_repository.dart';
import 'package:daily_care/ui/features/kids/view_models/kids_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _children = <Child>[
  Child(
    id: 'mateo',
    firstName: 'Mateo',
    lastName: 'Fernández',
    birthDate: DateTime(2023, 3, 12),
    room: 'Soles',
    enrolledAt: DateTime(2025, 2),
    colorToken: 'blue',
  ),
  Child(
    id: 'sofia',
    firstName: 'Sofía',
    lastName: 'Méndez',
    birthDate: DateTime(2024, 5, 9),
    room: 'Soles',
    enrolledAt: DateTime(2025, 2),
    colorToken: 'pink',
  ),
];

class _FakeKidsRepository implements KidsRepository {
  int calls = 0;

  @override
  Future<Result<List<Child>>> loadChildren() async {
    calls++;
    return Success(_children);
  }

  @override
  Future<Result<Child?>> loadChild(String id) async {
    for (final child in _children) {
      if (child.id == id) return Success(child);
    }
    return const Success(null);
  }
}

void main() {
  test('filters locally and reloads on retry', () async {
    final repository = _FakeKidsRepository();
    final container = ProviderContainer.test(
      overrides: [
        kidsRepositoryProvider.overrideWithValue(repository),
        todayProvider.overrideWithValue(() => DateTime(2026, 10, 24)),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(kidsViewModelProvider, (_, _) {});
    addTearDown(subscription.close);

    final initial = await container.read(kidsViewModelProvider.future);
    expect(initial.all, hasLength(2));
    expect(initial.ageOf(initial.all.first), 3);
    expect(repository.calls, 1);

    container.read(kidsViewModelProvider.notifier).search('sofia');
    final filtered = container.read(kidsViewModelProvider).value!;
    expect(filtered.visible.single.firstName, 'Sofía');
    expect(filtered.ageOf(filtered.visible.single), 2);
    expect(repository.calls, 1);

    container.read(kidsViewModelProvider.notifier).retry();
    await container.read(kidsViewModelProvider.future);
    expect(repository.calls, 2);
  });
}
