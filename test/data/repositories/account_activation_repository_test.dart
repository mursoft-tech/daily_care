import 'package:daily_care/core/result.dart';
import 'package:daily_care/data/datasources/account_activation_data_source.dart';
import 'package:daily_care/data/datasources/local/demo_account_activation_data_source.dart';
import 'package:daily_care/data/repositories/account_activation_repository_impl.dart';
import 'package:daily_care/domain/models/account_invitation.dart';
import 'package:flutter_test/flutter_test.dart';

class _ThrowingDataSource implements AccountActivationDataSource {
  @override
  Future<AccountInvitation?> fetchInvitation(String code) async {
    throw Exception('boom');
  }

  @override
  Future<void> activate({
    required AccountInvitation invitation,
    required String password,
    required bool photoConsent,
  }) async {
    throw Exception('boom');
  }
}

void main() {
  group('AccountActivationRepositoryImpl', () {
    const repository = AccountActivationRepositoryImpl(
      DemoAccountActivationDataSource(),
    );

    test('loads the demo invitation for its code', () async {
      final result = await repository.loadInvitation('7K4P9');

      expect(result, isA<Success<AccountInvitation?>>());
      final invitation = (result as Success<AccountInvitation?>).value;
      expect(invitation?.childName, 'Mateo');
      expect(invitation?.roomName, 'Sala Soles');
      expect(invitation?.email, 'lucia.fernandez@gmail.com');
    });

    test('normalizes the code before matching', () async {
      final result = await repository.loadInvitation('  7k4p9 ');

      expect(
        (result as Success<AccountInvitation?>).value?.code,
        '7K4P9',
      );
    });

    test('returns null for an unknown code', () async {
      final result = await repository.loadInvitation('XXXXX');

      expect((result as Success<AccountInvitation?>).value, isNull);
    });

    test('activates a valid invitation', () async {
      final result = await repository.activate(
        invitation: DemoAccountActivationDataSource.invitation,
        password: 'secreto123',
        photoConsent: true,
      );

      expect(result, isA<Success<void>>());
    });

    test('translates datasource errors into a data failure', () async {
      final failing = AccountActivationRepositoryImpl(_ThrowingDataSource());

      expect(await failing.loadInvitation('7K4P9'), isA<Failure>());
      expect(
        await failing.activate(
          invitation: DemoAccountActivationDataSource.invitation,
          password: 'secreto123',
          photoConsent: true,
        ),
        isA<Failure>(),
      );
    });
  });
}
