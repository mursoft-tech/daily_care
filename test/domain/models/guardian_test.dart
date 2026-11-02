import 'package:daily_care/domain/models/guardian.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Guardian', () {
    const active = Guardian(
      id: 'lucia-fernandez',
      firstName: 'Lucía',
      lastName: 'Fernández',
      email: 'lucia@ejemplo.com',
      relationship: GuardianRelationship.mother,
      status: GuardianStatus.active,
      colorToken: 'purple',
    );

    const invited = Guardian(
      id: 'diego-fernandez',
      firstName: 'Diego',
      lastName: 'Fernández',
      email: '  DIEGO@Ejemplo.com ',
      relationship: GuardianRelationship.father,
      status: GuardianStatus.invited,
      colorToken: 'blue',
      invitationCode: 'K7M2P',
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

    test('exposes the invitation code and normalized email', () {
      expect(invited.invitationCode, 'K7M2P');
      expect(invited.normalizedEmail, 'diego@ejemplo.com');
      expect(active.invitationCode, isEmpty);
    });
  });
}
