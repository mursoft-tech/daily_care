import '../../domain/models/child.dart';

abstract interface class KidsDataSource {
  Future<List<Child>> fetchChildren();
}
