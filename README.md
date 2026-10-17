# FinHealth

Aplicativo mobile (Flutter/Dart) para avaliar a saúde financeira pessoal.
Desenvolvido como Trabalho de Conclusão de Curso de Ciência da Computação
no UNIFESO.

## Funcionalidades

- Entrada de renda mensal, gastos mensais, dívidas e investimentos/poupança,
  com máscara de valores no padrão brasileiro.
- Quatro indicadores: comprometimento da renda, endividamento, poupança
  mensal e reserva de emergência (em meses de gastos).
- FinHealth Score de 0 a 100, com situação (Crítico, Atenção ou Saudável),
  cor contínua e recomendações por indicador.
- Simulador de juros compostos com aportes mensais, taxa ao mês ou ao ano
  (efetiva) e prazo em meses ou anos.
- Últimos dados informados guardados no próprio aparelho; nada é enviado
  para servidores.

## Como executar

```bash
flutter pub get
flutter run
```

## Testes e análise estática

```bash
flutter test
flutter analyze
```

## Estrutura de `lib/`

- `models/`: estruturas de dados (dados informados, indicadores, score).
- `services/`: regras de cálculo, limites, mensagens, simulador e persistência.
- `utils/`: formatação e leitura de valores monetários.
- `screens/` e `widgets/`: interface.
- `theme/`: cores e tema.
