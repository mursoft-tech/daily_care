import 'package:flutter/services.dart';

/// Máscara de fecha `dd/mm/aaaa`: acepta solo dígitos y agrega las barras.
class BirthDateInputFormatter extends TextInputFormatter {
  const BirthDateInputFormatter();

  static const _maxDigits = 8;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > _maxDigits) {
      digits = digits.substring(0, _maxDigits);
    }

    final masked = _mask(digits);
    final cursorDigits = _digitCount(
      newValue.text,
      newValue.selection.baseOffset.clamp(0, newValue.text.length),
    );

    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(
        offset: _offsetForDigitCount(masked, cursorDigits),
      ),
    );
  }

  String _mask(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  int _digitCount(String text, int end) {
    return text
        .substring(0, end)
        .replaceAll(RegExp(r'\D'), '')
        .length;
  }

  int _offsetForDigitCount(String masked, int count) {
    if (count <= 0) return 0;

    var seen = 0;
    for (var i = 0; i < masked.length; i++) {
      if (!RegExp(r'\d').hasMatch(masked[i])) continue;
      seen++;
      if (seen == count) {
        final afterSeparator = i + 1 < masked.length && masked[i + 1] == '/';
        return afterSeparator ? i + 2 : i + 1;
      }
    }
    return masked.length;
  }
}
