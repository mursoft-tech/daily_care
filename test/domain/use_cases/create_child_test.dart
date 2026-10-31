import 'package:daily_care/core/result.dart';
import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/domain/repositories/kids_repository.dart';
import 'package:daily_care/domain/use_cases/create_child.dart';
import 'package:daily_care/domain/value_objects/child_draft.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeKidsRepository implements KidsRepository {
  _FakeKidsRepository({
    List<Child>? children,
    this.loadFailure,
    this.saveFailure,
  }) : children = children ?? <Child>[];

  final List<Child> children;
  final AppFailure? loadFailure;
  final AppFailure? saveFailure;

  @override
  Future<Result<List<Child>>> loadChildren() async {
    final failure = loadFailure;
    if (failure != null) return Failure(failure);
    return Success(List.unmodifiable(children));
  }

  @override
  Future<Result<Child?>> loadChild(String id) async => const Success(null);

  @override
  Future<Result<Child>> addChild(Child child) async {
    final failure = saveFailure;
    if (failure != null) return Failure(failure);
    children.add(child);
    return Success(child);
  }
}

DateTime _today() => DateTime(2026, 10, 24);

ChildDraft _draft({
  String fullName = 'Martina López',
  String birthDateText = '12/03/2023',
  String room = 'Soles',
  List<String> allergyLabels = const [],
  String medicalNotes = '',
}) {
  return ChildDraft(
    fullName: fullName,
    birthDateText: birthDateText,
    room: room,
    allergyLabels: allergyLabels,
    medicalNotes: medicalNotes,
  );
}

CreateChild _useCase(_FakeKidsRepository repository) =>
    CreateChild(repository, _today);

void main() {
  group('CreateChild', () {
    test('creates a child with a slug id, today enrollment and no guardians', () async {
      final repository = _FakeKidsRepository();
      final result = await _useCase(repository).execute(_draft());

      final created = result as ChildCreated;
      expect(created.child.id, 'martina-lopez');
      expect(created.child.firstName, 'Martina');
      expect(created.child.lastName, 'López');
      expect(created.child.birthDate, DateTime(2023, 3, 12));
      expect(created.child.room, 'Soles');
      expect(created.child.enrolledAt, DateTime(2026, 10, 24));
      expect(created.child.colorToken, 'blue');
      expect(created.child.guardians, isEmpty);
      expect(repository.children, hasLength(1));
    });

    test('maps the allergy labels to allergies and stores the medical notes', () async {
      final repository = _FakeKidsRepository();
      final result = await _useCase(repository).execute(
        _draft(
          allergyLabels: [' maní ', '', 'Lactosa'],
          medicalNotes: '  Lleva aerosol. ',
        ),
      );

      final child = (result as ChildCreated).child;
      expect(child.allergies.map((allergy) => allergy.label), [
        'MANÍ',
        'LACTOSA',
      ]);
      expect(child.medicalNotes, 'Lleva aerosol.');
    });

    test('rejects an empty name', () async {
      final result = await _useCase(_FakeKidsRepository()).execute(
        _draft(fullName: '   '),
      );

      expect(
        (result as ChildRejected).errors.single,
        RegistrationError.nameRequired,
      );
    });

    test('rejects an empty birth date', () async {
      final result = await _useCase(_FakeKidsRepository()).execute(
        _draft(birthDateText: ''),
      );

      expect(
        (result as ChildRejected).errors.single,
        RegistrationError.birthDateRequired,
      );
    });

    test('rejects a date that does not exist', () async {
      final result = await _useCase(_FakeKidsRepository()).execute(
        _draft(birthDateText: '31/02/2023'),
      );

      expect(
        (result as ChildRejected).errors.single,
        RegistrationError.birthDateInvalid,
      );
    });

    test('rejects a future birth date', () async {
      final result = await _useCase(_FakeKidsRepository()).execute(
        _draft(birthDateText: '25/10/2026'),
      );

      expect(
        (result as ChildRejected).errors.single,
        RegistrationError.birthDateFuture,
      );
    });

    test('accepts a child that is exactly six years old', () async {
      final result = await _useCase(_FakeKidsRepository()).execute(
        _draft(birthDateText: '24/10/2020'),
      );

      expect(result, isA<ChildCreated>());
    });

    test('rejects a child older than six', () async {
      final result = await _useCase(_FakeKidsRepository()).execute(
        _draft(birthDateText: '23/10/2019'),
      );

      expect(
        (result as ChildRejected).errors.single,
        RegistrationError.birthDateTooOld,
      );
    });

    test('rejects an empty room', () async {
      final result = await _useCase(_FakeKidsRepository()).execute(
        _draft(room: '  '),
      );

      expect(
        (result as ChildRejected).errors.single,
        RegistrationError.roomRequired,
      );
    });

    test('adds a numeric suffix when the slug already exists', () async {
      final existing = Child(
        id: 'martina-lopez',
        firstName: 'Martina',
        lastName: 'López',
        birthDate: DateTime(2023, 1, 1),
        room: 'Soles',
        enrolledAt: DateTime(2025, 2),
        colorToken: 'blue',
      );
      final repository = _FakeKidsRepository(children: [existing]);

      final result = await _useCase(repository).execute(_draft());

      expect((result as ChildCreated).child.id, 'martina-lopez-2');
    });

    test('rotates the color token over the existing palette', () async {
      final repository = _FakeKidsRepository(
        children: [
          for (var i = 0; i < 3; i++)
            Child(
              id: 'nino-$i',
              firstName: 'Nino',
              lastName: '$i',
              birthDate: DateTime(2023, 1, 1),
              room: 'Soles',
              enrolledAt: DateTime(2025, 2),
              colorToken: 'blue',
            ),
        ],
      );

      final result = await _useCase(repository).execute(_draft());

      expect((result as ChildCreated).child.colorToken, 'yellow');
    });

    test('fails when the list cannot be loaded', () async {
      final repository = _FakeKidsRepository(
        loadFailure: const DataFailure(),
      );

      final result = await _useCase(repository).execute(_draft());

      expect(result, isA<ChildFailed>());
    });

    test('fails when the child cannot be saved', () async {
      final repository = _FakeKidsRepository(
        saveFailure: const DataFailure(),
      );

      final result = await _useCase(repository).execute(_draft());

      expect(result, isA<ChildFailed>());
    });
  });

  group('slugify', () {
    test('removes accents and punctuation', () {
      final useCase = _useCase(_FakeKidsRepository());

      expect(useCase.slugify('Benjamín Ruiz'), 'benjamin-ruiz');
      expect(useCase.slugify('  José  María  Peña '), 'jose-maria-pena');
      expect(useCase.slugify('!!!'), 'nino');
    });
  });
}
