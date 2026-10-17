import 'package:flutter/material.dart';

import '../models/compound_interest_point.dart';
import '../theme/app_theme.dart';

/// Gráfico de linha da projeção: o investido em cinza e o saldo em azul.
class ProjectionChart extends StatelessWidget {
  const ProjectionChart({super.key, required this.points});

  final List<CompoundInterestPoint> points;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: CustomPaint(painter: _ChartPainter(points: points)),
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            _LegendDot(color: AppColors.primary, label: 'Saldo com juros'),
            SizedBox(width: 16),
            _LegendDot(color: AppColors.textMuted, label: 'Total investido'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  const _ChartPainter({required this.points});

  final List<CompoundInterestPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    final maxValue = points.last.balance <= 0 ? 1.0 : points.last.balance;
    final lastMonth = points.last.month.toDouble();

    Offset place(int month, double value) {
      final x = size.width * (month / lastMonth);
      final y = size.height - size.height * (value / maxValue);
      return Offset(x, y);
    }

    // Quatro linhas de grade horizontais
    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Linha do investido, em cinza
    final investedPath = Path()..moveTo(0, place(0, points.first.invested).dy);
    for (final p in points) {
      final o = place(p.month, p.invested);
      investedPath.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
      investedPath,
      Paint()
        ..color = AppColors.textMuted
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Linha do saldo, em azul, com a área embaixo pintada de leve
    final balancePath = Path()..moveTo(0, place(0, points.first.balance).dy);
    for (final p in points) {
      final o = place(p.month, p.balance);
      balancePath.lineTo(o.dx, o.dy);
    }
    final area = Path.from(balancePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()..color = AppColors.primary.withValues(alpha: 0.12),
    );
    canvas.drawPath(
      balancePath,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) => oldDelegate.points != points;
}
