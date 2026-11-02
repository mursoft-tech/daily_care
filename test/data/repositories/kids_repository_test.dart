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

  @override
  Future<void> saveChild(Child child) async => throw Exception('boom');

  @override
  Future<Guardian> linkGuardian({
    required String childId,
    required String fullName,
    required String email,
    required GuardianRelationship relationship,
    required String invitationCode,
  }) async => throw Exception('boom');
}

Child _child({String id = 'martina-lopez'}) => Child(
  id: id,
  firstName: 'Martina',
  lastName: 'López',
  birthDate: DateTime(2023, 3, 12),
  room: 'Soles',
  enrolledAt: DateTime(2026, 10, 24),
  colorToken: 'blue',
);

void main() {
  group('KidsRepositoryImpl', () {
    final repository = KidsRepositoryImpl(DemoKidsDataSource());

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
      expect(child.allergies.first.notes, contains('inhalador'));
      expect(child.linkedParents, 2);
      expect(child.guardians.first.status, GuardianStatus.active);
      expect(child.guardians.last.status, GuardianStatus.invited);
    });

    test('returns Success(null) for an unknown child', () async {
      final result = await repository.loadChild('inexistente');

      expect(result, isA<Success<Child?>>());
      expect((result as Success<Child?>).value, isNull);
    });

    test('adds a child that can be read back from the list', () async {
      final added = await repository.addChild(_child());

      expect(added, isA<Success<Child>>());
      final children = await repository.loadChildren();
      expect((children as Success<List<Child>>).value, hasLength(9));

      final stored = await repository.loadChild('martina-lopez');
      expect((stored as Success<Child?>).value, isNotNull);
      expect(stored.value!.fullName, 'Martina López');
    });

    test('links a new guardian to a child with invited status', () async {
      final result = await repository.linkGuardian(
        childId: 'mateo-fernandez',
        fullName: 'Carlos Gómez',
        email: 'carlos@ejemplo.com',
        relationship: GuardianRelationship.guardian,
        invitationCode: '7K4P9',
      );

      expect(result, isA<Success<Guardian>>());
      final guardian = (result as Success<Guardian>).value;
      expect(guardian.fullName, 'Carlos Gómez');
      expect(guardian.email, 'carlos@ejemplo.com');
      expect(guardian.invitationCode, '7K4P9');
      expect(guardian.relationship, GuardianRelationship.guardian);
      expect(guardian.status, GuardianStatus.invited);
      expect(guardian.isActive, isFalse);

      final childResult = await repository.loadChild('mateo-fernandez');
      final updatedChild = (childResult as Success<Child?>).value!;
      expect(updatedChild.guardians.any((g) => g.fullName == 'Carlos Gómez'), isTrue);
      expect(updatedChild.linkedParents, 3);
    });

    test('rejects a guardian whose email is already linked to the child', () async {
      final repo = KidsRepositoryImpl(DemoKidsDataSource());

      final result = await repo.linkGuardian(
        childId: 'mateo-fernandez',
        fullName: 'Lucía Duplicada',
        email: '  LUCIA@EJEMPLO.COM ',
        relationship: GuardianRelationship.mother,
        invitationCode: 'ABCDE',
      );

      expect(result, isA<Failure<Guardian>>());
      expect(
        (result as Failure<Guardian>).failure,
        isA<GuardianAlreadyLinkedFailure>(),
      );

      final childResult = await repo.loadChild('mateo-fernandez');
      final child = (childResult as Success<Child?>).value!;
      expect(child.linkedParents, 2);
      expect(child.guardians.any((g) => g.fullName == 'Lucía Duplicada'), isFalse);
    });

    test('links a different email to a child that already has guardians', () async {
      final repo = KidsRepositoryImpl(DemoKidsDataSource());

      final result = await repo.linkGuardian(
        childId: 'mateo-fernandez',
        fullName: 'Carlos Gómez',
        email: 'carlos@ejemplo.com',
        relationship: GuardianRelationship.guardian,
        invitationCode: 'ABCDE',
      );

      expect(result, isA<Success<Guardian>>());
      final childResult = await repo.loadChild('mateo-fernandez');
      final child = (childResult as Success<Child?>).value!;
      expect(child.linkedParents, 3);
      expect(child.guardians.last.email, 'carlos@ejemplo.com');
    });

    test('returns Failure when the data source fails', () async {
      final failing = KidsRepositoryImpl(_FailingDataSource());

      final children = await failing.loadChildren();
      final child = await failing.loadChild('mateo-fernandez');
      final added = await failing.addChild(_child());
      final linked = await failing.linkGuardian(
        childId: 'mateo-fernandez',
        fullName: 'Carlos Gómez',
        email: 'carlos@ejemplo.com',
        relationship: GuardianRelationship.guardian,
        invitationCode: '7K4P9',
      );

      expect(children, isA<Failure<List<Child>>>());
      expect((children as Failure<List<Child>>).failure, isA<DataFailure>());
      expect(child, isA<Failure<Child?>>());
      expect((child as Failure<Child?>).failure, isA<DataFailure>());
      expect(added, isA<Failure<Child>>());
      expect((added as Failure<Child>).failure, isA<DataFailure>());
      expect(linked, isA<Failure<Guardian>>());
      expect((linked as Failure<Guardian>).failure, isA<DataFailure>());
    });
  });
}
