import 'financial_indicators.dart';

/// A recomendação de um indicador, na faixa em que ele caiu.
class Recommendation {
  const Recommendation({
    required this.kind,
    required this.level,
    required this.message,
  });

  /// Qual indicador.
  final IndicatorKind kind;

  /// Faixa do indicador. Define o ícone e a cor na tela.
  final IndicatorLevel level;

  /// Texto de [HealthMessages] para este indicador nesta faixa.
  final String message;
}
