import 'dart:math';

/// Genera códigos de invitación de 5 caracteres sin caracteres ambiguos.
class GenerateInvitationCode {
  GenerateInvitationCode({Random? random}) : _random = random ?? Random();

  static const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const length = 5;
  static const _maxAttempts = 1000;

  final Random _random;

  String execute({Iterable<String> reservedCodes = const []}) {
    final reserved = reservedCodes
        .map((code) => code.trim().toUpperCase())
        .where((code) => code.isNotEmpty)
        .toSet();

    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final code = List.generate(
        length,
        (_) => alphabet[_random.nextInt(alphabet.length)],
      ).join();
      if (!reserved.contains(code)) return code;
    }

    throw StateError('No se pudo generar un código de invitación único');
  }
}
