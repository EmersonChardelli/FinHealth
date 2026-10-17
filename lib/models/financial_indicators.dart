/// Os quatro indicadores financeiros já calculados.
class FinancialIndicators {
  const FinancialIndicators({
    required this.incomeCommitment,
    required this.debtLevel,
    required this.monthlySavings,
    required this.emergencyReserveMonths,
  });

  /// Renda comprometida com despesas, em pontos percentuais:
  /// gastos / renda × 100.
  final double incomeCommitment;

  /// Nível de endividamento, em pontos percentuais: dívidas / renda anual × 100.
  final double debtLevel;

  /// Poupança mensal, em pontos percentuais: (renda − gastos) / renda × 100.
  /// Fica negativa quando os gastos passam da renda, e não é limitada a zero.
  final double monthlySavings;

  /// Reserva de emergência em meses de gastos: investimentos / gastos.
  /// Só existe com gastos maiores que zero; a entrada valida isso antes.
  final double emergencyReserveMonths;
}

/// Identifica cada um dos quatro indicadores, com o título mostrado na tela.
enum IndicatorKind {
  incomeCommitment('Renda Comprometida com Despesas'),
  debtLevel('Endividamento'),
  monthlySavings('Poupança Mensal'),
  emergencyReserve('Reserva de Emergência');

  const IndicatorKind(this.title);

  final String title;
}

/// Faixa em que um indicador caiu.
enum IndicatorLevel {
  /// Dentro do recomendado. "Saudável" na tela.
  good('Saudável'),

  /// Fora do recomendado, mas antes do limite crítico. "Atenção" na tela.
  warning('Atenção'),

  /// No limite crítico ou além dele. "Crítico" na tela.
  critical('Crítico');

  const IndicatorLevel(this.label);

  final String label;
}
