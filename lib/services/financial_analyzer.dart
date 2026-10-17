import '../models/analysis_result.dart';
import '../models/financial_data.dart';
import '../models/financial_indicators.dart';
import '../models/health_score.dart';
import '../models/recommendation.dart';
import 'financial_thresholds.dart';
import 'health_messages.dart';

/// Calcula os indicadores, o score, a mensagem geral e as recomendações a
/// partir dos dados informados. Sem estado; todos os métodos são funções puras.
class FinancialAnalyzer {
  const FinancialAnalyzer();

  /// Roda todos os cálculos de uma vez e junta tudo para a tela de resultado.
  AnalysisResult analyze(FinancialData data) {
    final indicators = computeIndicators(data);
    final score = computeScore(indicators);
    return AnalysisResult(
      data: data,
      indicators: indicators,
      score: score,
      generalMessage: HealthMessages.general(score.status),
      recommendations: buildRecommendations(indicators),
    );
  }

  /// Aplica as fórmulas dos indicadores (Equações 3.1 a 3.4 do TCC).
  ///
  /// Lança [ArgumentError] quando a renda ou os gastos são zero ou negativos,
  /// porque os indicadores dividem pelos dois. A tela valida isso antes de
  /// chamar, com a mensagem de erro correspondente.
  FinancialIndicators computeIndicators(FinancialData data) {
    if (data.monthlyIncome <= 0) {
      throw ArgumentError.value(
        data.monthlyIncome,
        'monthlyIncome',
        'A renda mensal precisa ser maior que zero',
      );
    }
    if (data.monthlyExpenses <= 0) {
      throw ArgumentError.value(
        data.monthlyExpenses,
        'monthlyExpenses',
        'Os gastos mensais precisam ser maiores que zero',
      );
    }

    final income = data.monthlyIncome;
    final expenses = data.monthlyExpenses;

    return FinancialIndicators(
      incomeCommitment: expenses / income * 100,
      debtLevel: data.totalDebt / (income * 12) * 100,
      monthlySavings: (income - expenses) / income * 100,
      emergencyReserveMonths: data.savings / expenses,
    );
  }

  /// Soma os pontos dos quatro indicadores e classifica o total sem arredondar.
  HealthScore computeScore(FinancialIndicators indicators) {
    var total = 0.0;
    for (final kind in IndicatorKind.values) {
      total += FinancialThresholds.points(kind, _valueOf(kind, indicators));
    }

    final value = total.clamp(0.0, 100.0);
    return HealthScore(value: value, status: _statusFor(value));
  }

  /// Faixa em que um indicador caiu. Usada para colorir a barra de cada cartão.
  IndicatorLevel levelOf(IndicatorKind kind, FinancialIndicators indicators) {
    return FinancialThresholds.level(kind, _valueOf(kind, indicators));
  }

  /// Sempre quatro recomendações, uma por indicador, na ordem dos indicadores,
  /// com o texto da faixa em que cada um caiu.
  List<Recommendation> buildRecommendations(FinancialIndicators indicators) {
    return [
      for (final kind in IndicatorKind.values)
        Recommendation(
          kind: kind,
          level: levelOf(kind, indicators),
          message: HealthMessages.recommendation(
            kind,
            levelOf(kind, indicators),
          ),
        ),
    ];
  }

  /// Classifica pelo valor sem arredondar: 79,99 ainda é "Atenção".
  HealthStatus _statusFor(double value) {
    if (value >= FinancialThresholds.healthyScore) {
      return HealthStatus.saudavel;
    }
    if (value >= FinancialThresholds.attentionScore) {
      return HealthStatus.atencao;
    }
    return HealthStatus.critico;
  }

  double _valueOf(IndicatorKind kind, FinancialIndicators indicators) {
    switch (kind) {
      case IndicatorKind.incomeCommitment:
        return indicators.incomeCommitment;
      case IndicatorKind.debtLevel:
        return indicators.debtLevel;
      case IndicatorKind.monthlySavings:
        return indicators.monthlySavings;
      case IndicatorKind.emergencyReserve:
        return indicators.emergencyReserveMonths;
    }
  }
}
