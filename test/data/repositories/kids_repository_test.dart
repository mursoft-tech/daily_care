import 'package:daily_care/core/result.dart';
import 'package:daily_care/data/datasources/kids_data_source.dart';
import 'package:daily_care/data/datasources/local/demo_kids_data_source.dart';
import 'package:daily_care/data/repositories/kids_repository_impl.dart';
import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/domain/models/guardian.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailingDataSource implements KidsDataSource {
  @override
  Future<List<Child>> fetchChildren() async => throw Exception('boom');

  @override
  Future<Child?> fetchChild(String id) async => throw Exception('boom');
}

void main() {
  group('KidsRepositoryImpl', () {
    final repository = KidsRepositoryImpl(const DemoKidsDataSource());

    test('returns Success with the eight demo children', () async {
      final result = await repository.loadChildren();

      expect(result, isA<Success<List<Child>>>());
      final children = (result as Success<List<Child>>).value;
      expect(children, hasLength(8));
      expect(children.first.fullName, 'Mateo Fernández');
      expect(children.last.fullName, 'Olivia Vega');
    });

    test('returns the full profile of a demo child', () async {
      final result = await repository.loadChild('mateo-fernandez');

      expect(result, isA<Success<Child?>>());
      final child = (result as Success<Child?>).value!;
      expect(child.fullName, 'Mateo Fernández');
      expect(child.birthDate, DateTime(2023, 3, 12));
      expect(child.room, 'Soles');
      expect(child.enrolledAt, DateTime(2025, 2));
      expect(child.allergy!.notes, contains('inhalador'));
      expect(child.linkedParents, 2);
      expect(child.guardians.first.status, GuardianStatus.active);
      expect(child.guardians.last.status, GuardianStatus.invited);
    });

    test('returns Success(null) for an unknown child', () async {
      final result = await repository.loadChild('inexistente');

      expect(result, isA<Success<Child?>>());
      expect((result as Success<Child?>).value, isNull);
    });

    test('returns Failure when the data source fails', () async {
      final failing = KidsRepositoryImpl(_FailingDataSource());

      final children = await failing.loadChildren();
      final child = await failing.loadChild('mateo-fernandez');

      expect(children, isA<Failure<List<Child>>>());
      expect((children as Failure<List<Child>>).failure, isA<DataFailure>());
      expect(child, isA<Failure<Child?>>());
      expect((child as Failure<Child?>).failure, isA<DataFailure>());
    });
  });
}
