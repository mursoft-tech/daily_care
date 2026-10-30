import 'package:daily_care/app/providers.dart';
import 'package:daily_care/core/result.dart';
import 'package:daily_care/domain/models/account_invitation.dart';
import 'package:daily_care/domain/repositories/account_activation_repository.dart';
import 'package:daily_care/domain/use_cases/activate_account.dart';
import 'package:daily_care/ui/features/account_activation/view_models/activate_account_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _invitation = AccountInvitation(
  code: '7K4P9',
  email: 'lucia.fernandez@gmail.com',
  childName: 'Mateo',
  roomName: 'Sala Soles',
);

class _FakeRepository implements AccountActivationRepository {
  AccountInvitation? invitation = _invitation;
  bool loadFails = false;
  bool activateFails = false;

  @override
  Future<Result<AccountInvitation?>> loadInvitation(String code) async {
    if (loadFails) return const Failure(DataFailure());
    return Success(invitation);
  }

  @override
  Future<Result<void>> activate({
    required AccountInvitation invitation,
    required String password,
    required bool photoConsent,
  }) async {
    return activateFails
        ? const Failure(DataFailure())
        : const Success(null);
  }
}

void main() {
  group('ActivateAccountViewModel', () {
    late _FakeRepository repository;

    ProviderContainer createContainer() {
      final container = ProviderContainer.test(
        overrides: [
          accountActivationRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    setUp(() {
      repository = _FakeRepository();
    });

    test('loads the invitation and prefills the email', () async {
      final container = createContainer();
      final state = await container.read(
        activateAccountViewModelProvider('7K4P9').future,
      );

      expect(state.invitation?.childName, 'Mateo');
      expect(state.code, '7K4P9');
      expect(state.email, 'lucia.fernandez@gmail.com');
      expect(state.photoConsent, isFalse);
      expect(state.errorType, isNull);
    });

    test('exposes an AsyncError when the invitation cannot be loaded', () async {
      repository.loadFails = true;
      final container = createContainer();

      await expectLater(
        container.read(activateAccountViewModelProvider('7K4P9').future),
        throwsA(isA<AppFailure>()),
      );
    });

    test('retry reloads the invitation after a failure', () async {
      repository.loadFails = true;
      final container = createContainer();
      final provider = activateAccountViewModelProvider('7K4P9');

      await expectLater(
        container.read(provider.future),
        throwsA(isA<AppFailure>()),
      );

      repository.loadFails = false;
      container.read(provider.notifier).retry();

      final state = await container.read(provider.future);
      expect(state.invitation, isNotNull);
    });

    test('clears the validation error when the user edits a field', () async {
      final container = createContainer();
      final provider = activateAccountViewModelProvider('7K4P9');
      await container.read(provider.future);
      final notifier = container.read(provider.notifier);

      notifier.setPassword('secreto123');
      notifier.setPhotoConsent(true);
      await notifier.submit();
      expect(container.read(provider).requireValue.errorType, isNull);

      notifier.setEmail('otro@correo.com');
      await notifier.submit();
      expect(
        container.read(provider).requireValue.errorType,
        ActivationError.emailMismatch,
      );

      notifier.setEmail('lucia.fernandez@gmail.com');
      expect(container.read(provider).requireValue.errorType, isNull);
    });

    test('submit is accepted with valid data and consent', () async {
      final container = createContainer();
      final provider = activateAccountViewModelProvider('7K4P9');
      await container.read(provider.future);
      final notifier = container.read(provider.notifier);

      notifier.setPassword('secreto123');
      notifier.setPhotoConsent(true);

      expect(await notifier.submit(), isTrue);
      expect(container.read(provider).requireValue.isActivated, isTrue);
    });

    test('submit rejects each validation error', () async {
      final container = createContainer();
      final provider = activateAccountViewModelProvider('7K4P9');
      await container.read(provider.future);
      final notifier = container.read(provider.notifier);

      notifier.setPassword('corta');
      await notifier.submit();
      expect(
        container.read(provider).requireValue.errorType,
        ActivationError.weakPassword,
      );

      notifier.setPassword('');
      await notifier.submit();
      expect(
        container.read(provider).requireValue.errorType,
        ActivationError.emptyPassword,
      );

      notifier.setCode('XXXXX');
      notifier.setPassword('secreto123');
      await notifier.submit();
      expect(
        container.read(provider).requireValue.errorType,
        ActivationError.invalidCode,
      );

      notifier.setCode('7K4P9');
      notifier.setEmail('invalido');
      await notifier.submit();
      expect(
        container.read(provider).requireValue.errorType,
        ActivationError.invalidEmail,
      );

      notifier.setEmail('lucia.fernandez@gmail.com');
      await notifier.submit();
      expect(
        container.read(provider).requireValue.errorType,
        ActivationError.consentRequired,
      );
    });

    test('flags a generic failure when activation cannot complete', () async {
      repository.activateFails = true;
      final container = createContainer();
      final provider = activateAccountViewModelProvider('7K4P9');
      await container.read(provider.future);
      final notifier = container.read(provider.notifier);

      notifier.setPassword('secreto123');
      notifier.setPhotoConsent(true);

      expect(await notifier.submit(), isFalse);
      expect(container.read(provider).requireValue.submitFailed, isTrue);
    });
  });
}
