import 'package:daily_care/app/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sessionUserProvider expone el usuario de demostración', () {
    final container = ProviderContainer.test();

    final user = container.read(sessionUserProvider);

    expect(user.fullName, 'Caro Giménez');
    expect(container.read(sessionUserProvider), same(user));
  });
}
