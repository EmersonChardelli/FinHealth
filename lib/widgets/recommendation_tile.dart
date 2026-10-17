import 'package:flutter/material.dart';

import '../models/financial_indicators.dart';
import '../models/recommendation.dart';
import '../theme/app_theme.dart';

/// Um cartão de recomendação: ícone da faixa à esquerda, o nome do indicador
/// e a mensagem ao lado.
class RecommendationTile extends StatelessWidget {
  const RecommendationTile({super.key, required this.recommendation});

  final Recommendation recommendation;

  /// Ícone de cada faixa: visto, lâmpada ou triângulo.
  static IconData iconFor(IndicatorLevel level) {
    switch (level) {
      case IndicatorLevel.good:
        return Icons.check_circle_outline;
      case IndicatorLevel.warning:
        return Icons.lightbulb_outline;
      case IndicatorLevel.critical:
        return Icons.warning_amber_rounded;
    }
  }

  static Color colorFor(IndicatorLevel level) {
    switch (level) {
      case IndicatorLevel.good:
        return AppColors.good;
      case IndicatorLevel.warning:
        return AppColors.warning;
      case IndicatorLevel.critical:
        return AppColors.critical;
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = recommendation.level;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(iconFor(level), color: colorFor(level), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${recommendation.kind.title}: ${level.label}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recommendation.message,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: AppColors.textDark,
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
