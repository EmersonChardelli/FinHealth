import '../models/financial_indicators.dart';

/// Limites das faixas de cada indicador, Equações 3.5 a 3.8 do TCC.
///
/// Cada indicador tem um valor "saudável" e um valor "crítico". No saudável ou
/// além dele vale [maxPoints]; no crítico ou além dele vale zero; entre os dois
/// os pontos seguem uma linha reta. Este é o único arquivo a mudar se o autor
/// decidir afrouxar ou apertar as faixas.
class FinancialThresholds {
  FinancialThresholds._();

  /// Pontos que um indicador vale quando está na faixa saudável.
  static const double maxPoints = 25;

  /// Renda comprometida: saudável até 30%, crítico a partir de 50%.
  static const double incomeCommitmentGood = 30;
  static const double incomeCommitmentCritical = 50;

  /// Endividamento sobre a renda anual: saudável até 30%, crítico a partir de 60%.
  static const double debtLevelGood = 30;
  static const double debtLevelCritical = 60;

  /// Poupança mensal: saudável a partir de 10%, crítica em 0% ou menos.
  static const double monthlySavingsGood = 10;
  static const double monthlySavingsCritical = 0;

  /// Reserva de emergência: saudável a partir de 3 meses, crítica com 1 mês ou menos.
  static const double emergencyReserveGood = 3;
  static const double emergencyReserveCritical = 1;

  /// Score mínimo de cada situação, comparado com o score sem arredondar.
  static const double healthyScore = 80;
  static const double attentionScore = 50;

  /// Pontos de um indicador, de 0 a [maxPoints], sem arredondar.
  static double points(IndicatorKind kind, double value) {
    switch (kind) {
      case IndicatorKind.incomeCommitment:
        return _lowerIsBetter(
          value,
          incomeCommitmentGood,
          incomeCommitmentCritical,
        );
      case IndicatorKind.debtLevel:
        return _lowerIsBetter(value, debtLevelGood, debtLevelCritical);
      case IndicatorKind.monthlySavings:
        return _higherIsBetter(
          value,
          monthlySavingsGood,
          monthlySavingsCritical,
        );
      case IndicatorKind.emergencyReserve:
        return _higherIsBetter(
          value,
          emergencyReserveGood,
          emergencyReserveCritical,
        );
    }
  }

  /// Faixa de um indicador, derivada dos pontos.
  static IndicatorLevel level(IndicatorKind kind, double value) {
    final p = points(kind, value);
    if (p >= maxPoints) {
      return IndicatorLevel.good;
    }
    if (p <= 0) {
      return IndicatorLevel.critical;
    }
    return IndicatorLevel.warning;
  }

  static double _lowerIsBetter(double value, double good, double critical) {
    if (value <= good) {
      return maxPoints;
    }
    if (value >= critical) {
      return 0;
    }
    return maxPoints * (critical - value) / (critical - good);
  }

  static double _higherIsBetter(double value, double good, double critical) {
    if (value >= good) {
      return maxPoints;
    }
    if (value <= critical) {
      return 0;
    }
    return maxPoints * (value - critical) / (good - critical);
  }
}
