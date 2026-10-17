import 'package:intl/intl.dart';

/// Formata e lê valores em reais no padrão brasileiro.
class MoneyFormat {
  MoneyFormat._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final NumberFormat _currencyNoCents = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 0,
  );

  /// Formata [value] como "R$ 5.000,00".
  static String format(double value) {
    return _currency.format(value).replaceAll(' ', ' ');
  }

  /// Formata [value] como "R$ 5.000", sem centavos.
  static String formatNoCents(double value) {
    return _currencyNoCents.format(value).replaceAll(' ', ' ');
  }

  /// Formata [value] para dentro de um campo de entrada, sem o "R$": "5.000"
  /// quando é inteiro, "3.200,50" quando tem centavos.
  static String formatInput(double value) {
    final pattern = value == value.roundToDouble() ? '#,##0' : '#,##0.00';
    return NumberFormat(pattern, 'pt_BR').format(value);
  }

  /// Formata uma porcentagem já em pontos percentuais, como "64%".
  static String formatPercent(double percent) {
    return '${percent.round()}%';
  }

  /// Lê um texto digitado pelo usuário e devolve o valor em reais.
  ///
  /// Aceita "R$ 5.000,00", "5.000", "5000", "5000,5" e "5000.50".
  /// Devolve `null` quando o texto está vazio ou não é um número.
  static double? parse(String text) {
    var cleaned = text.replaceAll(RegExp(r'[^\d,.\-]'), '');
    if (cleaned.isEmpty || cleaned == '-') {
      return null;
    }

    if (cleaned.contains(',')) {
      // Vírgula é o separador decimal, pontos são milhares
      cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else if (RegExp(r'^-?\d{1,3}(\.\d{3})+$').hasMatch(cleaned)) {
      // Só pontos em grupos de três são milhares, como em "5.000"
      cleaned = cleaned.replaceAll('.', '');
    }

    return double.tryParse(cleaned);
  }

  /// Lê uma taxa em percentual, como "1,5" ou "1.5".
  ///
  /// Diferente de [parse], o ponto nunca é separador de milhar: uma taxa não
  /// chega a milhares, então "1.500" é 1,5 e não 1500. Devolve `null` quando
  /// o texto está vazio, tem mais de um separador decimal ou não é número.
  static double? parseRate(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^\d,.]'), '').replaceAll(',', '.');
    if (cleaned.isEmpty || '.'.allMatches(cleaned).length > 1) {
      return null;
    }
    return double.tryParse(cleaned);
  }
}
