import 'dart:math';

import 'package:daily_care/domain/use_cases/generate_invitation_code.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedRandom implements Random {
  const _FixedRandom(this.value);

  final int value;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => value % max;
}

void main() {
  group('GenerateInvitationCode', () {
    test('generates five characters from the unambiguous alphabet', () {
      final code = GenerateInvitationCode(random: Random(7)).execute();

      expect(code, hasLength(GenerateInvitationCode.length));
      expect(RegExp('[IO01]').hasMatch(code), isFalse);
      expect(
        code.split('').every(GenerateInvitationCode.alphabet.contains),
        isTrue,
      );
    });

    test('regenerates the code when it collides with a reserved one', () {
      final generator = GenerateInvitationCode(random: Random(7));
      final first = generator.execute();
      final second = generator.execute(reservedCodes: [first]);

      expect(second, isNot(first));
    });

    test('ignores blank reserved codes', () {
      final code = GenerateInvitationCode(random: Random(7)).execute(
        reservedCodes: ['   ', ''],
      );

      expect(code, isNotEmpty);
    });

    test('fails when no unique code can be generated', () {
      final generator = GenerateInvitationCode(random: const _FixedRandom(0));
      final repeated = generator.execute();

      expect(
        () => generator.execute(reservedCodes: [repeated]),
        throwsStateError,
      );
    });
  });
}
