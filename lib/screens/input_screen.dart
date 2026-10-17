import 'dart:async';

import 'package:flutter/material.dart';

import '../models/financial_data.dart';
import '../services/financial_analyzer.dart';
import '../services/last_input_store.dart';
import '../theme/app_theme.dart';
import '../utils/money_format.dart';
import '../widgets/labeled_money_field.dart';
import 'result_screen.dart';
import 'simulator_screen.dart';

/// Tela "Informe Seus Dados": os quatro valores e o botão de análise.
class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  final _expensesController = TextEditingController();
  final _debtController = TextEditingController();
  final _savingsController = TextEditingController();

  static const _analyzer = FinancialAnalyzer();
  static const _store = LastInputStore();

  @override
  void initState() {
    super.initState();
    unawaited(_loadLastInput());
  }

  /// Preenche os campos com a última análise, se houver e se ainda estiverem vazios.
  Future<void> _loadLastInput() async {
    final data = await _store.load();
    if (!mounted || data == null || _incomeController.text.isNotEmpty) {
      return;
    }
    setState(() {
      _incomeController.text = MoneyFormat.formatInput(data.monthlyIncome);
      _expensesController.text = MoneyFormat.formatInput(data.monthlyExpenses);
      _debtController.text = MoneyFormat.formatInput(data.totalDebt);
      _savingsController.text = MoneyFormat.formatInput(data.savings);
    });
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _expensesController.dispose();
    _debtController.dispose();
    _savingsController.dispose();
    super.dispose();
  }

  /// Aceita qualquer valor de zero para cima.
  String? _validateAmount(String? text) {
    final value = MoneyFormat.parse(text ?? '');
    if (value == null) {
      return 'Informe um valor';
    }
    if (value < 0) {
      return 'O valor não pode ser negativo';
    }
    return null;
  }

  /// A renda também precisa ser maior que zero, senão não há como dividir.
  String? _validateIncome(String? text) {
    final error = _validateAmount(text);
    if (error != null) {
      return error;
    }
    if (MoneyFormat.parse(text!)! <= 0) {
      return 'Informe uma renda maior que zero';
    }
    return null;
  }

  /// Os gastos também, porque a reserva é medida em meses de gastos.
  String? _validateExpenses(String? text) {
    final error = _validateAmount(text);
    if (error != null) {
      return error;
    }
    if (MoneyFormat.parse(text!)! <= 0) {
      return 'Informe gastos maiores que zero';
    }
    return null;
  }

  void _analyze() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final data = FinancialData(
      monthlyIncome: MoneyFormat.parse(_incomeController.text)!,
      monthlyExpenses: MoneyFormat.parse(_expensesController.text)!,
      totalDebt: MoneyFormat.parse(_debtController.text)!,
      savings: MoneyFormat.parse(_savingsController.text)!,
    );

    final result = _analyzer.analyze(data);

    // Guarda os valores para a próxima abertura do app, sem esperar a gravação
    unawaited(_store.save(data));

    // Empurra a tela de resultado por cima, os campos ficam como estão
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ResultScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informe Seus Dados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate_outlined),
            tooltip: 'Simulador de juros compostos',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SimulatorScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _WalletIllustration(),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 16),
                LabeledMoneyField(
                  label: 'Renda Mensal',
                  icon: Icons.payments_outlined,
                  controller: _incomeController,
                  validator: _validateIncome,
                ),
                const SizedBox(height: 20),
                LabeledMoneyField(
                  label: 'Gastos Mensais',
                  icon: Icons.shopping_cart_outlined,
                  controller: _expensesController,
                  validator: _validateExpenses,
                ),
                const SizedBox(height: 20),
                LabeledMoneyField(
                  label: 'Dívidas',
                  icon: Icons.credit_card,
                  controller: _debtController,
                  validator: _validateAmount,
                ),
                const SizedBox(height: 20),
                LabeledMoneyField(
                  label: 'Investimentos / Poupança',
                  icon: Icons.eco_outlined,
                  controller: _savingsController,
                  validator: _validateAmount,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _analyze,
                  child: const Text('ANALISAR MINHA SAÚDE FINANCEIRA'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A carteira do topo da tela, feita com um ícone do Material.
class _WalletIllustration extends StatelessWidget {
  const _WalletIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: const BoxDecoration(
          color: Color(0xFFD8E6F7),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.account_balance_wallet,
          size: 64,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
