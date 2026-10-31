import '../../core/result.dart';
import '../models/child.dart';

abstract class KidsRepository {
  Future<Result<List<Child>>> loadChildren();

  Future<Result<Child?>> loadChild(String id);

  Future<Result<Child>> addChild(Child child);
}
