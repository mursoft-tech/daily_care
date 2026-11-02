import '../../core/result.dart';
import '../../domain/models/child.dart';
import '../../domain/models/guardian.dart';
import '../../domain/repositories/kids_repository.dart';
import '../datasources/kids_data_source.dart';

class KidsRepositoryImpl implements KidsRepository {
  const KidsRepositoryImpl(this._dataSource);

  final KidsDataSource _dataSource;

  @override
  Future<Result<List<Child>>> loadChildren() async {
    try {
      return Success(await _dataSource.fetchChildren());
    } on Exception {
      return const Failure(DataFailure());
    } catch (_) {
      return const Failure(UnexpectedFailure());
    }
  }

  @override
  Future<Result<Child?>> loadChild(String id) async {
    try {
      return Success(await _dataSource.fetchChild(id));
    } on Exception {
      return const Failure(DataFailure());
    } catch (_) {
      return const Failure(UnexpectedFailure());
    }
  }

  @override
  Future<Result<Child>> addChild(Child child) async {
    try {
      await _dataSource.saveChild(child);
      return Success(child);
    } on Exception {
      return const Failure(DataFailure());
    } catch (_) {
      return const Failure(UnexpectedFailure());
    }
  }

  @override
  Future<Result<Guardian>> linkGuardian({
    required String childId,
    required String fullName,
    required String email,
    required GuardianRelationship relationship,
    required String invitationCode,
  }) async {
    try {
      final child = await _dataSource.fetchChild(childId);
      final normalizedEmail = email.trim().toLowerCase();
      final alreadyLinked =
          child != null &&
          child.guardians.any(
            (guardian) => guardian.normalizedEmail == normalizedEmail,
          );
      if (alreadyLinked) {
        return const Failure(GuardianAlreadyLinkedFailure());
      }

      final guardian = await _dataSource.linkGuardian(
        childId: childId,
        fullName: fullName,
        email: email,
        relationship: relationship,
        invitationCode: invitationCode,
      );
      return Success(guardian);
    } on Exception {
      return const Failure(DataFailure());
    } catch (_) {
      return const Failure(UnexpectedFailure());
    }
  }
}
