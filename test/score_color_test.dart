import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finhealth/services/score_color.dart';
import 'package:finhealth/theme/app_theme.dart';

void main() {
  int r(Color c) => (c.toARGB32() >> 16) & 0xFF;
  int g(Color c) => (c.toARGB32() >> 8) & 0xFF;
  int b(Color c) => c.toARGB32() & 0xFF;

  /// Maior diferença entre canais de duas cores.
  int maxChannelDiff(Color a, Color c) {
    return [
      (r(a) - r(c)).abs(),
      (g(a) - g(c)).abs(),
      (b(a) - b(c)).abs(),
    ].reduce((x, y) => x > y ? x : y);
  }

  test('0 é o vermelho, 50 o amarelo e 100 o verde de referência', () {
    expect(ScoreColor.forScore(0), AppColors.scoreRed);
    expect(ScoreColor.forScore(50), AppColors.scoreYellow);
    expect(ScoreColor.forScore(100), AppColors.scoreGreen);
  });

  test('fora da faixa fica preso nas pontas', () {
    expect(ScoreColor.forScore(-10), AppColors.scoreRed);
    expect(ScoreColor.forScore(140), AppColors.scoreGreen);
  });

  test('25 fica entre o vermelho e o amarelo, canal a canal', () {
    final c = ScoreColor.forScore(25);
    for (final channel in [r, g, b]) {
      final lo = channel(AppColors.scoreRed);
      final hi = channel(AppColors.scoreYellow);
      expect(
        channel(c),
        inInclusiveRange(lo < hi ? lo : hi, lo < hi ? hi : lo),
      );
    }
  });

  test('não há salto de cor em 50 nem em 80', () {
    expect(
      maxChannelDiff(ScoreColor.forScore(49.99), ScoreColor.forScore(50)),
      lessThanOrEqualTo(1),
    );
    expect(
      maxChannelDiff(ScoreColor.forScore(79.99), ScoreColor.forScore(80)),
      lessThanOrEqualTo(1),
    );
  });

  test('a cor muda aos poucos ao longo de toda a escala', () {
    for (var s = 0.0; s < 100; s += 1) {
      expect(
        maxChannelDiff(ScoreColor.forScore(s), ScoreColor.forScore(s + 1)),
        lessThanOrEqualTo(6),
      );
    }
  });
}
