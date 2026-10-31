import '../../core/formatters/app_date_formatter.dart';
import '../../core/result.dart';
import '../models/child.dart';
import '../repositories/kids_repository.dart';
import '../value_objects/allergy.dart';
import '../value_objects/child_draft.dart';
import 'calculate_age.dart';

enum RegistrationError {
  nameRequired,
  birthDateRequired,
  birthDateInvalid,
  birthDateFuture,
  birthDateTooOld,
  roomRequired,
  saveFailed,
}

sealed class CreateChildResult {
  const CreateChildResult();
}

final class ChildCreated extends CreateChildResult {
  const ChildCreated(this.child);

  final Child child;
}

final class ChildRejected extends CreateChildResult {
  const ChildRejected(this.errors);

  final List<RegistrationError> errors;
}

/// El alta no pudo completarse por un fallo de datos, no de validación.
final class ChildFailed extends CreateChildResult {
  const ChildFailed();
}

class CreateChild {
  const CreateChild(this._repository, this._today);

  static const maxAgeYears = 6;
  static const _colorTokens = ['blue', 'pink', 'green', 'yellow', 'purple'];
  static const _accents = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
  };

  final KidsRepository _repository;
  final DateTime Function() _today;

  Future<CreateChildResult> execute(ChildDraft draft) async {
    final today = _today();
    final errors = _validate(draft, today);
    if (errors.isNotEmpty) return ChildRejected(errors);

    final birthDate = parseBirthDate(draft.birthDateText)!;
    final room = draft.room.trim();

    final loaded = await _repository.loadChildren();
    if (loaded is Failure<List<Child>>) return const ChildFailed();
    final existing = (loaded as Success<List<Child>>).value;

    final child = Child(
      id: _uniqueId(slugify(draft.trimmedName), existing),
      firstName: draft.firstName,
      lastName: draft.lastName,
      birthDate: birthDate,
      room: room,
      enrolledAt: DateTime(today.year, today.month, today.day),
      colorToken: _colorTokens[existing.length % _colorTokens.length],
      allergies: [
        for (final label in draft.normalizedAllergyLabels)
          Allergy(label: label, notes: ''),
      ],
      medicalNotes: draft.medicalNotes.trim(),
    );

    final saved = await _repository.addChild(child);
    return switch (saved) {
      Success(:final value) => ChildCreated(value),
      Failure() => const ChildFailed(),
    };
  }

  List<RegistrationError> _validate(ChildDraft draft, DateTime today) {
    final errors = <RegistrationError>[];

    if (draft.trimmedName.isEmpty) {
      errors.add(RegistrationError.nameRequired);
    }

    final birthDateText = draft.birthDateText.trim();
    if (birthDateText.isEmpty) {
      errors.add(RegistrationError.birthDateRequired);
    } else {
      final birthDate = parseBirthDate(birthDateText);
      if (birthDate == null) {
        errors.add(RegistrationError.birthDateInvalid);
      } else if (birthDate.isAfter(today)) {
        errors.add(RegistrationError.birthDateFuture);
      } else if (calculateAge(birthDate, today) > maxAgeYears) {
        errors.add(RegistrationError.birthDateTooOld);
      }
    }

    if (draft.room.trim().isEmpty) {
      errors.add(RegistrationError.roomRequired);
    }

    return errors;
  }

  String slugify(String name) {
    final normalized = name
        .toLowerCase()
        .split('')
        .map((char) => _accents[char] ?? char)
        .join();
    final slug = normalized
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'nino' : slug;
  }

  String _uniqueId(String base, List<Child> existing) {
    final ids = existing.map((child) => child.id).toSet();
    if (!ids.contains(base)) return base;

    var suffix = 2;
    while (ids.contains('$base-$suffix')) {
      suffix++;
    }
    return '$base-$suffix';
  }
}
