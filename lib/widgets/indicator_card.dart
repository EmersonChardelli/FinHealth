import 'package:flutter/material.dart';

import '../models/financial_indicators.dart';
import '../theme/app_theme.dart';

/// Um dos quatro cartões de indicador: título, valor grande com unidade
/// menor, e uma barra fina colorida pela faixa.
class IndicatorCard extends StatelessWidget {
  const IndicatorCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.level,
    required this.fill,
  });

  final String title;

  /// O número, já formatado, como "64" ou "0,6".
  final String value;

  /// A unidade ao lado do número, como "%" ou "Meses".
  final String unit;

  final IndicatorLevel level;

  /// Quanto da barra fica pintado, de 0 a 1.
  final double fill;

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
    final color = colorFor(level);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  TextSpan(
                    text: unit == '%' ? '%' : ' $unit',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: fill.clamp(0, 1),
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
