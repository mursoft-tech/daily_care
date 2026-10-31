import '../../domain/models/child.dart';

abstract interface class KidsDataSource {
  Future<List<Child>> fetchChildren();

  Future<Child?> fetchChild(String id);

  Future<void> saveChild(Child child);
}
