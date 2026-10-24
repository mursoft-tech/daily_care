import 'package:daily_care/core/result.dart';
import 'package:daily_care/data/datasources/kids_data_source.dart';
import 'package:daily_care/data/datasources/local/demo_kids_data_source.dart';
import 'package:daily_care/data/repositories/kids_repository_impl.dart';
import 'package:daily_care/domain/models/child.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailingDataSource implements KidsDataSource {
  @override
  Future<List<Child>> fetchChildren() async => throw Exception('boom');
}

void main() {
  group('KidsRepositoryImpl', () {
    test('returns Success with the eight demo children', () async {
      final repository = KidsRepositoryImpl(const DemoKidsDataSource());

      final result = await repository.loadChildren();

      expect(result, isA<Success<List<Child>>>());
      final children = (result as Success<List<Child>>).value;
      expect(children, hasLength(8));
      expect(children.first.fullName, 'Mateo Fernández');
      expect(children.last.fullName, 'Olivia Vega');
    });

    test('returns Failure when the data source fails', () async {
      final repository = KidsRepositoryImpl(_FailingDataSource());

      final result = await repository.loadChildren();

      expect(result, isA<Failure<List<Child>>>());
      expect((result as Failure<List<Child>>).failure, isA<DataFailure>());
    });
  });
}
