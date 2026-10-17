import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finhealth/utils/money_input_formatter.dart';

void main() {
  const formatter = MoneyInputFormatter();

  /// Aplica o formatador como se o usuário tivesse acabado de digitar [text]
  /// com o cursor em [cursor], ou no fim quando não informado.
  TextEditingValue type(String text, [int? cursor]) {
    return formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: cursor ?? text.length),
      ),
    );
  }

  group('format', () {
    test('põe o ponto de milhar enquanto digita', () {
      expect(MoneyInputFormatter.format('5'), '5');
      expect(MoneyInputFormatter.format('500'), '500');
      expect(MoneyInputFormatter.format('5000'), '5.000');
      expect(MoneyInputFormatter.format('1234567'), '1.234.567');
    });

    test('a vírgula é o decimal, com no máximo dois dígitos', () {
      expect(MoneyInputFormatter.format('5000,'), '5.000,');
      expect(MoneyInputFormatter.format('5000,5'), '5.000,5');
      expect(MoneyInputFormatter.format('1234,56'), '1.234,56');
      expect(MoneyInputFormatter.format('12,345'), '12,34');
      expect(MoneyInputFormatter.format(',5'), '0,5');
    });

    test('ignora pontos digitados e zeros à esquerda', () {
      expect(MoneyInputFormatter.format('1.234,56'), '1.234,56');
      expect(MoneyInputFormatter.format('1.2.3.4'), '1.234');
      expect(MoneyInputFormatter.format('007'), '7');
      expect(MoneyInputFormatter.format('0'), '0');
      expect(MoneyInputFormatter.format('0,50'), '0,50');
    });

    test('vazio ou sem dígitos fica vazio', () {
      expect(MoneyInputFormatter.format(''), '');
      expect(MoneyInputFormatter.format('abc'), '');
      expect(MoneyInputFormatter.format('.'), '');
    });
  });

  group('cursor', () {
    test('digitar no fim deixa o cursor no fim', () {
      final v = type('1234');
      expect(v.text, '1.234');
      expect(v.selection.baseOffset, 5);
    });

    test('digitar no meio mantém o cursor depois do mesmo dígito', () {
      // "1.345" com o cursor depois do 1, o usuário digita 2: "12.345"
      final v = type('12.345', 2);
      expect(v.text, '12.345');
      expect(v.selection.baseOffset, 2);
    });

    test('apagar o último dígito tira o ponto que sobrou', () {
      // De "1.234" o usuário apaga o 4: fica "1.23", que vira "123"
      final v = type('1.23');
      expect(v.text, '123');
      expect(v.selection.baseOffset, 3);
    });

    test('cursor no começo fica no começo', () {
      final v = type('5000', 0);
      expect(v.text, '5.000');
      expect(v.selection.baseOffset, 0);
    });
  });
}
