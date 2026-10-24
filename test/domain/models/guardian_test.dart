import 'package:daily_care/domain/models/guardian.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Guardian', () {
    const active = Guardian(
      id: 'lucia-fernandez',
      firstName: 'Lucía',
      lastName: 'Fernández',
      relationship: GuardianRelationship.mother,
      status: GuardianStatus.active,
      colorToken: 'purple',
    );

    const invited = Guardian(
      id: 'diego-fernandez',
      firstName: 'Diego',
      lastName: 'Fernández',
      relationship: GuardianRelationship.father,
      status: GuardianStatus.invited,
      colorToken: 'blue',
    );

    test('builds the full name and initial', () {
      expect(active.fullName, 'Lucía Fernández');
      expect(active.initial, 'L');
    });

    test('distinguishes active from invited guardians', () {
      expect(active.isActive, isTrue);
      expect(invited.isActive, isFalse);
      expect(active.status, GuardianStatus.active);
      expect(invited.status, GuardianStatus.invited);
    });
  });
}
