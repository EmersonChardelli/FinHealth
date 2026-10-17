import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/health_score.dart';
import '../services/score_color.dart';
import '../theme/app_theme.dart';

/// O medidor em arco: um trilho cinza, o trecho de 0 até o score pintado num
/// degradê vermelho, amarelo e verde, e o número no centro na cor do score.
class ScoreGauge extends StatelessWidget {
  const ScoreGauge({super.key, required this.score});

  final HealthScore score;

  static const double _width = 240;
  static const double _height = 150;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: _height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(_width, _height),
            painter: _GaugePainter(value: score.value),
          ),
          Positioned(
            bottom: 8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Score',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${score.displayValue}',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: ScoreColor.forScore(score.value),
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.value});

  final double value;

  /// O arco cobre 240 graus, de 150 graus (baixo à esquerda) até 30 graus
  /// (baixo à direita), no sentido horário.
  static const double _startAngle = 150 * math.pi / 180;
  static const double _sweepAngle = 240 * math.pi / 180;
  static const double _stroke = 22;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 12);
    final radius = math.min(size.width / 2, size.height) - _stroke;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Trilho cinza do arco inteiro
    canvas.drawArc(
      rect,
      _startAngle,
      _sweepAngle,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round
        ..color = AppColors.border,
    );

    final fraction = value.clamp(0.0, 100.0) / 100;
    if (fraction <= 0) {
      return;
    }

    // Degradê fixo ao longo do arco, vermelho em 0, amarelo em 50, verde em 100
    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: _sweepAngle,
      colors: const [
        AppColors.scoreRed,
        AppColors.scoreYellow,
        AppColors.scoreGreen,
      ],
      stops: const [0, 0.5, 1],
      transform: const GradientRotation(_startAngle),
    );

    // Pinta só até a posição do score, com pontas retas: uma ponta redonda
    // passaria do início do arco, onde o degradê dá a volta e fica verde
    canvas.drawArc(
      rect,
      _startAngle,
      _sweepAngle * fraction,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.butt
        ..shader = gradient.createShader(rect),
    );

    // Pontas redondas desenhadas à mão, cada uma na cor do seu lado
    _roundEnd(canvas, center, radius, _startAngle, AppColors.scoreRed);
    _roundEnd(
      canvas,
      center,
      radius,
      _startAngle + _sweepAngle * fraction,
      ScoreColor.forScore(value),
    );
  }

  void _roundEnd(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    Color color,
  ) {
    final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
    canvas.drawCircle(point, _stroke / 2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) => oldDelegate.value != value;
}
