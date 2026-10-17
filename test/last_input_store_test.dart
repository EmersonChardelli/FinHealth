import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finhealth/models/financial_data.dart';
import 'package:finhealth/services/last_input_store.dart';

void main() {
  const store = LastInputStore();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('sem análise anterior devolve null', () async {
    expect(await store.load(), isNull);
  });

  test('guarda e lê os quatro valores', () async {
    await store.save(
      const FinancialData(
        monthlyIncome: 5000,
        monthlyExpenses: 3200.5,
        totalDebt: 8000,
        savings: 2000,
      ),
    );

    final data = await store.load();
    expect(data, isNotNull);
    expect(data!.monthlyIncome, 5000);
    expect(data.monthlyExpenses, 3200.5);
    expect(data.totalDebt, 8000);
    expect(data.savings, 2000);
  });

  test('a segunda gravação substitui a primeira', () async {
    await store.save(
      const FinancialData(
        monthlyIncome: 1000,
        monthlyExpenses: 100,
        totalDebt: 10,
        savings: 1,
      ),
    );
    await store.save(
      const FinancialData(
        monthlyIncome: 2000,
        monthlyExpenses: 200,
        totalDebt: 20,
        savings: 2,
      ),
    );

    final data = await store.load();
    expect(data!.monthlyIncome, 2000);
    expect(data.savings, 2);
  });

  test('clear apaga tudo', () async {
    await store.save(
      const FinancialData(
        monthlyIncome: 1000,
        monthlyExpenses: 100,
        totalDebt: 10,
        savings: 1,
      ),
    );
    await store.clear();
    expect(await store.load(), isNull);
  });
}
