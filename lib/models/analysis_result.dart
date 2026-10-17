import 'financial_data.dart';
import 'financial_indicators.dart';
import 'health_score.dart';
import 'recommendation.dart';

/// Tudo o que a tela de resultado precisa, calculado de uma vez.
class AnalysisResult {
  const AnalysisResult({
    required this.data,
    required this.indicators,
    required this.score,
    required this.generalMessage,
    required this.recommendations,
  });

  final FinancialData data;
  final FinancialIndicators indicators;
  final HealthScore score;

  /// Mensagem geral da faixa do score.
  final String generalMessage;

  /// Uma por indicador, sempre quatro, na ordem de [IndicatorKind.values].
  final List<Recommendation> recommendations;
}
