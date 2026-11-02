import '../../core/result.dart';
import '../models/child.dart';
import '../models/guardian.dart';

abstract class KidsRepository {
  Future<Result<List<Child>>> loadChildren();

  Future<Result<Child?>> loadChild(String id);

  Future<Result<Child>> addChild(Child child);

  Future<Result<Guardian>> linkGuardian({
    required String childId,
    required String fullName,
    required String email,
    required GuardianRelationship relationship,
    required String invitationCode,
  });
}
