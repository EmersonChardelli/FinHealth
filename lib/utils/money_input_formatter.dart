import 'package:flutter/services.dart';

/// Formata reais enquanto o usuário digita, ponto de
/// milhar na parte inteira, vírgula como decimal, no máximo dois centavos.
///
/// O usuário digita só dígitos e, se quiser, uma vírgula. "5000" vira "5.000",
/// "5000,5" vira "5.000,5". Dá para apagar e editar no meio do texto: o cursor
/// fica depois do mesmo dígito em que estava, mesmo que os pontos de milhar
/// mudem de lugar. Pontos digitados são ignorados.
class MoneyInputFormatter extends TextInputFormatter {
  const MoneyInputFormatter();

  /// No máximo 15 dígitos na parte inteira, bem acima de qualquer valor real.
  static const int _maxIntegerDigits = 15;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    final formatted = format(raw);

    // Conta os dígitos e a vírgula antes do cursor, que são o que o usuário vê
    final cursor = newValue.selection.baseOffset.clamp(0, raw.length);
    final before = _significant(raw.substring(0, cursor)).length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: _offsetAfter(formatted, before),
      ),
    );
  }

  /// Escreve o texto no formato final, sem mexer no cursor.
  static String format(String raw) {
    final commaIndex = raw.indexOf(',');
    final hasComma = commaIndex >= 0;
    var integer = _digits(hasComma ? raw.substring(0, commaIndex) : raw);
    var decimals = hasComma ? _digits(raw.substring(commaIndex + 1)) : '';

    // Tira zeros à esquerda, mas deixa um zero sozinho
    integer = integer.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (integer.isEmpty && hasComma) {
      integer = '0';
    }
    if (integer.isEmpty) {
      return '';
    }
    if (integer.length > _maxIntegerDigits) {
      integer = integer.substring(0, _maxIntegerDigits);
    }
    if (decimals.length > 2) {
      decimals = decimals.substring(0, 2);
    }

    final grouped = _group(integer);
    return hasComma ? '$grouped,$decimals' : grouped;
  }

  static String _digits(String text) => text.replaceAll(RegExp(r'\D'), '');

  static String _significant(String text) =>
      text.replaceAll(RegExp(r'[^\d,]'), '');

  /// Põe um ponto a cada três dígitos, da direita para a esquerda.
  static String _group(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      if (i > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Posição logo depois do [count]-ésimo dígito ou vírgula de [text].
  static int _offsetAfter(String text, int count) {
    if (count <= 0) {
      return 0;
    }
    var seen = 0;
    for (var i = 0; i < text.length; i++) {
      if (text[i] != '.') {
        seen++;
        if (seen == count) {
          return i + 1;
        }
      }
    }
    return text.length;
  }
}
