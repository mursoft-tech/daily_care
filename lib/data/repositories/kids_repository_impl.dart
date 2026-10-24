import '../../core/result.dart';
import '../../domain/models/child.dart';
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
}
