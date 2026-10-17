import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Cor contínua do score: vermelho em 0, amarelo em 50,
/// verde em 100, interpolada canal a canal entre os vizinhos. A cor vem do
/// número, não do rótulo, então não dá salto em 50 nem em 80.
class ScoreColor {
  ScoreColor._();

  /// Cor para um score de 0 a 100. Valores fora da faixa são limitados a ela.
  static Color forScore(double score) {
    final s = score.clamp(0.0, 100.0);
    if (s <= 50) {
      return _mix(AppColors.scoreRed, AppColors.scoreYellow, s / 50);
    }
    return _mix(AppColors.scoreYellow, AppColors.scoreGreen, (s - 50) / 50);
  }

  /// Interpola cada canal e arredonda para um inteiro de 0 a 255.
  static Color _mix(Color from, Color to, double t) {
    int channel(int a, int b) => (a + t * (b - a)).round().clamp(0, 255);
    final f = from.toARGB32();
    final g = to.toARGB32();
    return Color.fromARGB(
      255,
      channel((f >> 16) & 0xFF, (g >> 16) & 0xFF),
      channel((f >> 8) & 0xFF, (g >> 8) & 0xFF),
      channel(f & 0xFF, g & 0xFF),
    );
  }
}
