import 'package:flutter_test/flutter_test.dart';
import 'package:finhealth/services/compound_interest_simulator.dart';

void main() {
  const simulator = CompoundInterestSimulator();

  group('monthlyRate', () {
    test('taxa ao mês vira fração direto', () {
      expect(simulator.monthlyRate(1, RatePeriod.mensal), closeTo(0.01, 1e-9));
      expect(simulator.monthlyRate(0, RatePeriod.mensal), 0);
    });

    test('taxa ao ano é efetiva, convertida com (1 + ia)^(1/12) − 1', () {
      // 12,6825% ao ano equivale a 1% ao mês
      expect(
        simulator.monthlyRate(12.6825, RatePeriod.anual),
        closeTo(0.01, 1e-6),
      );
      // E não é 12% / 12 = 1%
      expect(simulator.monthlyRate(12, RatePeriod.anual), lessThan(0.01));
    });
  });

  group('monthsFor', () {
    test('meses ficam como estão', () {
      expect(simulator.monthsFor(12, TermUnit.meses), 12);
      expect(simulator.monthsFor(0, TermUnit.meses), 0);
    });

    test('anos viram meses: 1, 5 e 10 anos', () {
      expect(simulator.monthsFor(1, TermUnit.anos), 12);
      expect(simulator.monthsFor(5, TermUnit.anos), 60);
      expect(simulator.monthsFor(10, TermUnit.anos), 120);
    });
  });

  group('simulate', () {
    test(
      'exemplo do relatório: 1.000 inicial, 200 por mês, 1% ao mês, 12 meses',
      () {
        final points = simulator.simulate(
          initial: 1000,
          monthlyDeposit: 200,
          monthlyRate: 0.01,
          months: 12,
        );
        expect(points, hasLength(13));
        expect(points.first.month, 0);
        expect(points.first.balance, 1000);
        expect(points.last.month, 12);
        expect(points.last.invested, 3400);
        expect(points.last.balance, closeTo(3663.33, 0.01));
        expect(points.last.interest, closeTo(263.33, 0.01));
      },
    );

    test('exemplo sem aporte dá 1.126,83', () {
      final points = simulator.simulate(
        initial: 1000,
        monthlyDeposit: 0,
        monthlyRate: 0.01,
        months: 12,
      );
      expect(points.last.invested, 1000);
      expect(points.last.balance, closeTo(1126.83, 0.01));
      expect(points.last.interest, closeTo(126.83, 0.01));
    });

    test('taxa zero dá C₀ + A × n, sem divisão por zero', () {
      final points = simulator.simulate(
        initial: 1000,
        monthlyDeposit: 200,
        monthlyRate: 0,
        months: 12,
      );
      expect(points.last.balance, 3400);
      expect(points.last.interest, 0);
    });

    test('prazo zero devolve só o mês 0, que é o capital', () {
      final points = simulator.simulate(
        initial: 1000,
        monthlyDeposit: 200,
        monthlyRate: 0.01,
        months: 0,
      );
      expect(points, hasLength(1));
      expect(points.single.balance, 1000);
      expect(points.single.invested, 1000);
    });

    test('1 ano em anos dá o mesmo que 12 meses', () {
      final byMonths = simulator.simulate(
        initial: 1000,
        monthlyDeposit: 200,
        monthlyRate: 0.01,
        months: simulator.monthsFor(12, TermUnit.meses),
      );
      final byYears = simulator.simulate(
        initial: 1000,
        monthlyDeposit: 200,
        monthlyRate: 0.01,
        months: simulator.monthsFor(1, TermUnit.anos),
      );
      expect(byYears.last.balance, byMonths.last.balance);
    });

    test('o saldo nunca diminui com taxa e aporte de zero para cima', () {
      final points = simulator.simulate(
        initial: 500,
        monthlyDeposit: 50,
        monthlyRate: 0.005,
        months: 36,
      );
      for (var i = 1; i < points.length; i++) {
        expect(points[i].balance, greaterThanOrEqualTo(points[i - 1].balance));
      }
    });
  });
}
