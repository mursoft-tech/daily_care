import 'package:daily_care/app/providers.dart';
import 'package:daily_care/core/result.dart';
import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/domain/repositories/kids_repository.dart';
import 'package:daily_care/ui/features/kids/view_models/kids_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _children = <Child>[
  Child(
    id: 'mateo',
    firstName: 'Mateo',
    lastName: 'Fernández',
    ageYears: 3,
    linkedParents: 2,
    colorToken: 'blue',
  ),
  Child(
    id: 'sofia',
    firstName: 'Sofía',
    lastName: 'Méndez',
    ageYears: 2,
    linkedParents: 1,
    colorToken: 'pink',
  ),
];

class _FakeKidsRepository implements KidsRepository {
  int calls = 0;

  @override
  Future<Result<List<Child>>> loadChildren() async {
    calls++;
    return const Success(_children);
  }
}

void main() {
  test('filters locally and reloads on retry', () async {
    final repository = _FakeKidsRepository();
    final container = ProviderContainer.test(
      overrides: [kidsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(kidsViewModelProvider, (_, _) {});
    addTearDown(subscription.close);

    final initial = await container.read(kidsViewModelProvider.future);
    expect(initial.all, hasLength(2));
    expect(repository.calls, 1);

    container.read(kidsViewModelProvider.notifier).search('sofia');
    final filtered = container.read(kidsViewModelProvider).value!;
    expect(filtered.visible.single.firstName, 'Sofía');
    expect(repository.calls, 1);

    container.read(kidsViewModelProvider.notifier).retry();
    await container.read(kidsViewModelProvider.future);
    expect(repository.calls, 2);
  });
}
