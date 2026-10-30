import 'package:daily_care/domain/models/account_invitation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccountInvitation', () {
    test('exposes the invitation fields', () {
      const invitation = AccountInvitation(
        code: '7K4P9',
        email: 'lucia.fernandez@gmail.com',
        childName: 'Mateo',
        roomName: 'Sala Soles',
      );

      expect(invitation.code, '7K4P9');
      expect(invitation.email, 'lucia.fernandez@gmail.com');
      expect(invitation.childName, 'Mateo');
      expect(invitation.roomName, 'Sala Soles');
    });

    test('derives the avatar initial from the child name', () {
      const invitation = AccountInvitation(
        code: '7K4P9',
        email: 'lucia.fernandez@gmail.com',
        childName: 'mateo',
        roomName: 'Sala Soles',
      );

      expect(invitation.childInitial, 'M');
    });

    test('returns an empty initial when the child name is empty', () {
      const invitation = AccountInvitation(
        code: '7K4P9',
        email: 'lucia.fernandez@gmail.com',
        childName: '',
        roomName: 'Sala Soles',
      );

      expect(invitation.childInitial, isEmpty);
    });
  });
}
