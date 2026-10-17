import 'package:flutter_test/flutter_test.dart';
import 'package:finhealth/models/financial_data.dart';
import 'package:finhealth/models/financial_indicators.dart';
import 'package:finhealth/models/health_score.dart';
import 'package:finhealth/services/financial_analyzer.dart';
import 'package:finhealth/services/health_messages.dart';

void main() {
  const analyzer = FinancialAnalyzer();

  // Valores de referência usados nas Figuras 2 e 3 do TCC
  const exemplo = FinancialData(
    monthlyIncome: 5000,
    monthlyExpenses: 3200,
    totalDebt: 8000,
    savings: 2000,
  );

  /// Indicadores de valor escolhido; o endividamento fica sempre em 0%, que
  /// são 25 pontos fixos.
  FinancialIndicators crafted({
    double commitment = 30,
    double savings = 10,
    double reserve = 3,
  }) {
    return FinancialIndicators(
      incomeCommitment: commitment,
      debtLevel: 0,
      monthlySavings: savings,
      emergencyReserveMonths: reserve,
    );
  }

  group('computeIndicators', () {
    test('valores do exemplo', () {
      final i = analyzer.computeIndicators(exemplo);
      expect(i.incomeCommitment, closeTo(64, 0.01));
      expect(i.debtLevel, closeTo(13.33, 0.01));
      expect(i.monthlySavings, closeTo(36, 0.01));
      expect(i.emergencyReserveMonths, closeTo(0.625, 0.001));
    });

    test('renda zero lança ArgumentError', () {
      const data = FinancialData(
        monthlyIncome: 0,
        monthlyExpenses: 100,
        totalDebt: 0,
        savings: 0,
      );
      expect(() => analyzer.computeIndicators(data), throwsArgumentError);
    });

    test('gastos zero lançam ArgumentError, a reserva não é calculável', () {
      const data = FinancialData(
        monthlyIncome: 5000,
        monthlyExpenses: 0,
        totalDebt: 0,
        savings: 0,
      );
      expect(() => analyzer.computeIndicators(data), throwsArgumentError);
    });

    test('gastos maiores que a renda dão poupança negativa, sem limitar', () {
      const data = FinancialData(
        monthlyIncome: 4000,
        monthlyExpenses: 5000,
        totalDebt: 0,
        savings: 0,
      );
      final i = analyzer.computeIndicators(data);
      expect(i.monthlySavings, closeTo(-25, 0.01));
      expect(i.incomeCommitment, closeTo(125, 0.01));
    });
  });

  group('computeScore', () {
    test('exemplo dá 50 pontos e situação Atenção', () {
      final score = analyzer.computeScore(analyzer.computeIndicators(exemplo));
      expect(score.value, closeTo(50, 1e-9));
      expect(score.displayValue, 50);
      expect(score.status, HealthStatus.atencao);
    });

    test('todos os indicadores saudáveis dão 100 e Saudável', () {
      const data = FinancialData(
        monthlyIncome: 10000,
        monthlyExpenses: 2000,
        totalDebt: 0,
        savings: 20000,
      );
      final score = analyzer.computeScore(analyzer.computeIndicators(data));
      expect(score.value, 100);
      expect(score.status, HealthStatus.saudavel);
    });

    test('tudo no limite crítico dá 0 e Crítico', () {
      const data = FinancialData(
        monthlyIncome: 4000,
        monthlyExpenses: 5000,
        totalDebt: 40000,
        savings: 0,
      );
      final score = analyzer.computeScore(analyzer.computeIndicators(data));
      expect(score.value, 0);
      expect(score.status, HealthStatus.critico);
    });

    test('valor no meio da faixa dá metade dos pontos, sem arredondar', () {
      // Comprometimento 40% fica no meio entre 30% e 50%: 12,5 pontos
      // Os outros três ficam na faixa saudável: 75 pontos
      const data = FinancialData(
        monthlyIncome: 10000,
        monthlyExpenses: 4000,
        totalDebt: 0,
        savings: 20000,
      );
      final score = analyzer.computeScore(analyzer.computeIndicators(data));
      expect(score.value, closeTo(87.5, 1e-9));
      expect(score.displayValue, 88);
      expect(score.status, HealthStatus.saudavel);
    });
  });

  group('classificação nos cortes 50 e 80, pelo valor sem arredondar', () {
    test('49,99 é Crítico e aparece como 50', () {
      // Comprometimento 30,008% dá 24,99 pontos; reserva 0 dá 0
      final score = analyzer.computeScore(
        crafted(commitment: 30.008, savings: 0, reserve: 0),
      );
      expect(score.value, closeTo(49.99, 1e-6));
      expect(score.displayValue, 50);
      expect(score.status, HealthStatus.critico);
    });

    test('50 é Atenção', () {
      // Comprometimento 30% dá 25, endividamento 0% dá 25, os outros dois dão 0
      final score = analyzer.computeScore(
        crafted(commitment: 30, savings: 0, reserve: 0),
      );
      expect(score.value, closeTo(50, 1e-9));
      expect(score.status, HealthStatus.atencao);
    });

    test('79,99 é Atenção e aparece como 80', () {
      // Comprometimento 46,008% dá 4,99 pontos; reserva 3 dá 25
      final score = analyzer.computeScore(crafted(commitment: 46.008));
      expect(score.value, closeTo(79.99, 1e-6));
      expect(score.displayValue, 80);
      expect(score.status, HealthStatus.atencao);
    });

    test('79,6 aparece como 80 e continua Atenção', () {
      final score = analyzer.computeScore(crafted(commitment: 46.32));
      expect(score.value, closeTo(79.6, 1e-6));
      expect(score.displayValue, 80);
      expect(score.status, HealthStatus.atencao);
    });

    test('80 é Saudável', () {
      // Comprometimento 46% dá exatamente 5 pontos
      final score = analyzer.computeScore(crafted(commitment: 46));
      expect(score.value, closeTo(80, 1e-9));
      expect(score.status, HealthStatus.saudavel);
    });
  });

  group('levelOf', () {
    test('exemplo: comprometimento e reserva críticos, os outros saudáveis', () {
      final i = analyzer.computeIndicators(exemplo);
      expect(
        analyzer.levelOf(IndicatorKind.incomeCommitment, i),
        IndicatorLevel.critical,
      );
      expect(analyzer.levelOf(IndicatorKind.debtLevel, i), IndicatorLevel.good);
      expect(
        analyzer.levelOf(IndicatorKind.monthlySavings, i),
        IndicatorLevel.good,
      );
      expect(
        analyzer.levelOf(IndicatorKind.emergencyReserve, i),
        IndicatorLevel.critical,
      );
    });

    test('faixa de atenção entre os dois limites', () {
      const data = FinancialData(
        monthlyIncome: 10000,
        monthlyExpenses: 4000,
        totalDebt: 50000,
        savings: 8000,
      );
      final i = analyzer.computeIndicators(data);
      expect(
        analyzer.levelOf(IndicatorKind.incomeCommitment, i),
        IndicatorLevel.warning,
      );
      expect(
        analyzer.levelOf(IndicatorKind.debtLevel, i),
        IndicatorLevel.warning,
      );
      expect(
        analyzer.levelOf(IndicatorKind.emergencyReserve, i),
        IndicatorLevel.warning,
      );
    });
  });

  group('buildRecommendations', () {
    test('sempre quatro, na ordem dos indicadores, com a faixa de cada um', () {
      final i = analyzer.computeIndicators(exemplo);
      final list = analyzer.buildRecommendations(i);

      expect(list, hasLength(4));
      for (var n = 0; n < 4; n++) {
        final kind = IndicatorKind.values[n];
        expect(list[n].kind, kind);
        expect(list[n].level, analyzer.levelOf(kind, i));
        expect(
          list[n].message,
          HealthMessages.recommendation(kind, list[n].level),
        );
      }
    });

    test('exemplo: textos críticos do comprometimento e da reserva', () {
      final list = analyzer.buildRecommendations(
        analyzer.computeIndicators(exemplo),
      );
      expect(list[0].level, IndicatorLevel.critical);
      expect(list[0].message, startsWith('Mais da metade da sua renda'));
      expect(list[1].level, IndicatorLevel.good);
      expect(list[2].level, IndicatorLevel.good);
      expect(list[3].level, IndicatorLevel.critical);
      expect(
        list[3].message,
        startsWith('Sua reserva cobre, no máximo, um mês'),
      );
    });

    test('faixa de atenção traz o texto de atenção', () {
      const data = FinancialData(
        monthlyIncome: 10000,
        monthlyExpenses: 4000,
        totalDebt: 0,
        savings: 20000,
      );
      final list = analyzer.buildRecommendations(
        analyzer.computeIndicators(data),
      );
      expect(list[0].level, IndicatorLevel.warning);
      expect(list[0].message, startsWith('Uma parte significativa'));
    });
  });

  group('analyze', () {
    test('traz a mensagem geral da faixa do score', () {
      final result = analyzer.analyze(exemplo);
      expect(result.score.status, HealthStatus.atencao);
      expect(
        result.generalMessage,
        HealthMessages.general(HealthStatus.atencao),
      );
      expect(
        result.generalMessage,
        startsWith('Há pontos que merecem atenção'),
      );
      expect(result.recommendations, hasLength(4));
    });
  });
}
