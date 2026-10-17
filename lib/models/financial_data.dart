/// Os quatro valores que o usuário informa, em reais.
class FinancialData {
  const FinancialData({
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.totalDebt,
    required this.savings,
  });

  /// Renda mensal.
  final double monthlyIncome;

  /// Gastos mensais.
  final double monthlyExpenses;

  /// Total de dívidas.
  final double totalDebt;

  /// Investimentos e poupança acumulados.
  final double savings;
}
