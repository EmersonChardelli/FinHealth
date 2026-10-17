/// Um mês da projeção de juros compostos.
class CompoundInterestPoint {
  const CompoundInterestPoint({
    required this.month,
    required this.invested,
    required this.balance,
  });

  /// Mês da projeção, de 0 (início) até o prazo.
  final int month;

  /// Soma do valor inicial com os aportes feitos até este mês.
  final double invested;

  /// Saldo com os juros até este mês.
  final double balance;

  /// Quanto dos juros já entrou até este mês.
  double get interest => balance - invested;
}
