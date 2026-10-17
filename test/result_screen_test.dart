import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finhealth/models/financial_data.dart';
import 'package:finhealth/screens/result_screen.dart';
import 'package:finhealth/services/financial_analyzer.dart';
import 'package:finhealth/theme/app_theme.dart';
import 'package:finhealth/widgets/indicator_card.dart';
import 'package:finhealth/widgets/recommendation_tile.dart';
import 'package:finhealth/widgets/score_gauge.dart';

void main() {
  const analyzer = FinancialAnalyzer();

  /// Abre a tela numa janela alta o bastante para a lista inteira caber,
  /// senão a lista não constrói o que fica abaixo da dobra.
  Future<void> pump(WidgetTester tester, FinancialData data) async {
    tester.view.physicalSize = const Size(800, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ResultScreen(result: analyzer.analyze(data)),
      ),
    );
  }

  const exemplo = FinancialData(
    monthlyIncome: 5000,
    monthlyExpenses: 3200,
    totalDebt: 8000,
    savings: 2000,
  );

  const allGood = FinancialData(
    monthlyIncome: 10000,
    monthlyExpenses: 2000,
    totalDebt: 0,
    savings: 20000,
  );

  testWidgets('exemplo: medidor, score 50, situação e mensagem geral', (
    tester,
  ) async {
    await pump(tester, exemplo);

    expect(find.text('Sua Saúde Financeira'), findsOneWidget);
    expect(find.byType(ScoreGauge), findsOneWidget);
    expect(find.text('Score'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
    expect(find.text('Situação: Atenção'), findsOneWidget);
    expect(
      find.textContaining('Há pontos que merecem atenção'),
      findsOneWidget,
    );
  });

  testWidgets('exemplo: quatro cartões com os valores calculados', (
    tester,
  ) async {
    await pump(tester, exemplo);

    expect(find.byType(IndicatorCard), findsNWidgets(4));
    expect(find.text('Renda Comprometida com Despesas'), findsOneWidget);
    expect(find.text('Endividamento'), findsOneWidget);
    expect(find.text('Poupança Mensal'), findsOneWidget);
    expect(find.text('Reserva de Emergência'), findsOneWidget);
    expect(find.text('64%'), findsOneWidget);
    expect(find.text('13%'), findsOneWidget);
    expect(find.text('36%'), findsOneWidget);
    expect(find.text('0,6 Meses'), findsOneWidget);
  });

  testWidgets('exemplo: quatro recomendações, duas críticas e duas saudáveis', (
    tester,
  ) async {
    await pump(tester, exemplo);

    expect(find.text('Recomendações'), findsOneWidget);
    expect(find.byType(RecommendationTile), findsNWidgets(4));
    expect(find.byIcon(Icons.warning_amber_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(2));
    expect(find.byIcon(Icons.lightbulb_outline), findsNothing);
    expect(
      find.text('Renda Comprometida com Despesas: Crítico'),
      findsOneWidget,
    );
    expect(find.text('Endividamento: Saudável'), findsOneWidget);
    expect(
      find.textContaining('Mais da metade da sua renda está comprometida'),
      findsOneWidget,
    );
  });

  testWidgets(
    'todos saudáveis: 100, Saudável, quatro vistos e a mensagem geral',
    (tester) async {
      await pump(tester, allGood);

      expect(find.text('100'), findsOneWidget);
      expect(find.text('Situação: Saudável'), findsOneWidget);
      expect(find.text('10 Meses'), findsOneWidget);
      expect(find.byType(RecommendationTile), findsNWidgets(4));
      expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(4));
      expect(
        find.textContaining('Os indicadores apresentam resultados favoráveis'),
        findsOneWidget,
      );
    },
  );

  testWidgets('faixa de atenção mostra a lâmpada e o texto de atenção', (
    tester,
  ) async {
    const data = FinancialData(
      monthlyIncome: 10000,
      monthlyExpenses: 4000,
      totalDebt: 0,
      savings: 20000,
    );
    await pump(tester, data);

    // 87,5 aparece como 88
    expect(find.text('88'), findsOneWidget);
    expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    expect(
      find.text('Renda Comprometida com Despesas: Atenção'),
      findsOneWidget,
    );
  });
}
