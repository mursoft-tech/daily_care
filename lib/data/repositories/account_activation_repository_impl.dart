import '../../core/result.dart';
import '../../domain/models/account_invitation.dart';
import '../../domain/repositories/account_activation_repository.dart';
import '../datasources/account_activation_data_source.dart';

class AccountActivationRepositoryImpl implements AccountActivationRepository {
  const AccountActivationRepositoryImpl(this._dataSource);

  final AccountActivationDataSource _dataSource;

  @override
  Future<Result<AccountInvitation?>> loadInvitation(String code) async {
    try {
      return Success(await _dataSource.fetchInvitation(code));
    } on Exception {
      return const Failure(DataFailure());
    } catch (_) {
      return const Failure(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> activate({
    required AccountInvitation invitation,
    required String password,
    required bool photoConsent,
  }) async {
    try {
      await _dataSource.activate(
        invitation: invitation,
        password: password,
        photoConsent: photoConsent,
      );
      return const Success(null);
    } on Exception {
      return const Failure(DataFailure());
    } catch (_) {
      return const Failure(UnexpectedFailure());
    }
  }
}
