import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finhealth/screens/input_screen.dart';
import 'package:finhealth/screens/result_screen.dart';
import 'package:finhealth/screens/simulator_screen.dart';
import 'package:finhealth/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const buttonLabel = 'ANALISAR MINHA SAÚDE FINANCEIRA';

  setUp(() {
    // Sem análise anterior guardada
    SharedPreferences.setMockInitialValues({});
  });

  Widget app() {
    return MaterialApp(theme: AppTheme.light(), home: const InputScreen());
  }

  /// Preenche os quatro campos na ordem da tela.
  Future<void> fill(WidgetTester tester, List<String> values) async {
    final fields = find.byType(TextFormField);
    for (var i = 0; i < values.length; i++) {
      await tester.enterText(fields.at(i), values[i]);
    }
  }

  /// Rola até o botão e toca nele.
  Future<void> tapAnalyze(WidgetTester tester) async {
    await tester.ensureVisible(find.text(buttonLabel));
    await tester.tap(find.text(buttonLabel));
    await tester.pumpAndSettle();
  }

  testWidgets('mostra os quatro campos e o botão', (tester) async {
    await tester.pumpWidget(app());

    expect(find.text('Informe Seus Dados'), findsOneWidget);
    expect(find.text('Renda Mensal'), findsOneWidget);
    expect(find.text('Gastos Mensais'), findsOneWidget);
    expect(find.text('Dívidas'), findsOneWidget);
    expect(find.text('Investimentos / Poupança'), findsOneWidget);
    expect(find.text(buttonLabel), findsOneWidget);
  });

  testWidgets('campos vazios não trocam de tela', (tester) async {
    await tester.pumpWidget(app());

    await tapAnalyze(tester);

    expect(find.text('Informe um valor'), findsNWidgets(4));
    expect(find.byType(ResultScreen), findsNothing);
  });

  testWidgets('renda zero mostra a mensagem e fica na tela', (tester) async {
    await tester.pumpWidget(app());

    await fill(tester, ['0', '100', '0', '0']);
    await tapAnalyze(tester);

    expect(find.text('Informe uma renda maior que zero'), findsOneWidget);
    expect(find.byType(ResultScreen), findsNothing);
  });

  testWidgets('gastos zero mostram a mensagem e ficam na tela', (tester) async {
    await tester.pumpWidget(app());

    await fill(tester, ['1000', '0', '0', '0']);
    await tapAnalyze(tester);

    expect(find.text('Informe gastos maiores que zero'), findsOneWidget);
    expect(find.byType(ResultScreen), findsNothing);
  });

  testWidgets('o campo formata em reais enquanto digita', (tester) async {
    await tester.pumpWidget(app());

    await fill(tester, ['123456', '1234,5', '0', '0']);

    expect(find.text('123.456'), findsOneWidget);
    expect(find.text('1.234,5'), findsOneWidget);
  });

  testWidgets('valores do exemplo abrem o resultado com score 50', (
    tester,
  ) async {
    await tester.pumpWidget(app());

    await fill(tester, ['5.000', '3.200', '8.000', '2.000']);
    await tapAnalyze(tester);

    expect(find.byType(ResultScreen), findsOneWidget);
    expect(find.text('Sua Saúde Financeira'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
    expect(find.text('Situação: Atenção'), findsOneWidget);
  });

  testWidgets('voltar mantém os valores digitados', (tester) async {
    await tester.pumpWidget(app());

    await fill(tester, ['5000', '3200', '8000', '2000']);
    await tapAnalyze(tester);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(InputScreen), findsOneWidget);
    expect(find.text('5.000'), findsOneWidget);
    expect(find.text('3.200'), findsOneWidget);
  });

  testWidgets('analisar guarda os valores para a próxima abertura', (
    tester,
  ) async {
    await tester.pumpWidget(app());

    await fill(tester, ['5.000', '3.200', '8.000', '2.000']);
    await tapAnalyze(tester);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('last_income'), 5000);
    expect(prefs.getDouble('last_expenses'), 3200);
    expect(prefs.getDouble('last_debt'), 8000);
    expect(prefs.getDouble('last_savings'), 2000);
  });

  testWidgets('os campos abrem preenchidos com a última análise', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'last_income': 5000.0,
      'last_expenses': 3200.5,
      'last_debt': 8000.0,
      'last_savings': 2000.0,
    });

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('5.000'), findsOneWidget);
    expect(find.text('3.200,50'), findsOneWidget);
    expect(find.text('8.000'), findsOneWidget);
    expect(find.text('2.000'), findsOneWidget);
  });

  testWidgets('o ícone da barra abre o simulador', (tester) async {
    await tester.pumpWidget(app());

    await tester.tap(find.byIcon(Icons.calculate_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(SimulatorScreen), findsOneWidget);
    expect(find.text('Simulador de Juros'), findsOneWidget);
  });
}
