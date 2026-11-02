import '../../domain/models/child.dart';
import '../../domain/models/guardian.dart';

abstract interface class KidsDataSource {
  Future<List<Child>> fetchChildren();

  Future<Child?> fetchChild(String id);

  Future<void> saveChild(Child child);

  Future<Guardian> linkGuardian({
    required String childId,
    required String fullName,
    required String email,
    required GuardianRelationship relationship,
    required String invitationCode,
  });
}
