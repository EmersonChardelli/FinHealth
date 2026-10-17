import 'package:shared_preferences/shared_preferences.dart';

import '../models/financial_data.dart';

/// Guarda os quatro valores da última análise no aparelho, para os campos
/// já virem preenchidos na próxima abertura do app.
class LastInputStore {
  const LastInputStore();

  static const _incomeKey = 'last_income';
  static const _expensesKey = 'last_expenses';
  static const _debtKey = 'last_debt';
  static const _savingsKey = 'last_savings';

  Future<void> save(FinancialData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_incomeKey, data.monthlyIncome);
    await prefs.setDouble(_expensesKey, data.monthlyExpenses);
    await prefs.setDouble(_debtKey, data.totalDebt);
    await prefs.setDouble(_savingsKey, data.savings);
  }

  /// Devolve `null` quando nunca houve uma análise.
  Future<FinancialData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final income = prefs.getDouble(_incomeKey);
    if (income == null) {
      return null;
    }
    return FinancialData(
      monthlyIncome: income,
      monthlyExpenses: prefs.getDouble(_expensesKey) ?? 0,
      totalDebt: prefs.getDouble(_debtKey) ?? 0,
      savings: prefs.getDouble(_savingsKey) ?? 0,
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_incomeKey);
    await prefs.remove(_expensesKey);
    await prefs.remove(_debtKey);
    await prefs.remove(_savingsKey);
  }
}
