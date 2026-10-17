import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../models/financial_indicators.dart';
import '../models/health_score.dart';
import '../services/financial_analyzer.dart';
import '../services/financial_thresholds.dart';
import '../services/score_color.dart';
import '../theme/app_theme.dart';
import '../utils/money_format.dart';
import '../widgets/indicator_card.dart';
import '../widgets/recommendation_tile.dart';
import '../widgets/score_gauge.dart';

/// Tela "Sua Saúde Financeira": o medidor com o score, a mensagem geral, os
/// quatro cartões de indicador e as quatro recomendações.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final AnalysisResult result;

  static const _analyzer = FinancialAnalyzer();

  @override
  Widget build(BuildContext context) {
    final indicators = result.indicators;

    return Scaffold(
      appBar: AppBar(title: const Text('Sua Saúde Financeira')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _ScoreCard(score: result.score),
            const SizedBox(height: 12),
            _GeneralMessageCard(message: result.generalMessage),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.55,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _card(
                  kind: IndicatorKind.incomeCommitment,
                  value: _percent(indicators.incomeCommitment),
                  unit: '%',
                ),
                _card(
                  kind: IndicatorKind.debtLevel,
                  value: _percent(indicators.debtLevel),
                  unit: '%',
                ),
                _card(
                  kind: IndicatorKind.monthlySavings,
                  value: _percent(indicators.monthlySavings),
                  unit: '%',
                ),
                _card(
                  kind: IndicatorKind.emergencyReserve,
                  value: _formatMonths(indicators.emergencyReserveMonths),
                  unit: 'Meses',
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Recomendações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            for (final recommendation in result.recommendations) ...[
              RecommendationTile(recommendation: recommendation),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 6),
            const Text(
              'As mensagens são orientações gerais baseadas nos valores '
              'informados, e não aconselhamento financeiro individual.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  /// Monta um cartão com a faixa e o preenchimento vindos dos pontos.
  Widget _card({
    required IndicatorKind kind,
    required String value,
    required String unit,
  }) {
    final indicators = result.indicators;
    final points = FinancialThresholds.points(kind, _valueOf(kind, indicators));

    return IndicatorCard(
      title: kind.title,
      value: value,
      unit: unit,
      level: _analyzer.levelOf(kind, indicators),
      // Barra cheia na faixa saudável, quase vazia no limite crítico
      fill: (points / FinancialThresholds.maxPoints).clamp(0.06, 1.0),
    );
  }

  static double _valueOf(IndicatorKind kind, FinancialIndicators indicators) {
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

  /// Só o número, arredondado; o "%" vai na unidade do cartão.
  static String _percent(double value) {
    return MoneyFormat.formatPercent(value).replaceAll('%', '');
  }

  /// "0,6" abaixo de dez meses, "12" a partir daí.
  static String _formatMonths(double months) {
    if (months < 10) {
      return months.toStringAsFixed(1).replaceAll('.', ',');
    }
    return months.round().toString();
  }
}

/// O cartão branco do topo com o medidor e a linha "Situação: ...".
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score});

  final HealthScore score;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScoreGauge(score: score),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Situação: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  TextSpan(
                    text: score.status.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      // A cor vem do score, não do rótulo
                      color: ScoreColor.forScore(score.value),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A mensagem geral da faixa do score, logo abaixo do medidor.
class _GeneralMessageCard extends StatelessWidget {
  const _GeneralMessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppColors.primary, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
