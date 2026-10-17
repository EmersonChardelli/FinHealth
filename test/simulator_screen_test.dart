import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finhealth/screens/simulator_screen.dart';
import 'package:finhealth/theme/app_theme.dart';
import 'package:finhealth/widgets/projection_chart.dart';

void main() {
  /// Abre a tela numa janela alta o bastante para o resultado caber.
  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const SimulatorScreen()),
    );
  }

  /// Preenche inicial, aporte, taxa e prazo, nessa ordem.
  Future<void> fill(WidgetTester tester, List<String> values) async {
    final fields = find.byType(TextFormField);
    for (var i = 0; i < values.length; i++) {
      await tester.enterText(fields.at(i), values[i]);
    }
  }

  Future<void> simulate(WidgetTester tester) async {
    await tester.tap(find.text('SIMULAR'));
    await tester.pumpAndSettle();
  }

  testWidgets('mostra os quatro campos, os dois seletores e o botão', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Simulador de Juros'), findsOneWidget);
    expect(find.text('Valor Inicial'), findsOneWidget);
    expect(find.text('Aporte Mensal'), findsOneWidget);
    expect(find.text('Taxa de Juros'), findsOneWidget);
    expect(find.text('Prazo'), findsOneWidget);
    expect(find.text('taxa ao mês'), findsOneWidget);
    expect(find.text('taxa ao ano'), findsOneWidget);
    // "meses" aparece no seletor e no sufixo do campo
    expect(find.text('meses'), findsNWidgets(2));
    expect(find.text('anos'), findsOneWidget);
    expect(find.text('SIMULAR'), findsOneWidget);
    expect(find.byType(ProjectionChart), findsNothing);
  });

  testWidgets('campos vazios não simulam', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextFormField).at(0), '');
    await simulate(tester);

    expect(find.text('Informe um valor'), findsNWidgets(2));
    expect(find.text('Informe a taxa'), findsOneWidget);
    expect(find.text('Informe o prazo'), findsOneWidget);
    expect(find.byType(ProjectionChart), findsNothing);
  });

  testWidgets('exemplo do relatório dá R\$ 3.663,33', (tester) async {
    await pump(tester);

    await fill(tester, ['1.000', '200', '1', '12']);
    await simulate(tester);

    expect(find.text('Montante final'), findsOneWidget);
    expect(find.text('R\$ 3.663,33'), findsOneWidget);
    expect(find.text('R\$ 3.400,00'), findsOneWidget);
    expect(find.text('R\$ 263,33'), findsOneWidget);
    expect(find.byType(ProjectionChart), findsOneWidget);
    // A tabela tem só a linha do mês 12
    expect(find.text('12'), findsWidgets);
    expect(find.text('R\$ 3.663'), findsOneWidget);
  });

  testWidgets('taxa ao ano é efetiva: 12% ao ano sobre 1.000 dá 1.120', (
    tester,
  ) async {
    await pump(tester);

    await fill(tester, ['1.000', '0', '12', '12']);
    await tester.tap(find.text('taxa ao ano'));
    await tester.pumpAndSettle();
    await simulate(tester);

    expect(find.text('R\$ 1.120,00'), findsOneWidget);
  });

  testWidgets('prazo em anos: 1 ano dá o mesmo que 12 meses', (tester) async {
    await pump(tester);

    await fill(tester, ['1.000', '200', '1', '1']);
    await tester.tap(find.text('anos'));
    await tester.pumpAndSettle();

    // O sufixo do campo passou a "anos"
    expect(find.text('anos'), findsNWidgets(2));
    expect(find.text('meses'), findsOneWidget);
    expect(find.textContaining('1 ano = 12 meses'), findsOneWidget);

    await simulate(tester);

    expect(find.text('R\$ 3.663,33'), findsOneWidget);
    expect(find.text('R\$ 3.400,00'), findsOneWidget);
  });

  testWidgets('trocar a unidade mantém o número digitado', (tester) async {
    await pump(tester);

    await fill(tester, ['1.000', '0', '1', '5']);
    await tester.tap(find.text('anos'));
    await tester.pumpAndSettle();

    expect(find.text('5'), findsOneWidget);

    await simulate(tester);

    // 5 anos = 60 meses: a tabela vai até o mês 60
    expect(find.text('60'), findsOneWidget);
  });

  testWidgets('prazo acima de 600 meses é recusado, também em anos', (
    tester,
  ) async {
    await pump(tester);

    await fill(tester, ['1.000', '0', '1', '51']);
    await tester.tap(find.text('anos'));
    await tester.pumpAndSettle();
    await simulate(tester);

    expect(find.text('Prazo máximo de 600 meses (50 anos)'), findsOneWidget);
    expect(find.byType(ProjectionChart), findsNothing);
  });

  testWidgets('prazo zero mostra só o capital inicial', (tester) async {
    await pump(tester);

    await fill(tester, ['1.000', '200', '1', '0']);
    await simulate(tester);

    // Montante e total investido são o mesmo R$ 1.000,00
    expect(find.text('R\$ 1.000,00'), findsNWidgets(2));
    expect(find.text('R\$ 0,00'), findsOneWidget);
    expect(find.byType(ProjectionChart), findsNothing);
  });

  testWidgets('a convenção do aporte aparece no resumo', (tester) async {
    await pump(tester);

    await fill(tester, ['1.000', '200', '1', '12']);
    await simulate(tester);

    expect(find.textContaining('Aporte no fim de cada mês'), findsOneWidget);
    expect(find.textContaining('(1 + i)^(1/12)'), findsOneWidget);
  });
}
