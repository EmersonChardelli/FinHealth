import 'package:flutter_test/flutter_test.dart';
import 'package:finhealth/models/financial_indicators.dart';
import 'package:finhealth/services/financial_thresholds.dart';

void main() {
  double pts(IndicatorKind kind, double value) =>
      FinancialThresholds.points(kind, value);
  IndicatorLevel lvl(IndicatorKind kind, double value) =>
      FinancialThresholds.level(kind, value);

  group('limites das faixas, abaixo, igual e acima do corte', () {
    test('comprometimento: 30% saudável e 25 pontos, 50% crítico e 0', () {
      const k = IndicatorKind.incomeCommitment;
      expect(pts(k, 29.99), 25);
      expect(pts(k, 30), 25);
      expect(lvl(k, 30), IndicatorLevel.good);
      expect(pts(k, 30.01), lessThan(25));
      expect(lvl(k, 30.01), IndicatorLevel.warning);
      expect(pts(k, 49.99), greaterThan(0));
      expect(lvl(k, 49.99), IndicatorLevel.warning);
      expect(pts(k, 50), 0);
      expect(lvl(k, 50), IndicatorLevel.critical);
      expect(pts(k, 50.01), 0);
    });

    test('endividamento: 30% saudável e 25 pontos, 60% crítico e 0', () {
      const k = IndicatorKind.debtLevel;
      expect(pts(k, 30), 25);
      expect(lvl(k, 30), IndicatorLevel.good);
      expect(lvl(k, 30.01), IndicatorLevel.warning);
      expect(lvl(k, 59.99), IndicatorLevel.warning);
      expect(pts(k, 60), 0);
      expect(lvl(k, 60), IndicatorLevel.critical);
    });

    test('poupança: 0% crítica e 0 pontos, 10% saudável e 25', () {
      const k = IndicatorKind.monthlySavings;
      expect(pts(k, -5), 0);
      expect(pts(k, 0), 0);
      expect(lvl(k, 0), IndicatorLevel.critical);
      expect(lvl(k, 0.01), IndicatorLevel.warning);
      expect(lvl(k, 9.99), IndicatorLevel.warning);
      expect(pts(k, 10), 25);
      expect(lvl(k, 10), IndicatorLevel.good);
    });

    test('reserva: 1 mês crítica e 0 pontos, 3 meses saudável e 25', () {
      const k = IndicatorKind.emergencyReserve;
      expect(pts(k, 0), 0);
      expect(pts(k, 1), 0);
      expect(lvl(k, 1), IndicatorLevel.critical);
      expect(lvl(k, 1.01), IndicatorLevel.warning);
      expect(lvl(k, 2.99), IndicatorLevel.warning);
      expect(pts(k, 3), 25);
      expect(lvl(k, 3), IndicatorLevel.good);
    });
  });

  group('exemplos de metade dos pontos', () {
    test('40%, 45%, 5% e 2 meses dão 12,5 cada', () {
      expect(pts(IndicatorKind.incomeCommitment, 40), closeTo(12.5, 1e-9));
      expect(pts(IndicatorKind.debtLevel, 45), closeTo(12.5, 1e-9));
      expect(pts(IndicatorKind.monthlySavings, 5), closeTo(12.5, 1e-9));
      expect(pts(IndicatorKind.emergencyReserve, 2), closeTo(12.5, 1e-9));
    });

    test('os pontos ficam sempre entre 0 e 25', () {
      for (final k in IndicatorKind.values) {
        for (var v = -50.0; v <= 200; v += 0.5) {
          final p = pts(k, v);
          expect(p, greaterThanOrEqualTo(0));
          expect(p, lessThanOrEqualTo(25));
        }
      }
    });
  });
}
