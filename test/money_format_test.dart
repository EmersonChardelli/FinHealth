import 'package:flutter_test/flutter_test.dart';
import 'package:finhealth/utils/money_format.dart';

void main() {
  group('MoneyFormat.format', () {
    test('formata com milhares e centavos', () {
      expect(MoneyFormat.format(5000), 'R\$ 5.000,00');
      expect(MoneyFormat.format(3200.5), 'R\$ 3.200,50');
      expect(MoneyFormat.format(0), 'R\$ 0,00');
    });

    test('formata sem centavos', () {
      expect(MoneyFormat.formatNoCents(5000), 'R\$ 5.000');
      expect(MoneyFormat.formatNoCents(1234567), 'R\$ 1.234.567');
    });

    test('formata para o campo de entrada, sem R\$', () {
      expect(MoneyFormat.formatInput(5000), '5.000');
      expect(MoneyFormat.formatInput(3200.5), '3.200,50');
      expect(MoneyFormat.formatInput(0), '0');
      expect(
        MoneyFormat.parse(MoneyFormat.formatInput(1234567.89)),
        1234567.89,
      );
    });

    test('formata porcentagem arredondada', () {
      expect(MoneyFormat.formatPercent(64), '64%');
      expect(MoneyFormat.formatPercent(13.33), '13%');
      expect(MoneyFormat.formatPercent(9.5), '10%');
    });
  });

  group('MoneyFormat.parse', () {
    test('lê o formato brasileiro', () {
      expect(MoneyFormat.parse('R\$ 5.000,00'), 5000);
      expect(MoneyFormat.parse('5.000'), 5000);
      expect(MoneyFormat.parse('1.234.567,89'), 1234567.89);
      expect(MoneyFormat.parse('3200,5'), 3200.5);
    });

    test('lê números simples e com ponto decimal', () {
      expect(MoneyFormat.parse('5000'), 5000);
      expect(MoneyFormat.parse('5000.50'), 5000.5);
      expect(MoneyFormat.parse('0'), 0);
    });

    test('formatos aceitos na digitação', () {
      expect(MoneyFormat.parse('1.234,56'), 1234.56);
      expect(MoneyFormat.parse('1234,56'), 1234.56);
      expect(MoneyFormat.parse('1.234'), 1234);
      expect(MoneyFormat.parse(''), isNull);
    });

    test('a vírgula nunca é separador de milhar', () {
      expect(MoneyFormat.parse('1,234'), 1.234);
      expect(MoneyFormat.parse('1,5'), 1.5);
    });

    test('devolve null para texto vazio ou inválido', () {
      expect(MoneyFormat.parse(''), isNull);
      expect(MoneyFormat.parse('   '), isNull);
      expect(MoneyFormat.parse('abc'), isNull);
      expect(MoneyFormat.parse('R\$'), isNull);
    });
  });
  group('parseRate', () {
    test('lê vírgula e ponto como decimal', () {
      expect(MoneyFormat.parseRate('1,5'), closeTo(1.5, 1e-9));
      expect(MoneyFormat.parseRate('1.5'), closeTo(1.5, 1e-9));
      expect(MoneyFormat.parseRate('12'), closeTo(12, 1e-9));
    });

    test('o ponto nunca é separador de milhar', () {
      expect(MoneyFormat.parseRate('1.500'), closeTo(1.5, 1e-9));
      expect(MoneyFormat.parseRate('0.125'), closeTo(0.125, 1e-9));
    });

    test('devolve null para vazio, inválido ou mais de um separador', () {
      expect(MoneyFormat.parseRate(''), isNull);
      expect(MoneyFormat.parseRate('abc'), isNull);
      expect(MoneyFormat.parseRate('1.2.3'), isNull);
    });
  });
}
