import 'package:daily_care/core/result.dart';
import 'package:daily_care/domain/models/account_invitation.dart';
import 'package:daily_care/domain/repositories/account_activation_repository.dart';
import 'package:daily_care/domain/use_cases/activate_account.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements AccountActivationRepository {
  _FakeRepository({this.fails = false});

  final bool fails;
  int activateCalls = 0;

  @override
  Future<Result<AccountInvitation?>> loadInvitation(String code) async {
    return const Success(_invitation);
  }

  @override
  Future<Result<void>> activate({
    required AccountInvitation invitation,
    required String password,
    required bool photoConsent,
  }) async {
    activateCalls++;
    return fails ? const Failure(DataFailure()) : const Success(null);
  }
}

const _invitation = AccountInvitation(
  code: '7K4P9',
  email: 'lucia.fernandez@gmail.com',
  childName: 'Mateo',
  roomName: 'Sala Soles',
);

ActivationError? _rejectedError(ActivationResult result) =>
    result is ActivationRejected ? result.error : null;

void main() {
  group('ActivateAccount', () {
    late _FakeRepository repository;
    late ActivateAccount useCase;

    setUp(() {
      repository = _FakeRepository();
      useCase = ActivateAccount(repository);
    });

    Future<ActivationResult> run({
      AccountInvitation? invitation = _invitation,
      String code = '7K4P9',
      String email = 'lucia.fernandez@gmail.com',
      String password = 'secreto123',
      bool photoConsent = true,
    }) {
      return useCase.execute(
        invitation: invitation,
        code: code,
        email: email,
        password: password,
        photoConsent: photoConsent,
      );
    }

    test('accepts valid data', () async {
      expect(await run(), isA<ActivationAccepted>());
      expect(repository.activateCalls, 1);
    });

    test('accepts the code with different case and spaces', () async {
      expect(await run(code: ' 7k4p9 '), isA<ActivationAccepted>());
    });

    test('rejects an unknown code', () async {
      expect(
        _rejectedError(await run(code: 'XXXXX')),
        ActivationError.invalidCode,
      );
      expect(repository.activateCalls, 0);
    });

    test('rejects a missing invitation', () async {
      expect(
        _rejectedError(await run(invitation: null)),
        ActivationError.invalidCode,
      );
    });

    test('rejects an invalid email format', () async {
      expect(
        _rejectedError(await run(email: 'correo-invalido')),
        ActivationError.invalidEmail,
      );
    });

    test('rejects an email that does not match the invitation', () async {
      expect(
        _rejectedError(await run(email: 'otra@correo.com')),
        ActivationError.emailMismatch,
      );
    });

    test('rejects an empty password', () async {
      expect(
        _rejectedError(await run(password: '')),
        ActivationError.emptyPassword,
      );
    });

    test('rejects a short password', () async {
      expect(
        _rejectedError(await run(password: 'corta')),
        ActivationError.weakPassword,
      );
    });

    test('rejects a missing photo consent', () async {
      expect(
        _rejectedError(await run(photoConsent: false)),
        ActivationError.consentRequired,
      );
      expect(repository.activateCalls, 0);
    });

    test('reports a data failure without exposing details', () async {
      final failing = ActivateAccount(_FakeRepository(fails: true));

      final result = await failing.execute(
        invitation: _invitation,
        code: '7K4P9',
        email: 'lucia.fernandez@gmail.com',
        password: 'secreto123',
        photoConsent: true,
      );

      expect(result, isA<ActivationFailed>());
    });
  });
}
