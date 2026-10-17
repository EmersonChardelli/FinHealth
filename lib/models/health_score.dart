/// Situação geral da saúde financeira, derivada do score.
enum HealthStatus {
  saudavel('Saudável'),
  atencao('Atenção'),
  critico('Crítico');

  const HealthStatus(this.label);

  /// Texto mostrado na tela, como em "Situação: Atenção".
  final String label;
}

/// Score de 0 a 100 e a situação correspondente.
class HealthScore {
  const HealthScore({required this.value, required this.status});

  /// Soma dos pontos dos quatro indicadores, de 0 a 100, sem arredondar.
  /// A situação e a cor vêm deste valor.
  final double value;

  /// Faixa em que o score caiu, decidida pelo [value] sem arredondar.
  final HealthStatus status;

  /// O número mostrado na tela. 79,6 aparece como 80 e continua "Atenção".
  int get displayValue => value.round();
}
