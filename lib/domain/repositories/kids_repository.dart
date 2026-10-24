import '../../core/result.dart';
import '../models/child.dart';

abstract class KidsRepository {
  Future<Result<List<Child>>> loadChildren();
}
