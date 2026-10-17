import 'dart:math' as math;

import '../models/compound_interest_point.dart';

/// Período em que a taxa de juros foi informada.
enum RatePeriod {
  mensal('taxa ao mês'),
  anual('taxa ao ano');

  const RatePeriod(this.label);

  final String label;
}

/// Unidade em que o prazo foi informado.
enum TermUnit {
  meses('meses'),
  anos('anos');

  const TermUnit(this.label);

  final String label;
}

/// Projeta um investimento com aportes mensais e juros compostos.
///
/// Convenção: o aporte entra no fim de cada mês, então
/// `M = C₀ × (1 + i)^n + A × ((1 + i)^n − 1) / i`. Com taxa zero vira
/// `C₀ + A × n`. A iteração mês a mês reproduz a mesma fórmula.
class CompoundInterestSimulator {
  const CompoundInterestSimulator();

  /// Converte uma taxa em percentual para a taxa mensal em fração.
  ///
  /// "1" ao mês vira 0,01. A taxa ao ano é tratada como efetiva anual e vira
  /// mensal por `(1 + ia)^(1/12) − 1`, Equação 3.13 do TCC; nunca é dividida
  /// por 12.
  double monthlyRate(double ratePercent, RatePeriod period) {
    final rate = ratePercent / 100;
    switch (period) {
      case RatePeriod.mensal:
        return rate;
      case RatePeriod.anual:
        return math.pow(1 + rate, 1 / 12) - 1;
    }
  }

  /// Converte o prazo digitado para meses: anos × 12, meses como estão.
  int monthsFor(int value, TermUnit unit) {
    switch (unit) {
      case TermUnit.meses:
        return value;
      case TermUnit.anos:
        return value * 12;
    }
  }

  /// Devolve um ponto por mês, do mês 0 ao mês [months]. Com prazo zero
  /// devolve só o mês 0, que é o capital inicial.
  ///
  /// [monthlyRate] é a taxa mensal em fração, como devolvida por
  /// [CompoundInterestSimulator.monthlyRate].
  List<CompoundInterestPoint> simulate({
    required double initial,
    required double monthlyDeposit,
    required double monthlyRate,
    required int months,
  }) {
    var invested = initial;
    var balance = initial;
    final points = <CompoundInterestPoint>[
      CompoundInterestPoint(month: 0, invested: invested, balance: balance),
    ];

    for (var month = 1; month <= months; month++) {
      // Os juros do mês entram sobre o saldo, depois entra o aporte
      balance = balance * (1 + monthlyRate) + monthlyDeposit;
      invested += monthlyDeposit;
      points.add(
        CompoundInterestPoint(
          month: month,
          invested: invested,
          balance: balance,
        ),
      );
    }

    return points;
  }
}
