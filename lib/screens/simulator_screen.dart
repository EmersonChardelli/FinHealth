import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/compound_interest_point.dart';
import '../services/compound_interest_simulator.dart';
import '../theme/app_theme.dart';
import '../utils/money_format.dart';
import '../widgets/labeled_money_field.dart';
import '../widgets/projection_chart.dart';

/// Tela "Simulador de Juros Compostos": quatro entradas, o resultado, o
/// gráfico e a tabela ano a ano.
class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _initialController = TextEditingController(text: '0');
  final _depositController = TextEditingController();
  final _rateController = TextEditingController();
  final _termController = TextEditingController();

  /// Em que período a taxa foi digitada. Só muda a conversão da taxa.
  RatePeriod _ratePeriod = RatePeriod.mensal;

  /// Em que unidade o prazo foi digitado. O número fica, a unidade muda o
  /// sufixo, a validação e o cálculo.
  TermUnit _termUnit = TermUnit.meses;

  List<CompoundInterestPoint>? _points;

  static const _simulator = CompoundInterestSimulator();
  static const _maxMonths = 600;

  @override
  void dispose() {
    _initialController.dispose();
    _depositController.dispose();
    _rateController.dispose();
    _termController.dispose();
    super.dispose();
  }

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

  String? _validateRate(String? text) {
    final value = MoneyFormat.parseRate(text ?? '');
    if (value == null) {
      return 'Informe a taxa';
    }
    if (value < 0) {
      return 'A taxa não pode ser negativa';
    }
    return null;
  }

  /// Aceita zero; o limite é conferido em meses, seja qual for a unidade.
  String? _validateTerm(String? text) {
    final value = int.tryParse(text ?? '');
    if (value == null || value < 0) {
      return 'Informe o prazo';
    }
    if (_simulator.monthsFor(value, _termUnit) > _maxMonths) {
      return 'Prazo máximo de $_maxMonths meses (50 anos)';
    }
    return null;
  }

  void _simulate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final rate = _simulator.monthlyRate(
      MoneyFormat.parseRate(_rateController.text)!,
      _ratePeriod,
    );
    final months = _simulator.monthsFor(
      int.parse(_termController.text),
      _termUnit,
    );

    setState(() {
      _points = _simulator.simulate(
        initial: MoneyFormat.parse(_initialController.text)!,
        monthlyDeposit: MoneyFormat.parse(_depositController.text)!,
        monthlyRate: rate,
        months: months,
      );
    });

    // Tira o teclado da frente do resultado
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final points = _points;

    return Scaffold(
      appBar: AppBar(title: const Text('Simulador de Juros')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LabeledMoneyField(
                  label: 'Valor Inicial',
                  icon: Icons.account_balance_wallet_outlined,
                  controller: _initialController,
                  validator: _validateAmount,
                ),
                const SizedBox(height: 20),
                LabeledMoneyField(
                  label: 'Aporte Mensal',
                  icon: Icons.savings_outlined,
                  controller: _depositController,
                  validator: _validateAmount,
                ),
                const SizedBox(height: 20),
                _RateField(
                  controller: _rateController,
                  validator: _validateRate,
                  period: _ratePeriod,
                  onPeriodChanged: (p) => setState(() => _ratePeriod = p),
                ),
                const SizedBox(height: 20),
                _TermField(
                  controller: _termController,
                  validator: _validateTerm,
                  unit: _termUnit,
                  onUnitChanged: (u) => setState(() => _termUnit = u),
                  onDone: _simulate,
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _simulate,
                  child: const Text('SIMULAR'),
                ),
                if (points != null) ...[
                  const SizedBox(height: 24),
                  _Summary(points: points),
                  // Com prazo zero só existe o mês 0, sem o que desenhar
                  if (points.length > 1) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: ProjectionChart(points: points),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _YearTable(points: points),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Campo da taxa com o seletor "taxa ao mês" / "taxa ao ano" e a regra de
/// conversão embaixo.
class _RateField extends StatelessWidget {
  const _RateField({
    required this.controller,
    required this.validator,
    required this.period,
    required this.onPeriodChanged,
  });

  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final RatePeriod period;
  final ValueChanged<RatePeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(icon: Icons.percent, label: 'Taxa de Juros'),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller,
                validator: validator,
                textInputAction: TextInputAction.next,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                style: const TextStyle(fontSize: 16, color: AppColors.textDark),
                decoration: InputDecoration(
                  suffixText: '% ${period.label}',
                  hintText: '0,00',
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<RatePeriod>(
                segments: [
                  for (final p in RatePeriod.values)
                    ButtonSegment(value: p, label: Text(p.label)),
                ],
                selected: {period},
                showSelectedIcon: false,
                onSelectionChanged: (s) => onPeriodChanged(s.first),
              ),
              const SizedBox(height: 6),
              const _HelpText(
                'Taxa ao ano é efetiva: vira taxa mensal por (1 + i)^(1/12) − 1',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Campo do prazo, só dígitos, com o seletor "meses" / "anos" embaixo.
class _TermField extends StatelessWidget {
  const _TermField({
    required this.controller,
    required this.validator,
    required this.unit,
    required this.onUnitChanged,
    required this.onDone,
  });

  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final TermUnit unit;
  final ValueChanged<TermUnit> onUnitChanged;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(icon: Icons.calendar_month_outlined, label: 'Prazo'),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller,
                validator: validator,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onDone(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 16, color: AppColors.textDark),
                decoration: InputDecoration(
                  // O sufixo segue a unidade escolhida
                  suffixText: unit.label,
                  hintText: unit == TermUnit.meses ? '12' : '1',
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<TermUnit>(
                segments: [
                  for (final u in TermUnit.values)
                    ButtonSegment(value: u, label: Text(u.label)),
                ],
                selected: {unit},
                showSelectedIcon: false,
                onSelectionChanged: (s) => onUnitChanged(s.first),
              ),
              const SizedBox(height: 6),
              _HelpText(
                unit == TermUnit.anos
                    ? 'Prazo em anos: 1 ano = 12 meses na simulação'
                    : 'Prazo em meses',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 26),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

/// Uma linha curta de ajuda abaixo de um campo.
class _HelpText extends StatelessWidget {
  const _HelpText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
    );
  }
}

/// Os três números do resultado: montante, investido e juros, e a convenção
/// do aporte.
class _Summary extends StatelessWidget {
  const _Summary({required this.points});

  final List<CompoundInterestPoint> points;

  @override
  Widget build(BuildContext context) {
    final last = points.last;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Montante final',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            Text(
              MoneyFormat.format(last.balance),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: 'Total investido',
                    value: MoneyFormat.format(last.invested),
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    label: 'Juros ganhos',
                    value: MoneyFormat.format(last.interest),
                    color: AppColors.good,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const _HelpText(
              'Aporte no fim de cada mês, depois dos juros do mês. '
              'Total investido = capital inicial + aportes.',
            ),
            const SizedBox(height: 4),
            const _HelpText(
              'Projeção matemática com os valores informados; não é garantia '
              'de rentabilidade futura.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    this.color = AppColors.textDark,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Tabela com uma linha por ano fechado e uma para o último mês, se sobrar.
class _YearTable extends StatelessWidget {
  const _YearTable({required this.points});

  final List<CompoundInterestPoint> points;

  /// Os meses 12, 24, 36... e o último, quando não é múltiplo de 12.
  List<CompoundInterestPoint> get _rows {
    final rows = <CompoundInterestPoint>[];
    for (final p in points) {
      if (p.month > 0 && (p.month % 12 == 0 || p == points.last)) {
        rows.add(p);
      }
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AppColors.textMuted,
    );
    const cellStyle = TextStyle(fontSize: 13, color: AppColors.textDark);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
          },
          children: [
            const TableRow(
              children: [
                Text('Mês', style: headerStyle),
                Text('Investido', style: headerStyle, textAlign: TextAlign.end),
                Text('Saldo', style: headerStyle, textAlign: TextAlign.end),
              ],
            ),
            for (final p in _rows)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('${p.month}', style: cellStyle),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      MoneyFormat.formatNoCents(p.invested),
                      style: cellStyle,
                      textAlign: TextAlign.end,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      MoneyFormat.formatNoCents(p.balance),
                      style: cellStyle,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
