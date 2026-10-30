import 'package:daily_care/app/providers.dart';
import 'package:daily_care/core/result.dart';
import 'package:daily_care/domain/models/account_invitation.dart';
import 'package:daily_care/domain/repositories/account_activation_repository.dart';
import 'package:daily_care/domain/use_cases/activate_account.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAccountActivationRepository implements AccountActivationRepository {
  @override
  Future<Result<AccountInvitation?>> loadInvitation(String code) async {
    return const Success(null);
  }

  @override
  Future<Result<void>> activate({
    required AccountInvitation invitation,
    required String password,
    required bool photoConsent,
  }) async {
    return const Success(null);
  }
}

void main() {
  test('sessionUserProvider expone el usuario de demostración', () {
    final container = ProviderContainer.test();

    final user = container.read(sessionUserProvider);

    expect(user.fullName, 'Caro Giménez');
    expect(container.read(sessionUserProvider), same(user));
  });

  test('todayProvider can be overridden with a fixed date', () {
    final fixed = DateTime(2026, 10, 24);
    final container = ProviderContainer.test(
      overrides: [todayProvider.overrideWithValue(() => fixed)],
    );

    expect(container.read(todayProvider)(), fixed);
  });

  test('activateAccountUseCaseProvider usa el repositorio sobrescrito', () async {
    final fake = _FakeAccountActivationRepository();
    final container = ProviderContainer.test(
      overrides: [
        accountActivationRepositoryProvider.overrideWithValue(fake),
      ],
    );

    final result = await container.read(activateAccountUseCaseProvider).execute(
      invitation: null,
      code: '7K4P9',
      email: 'lucia.fernandez@gmail.com',
      password: 'secreto123',
      photoConsent: true,
    );

    expect(result, isA<ActivationRejected>());
    expect((result as ActivationRejected).error, ActivationError.invalidCode);
  });
}
