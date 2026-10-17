import '../models/financial_indicators.dart';
import '../models/health_score.dart';

/// Todos os textos de orientação do app, num lugar só: a mensagem geral de
/// cada faixa do score e a recomendação de cada indicador em cada faixa. São orientação geral, não
/// aconselhamento financeiro individual.
class HealthMessages {
  HealthMessages._();

  /// Mensagem geral da faixa do score.
  static String general(HealthStatus status) {
    switch (status) {
      case HealthStatus.critico:
        return 'Os resultados indicam dificuldades em alguns aspectos importantes. '
            'Priorize o orçamento, a organização das dívidas e a formação gradual de reserva.';
      case HealthStatus.atencao:
        return 'Há pontos que merecem atenção. Revise as despesas, acompanhe as dívidas '
            'e priorize os indicadores com menor pontuação.';
      case HealthStatus.saudavel:
        return 'Os indicadores apresentam resultados favoráveis. Mantenha os bons hábitos '
            'e continue acompanhando os pontos que ainda podem melhorar.';
    }
  }

  /// Recomendação de um indicador na faixa em que ele caiu.
  static String recommendation(IndicatorKind kind, IndicatorLevel level) {
    switch (kind) {
      case IndicatorKind.incomeCommitment:
        return _incomeCommitment(level);
      case IndicatorKind.debtLevel:
        return _debtLevel(level);
      case IndicatorKind.monthlySavings:
        return _monthlySavings(level);
      case IndicatorKind.emergencyReserve:
        return _emergencyReserve(level);
    }
  }

  static String _incomeCommitment(IndicatorLevel level) {
    switch (level) {
      case IndicatorLevel.good:
        return 'Seu comprometimento de renda está em uma faixa favorável. Continue '
            'acompanhando suas despesas para manter o equilíbrio entre o que recebe e o que gasta.';
      case IndicatorLevel.warning:
        return 'Uma parte significativa da sua renda está comprometida com despesas. Revise '
            'seus gastos mensais e identifique oportunidades de economia para ampliar sua '
            'margem financeira.';
      case IndicatorLevel.critical:
        return 'Mais da metade da sua renda está comprometida com despesas. Analise seus '
            'gastos prioritários, reduza despesas não essenciais quando possível e organize '
            'um plano para recuperar sua margem financeira.';
    }
  }

  static String _debtLevel(IndicatorLevel level) {
    switch (level) {
      case IndicatorLevel.good:
        return 'Sua relação entre dívida total e renda anual estimada está em uma faixa '
            'favorável. Continue acompanhando seus compromissos e avalie novas dívidas com cuidado.';
      case IndicatorLevel.warning:
        return 'Seu nível de endividamento merece atenção. Organize as dívidas, confira '
            'juros e prazos e avalie quais compromissos têm maior custo.';
      case IndicatorLevel.critical:
        return 'Seu nível de endividamento está elevado em relação à renda anual estimada. '
            'Evite assumir novos compromissos sem avaliar sua capacidade de pagamento e '
            'elabore um plano para reduzir as dívidas.';
    }
  }

  static String _monthlySavings(IndicatorLevel level) {
    switch (level) {
      case IndicatorLevel.good:
        return 'Você está reservando uma parcela relevante da sua renda. Mantenha esse '
            'hábito e direcione os recursos de acordo com seus objetivos financeiros.';
      case IndicatorLevel.warning:
        return 'Você consegue poupar parte da renda, mas pode ampliar esse valor. Revise o '
            'orçamento e estabeleça uma meta mensal compatível com sua realidade.';
      case IndicatorLevel.critical:
        return 'Sua renda não está gerando uma sobra mensal positiva. Revise as despesas e '
            'procure ajustar o orçamento para que as receitas superem os gastos antes de '
            'estabelecer metas maiores de investimento.';
    }
  }

  static String _emergencyReserve(IndicatorLevel level) {
    switch (level) {
      case IndicatorLevel.good:
        return 'Sua reserva cobre pelo menos três meses de despesas mensais. Preserve '
            'esse recurso para imprevistos e avalie se o valor é adequado à estabilidade da '
            'sua renda.';
      case IndicatorLevel.warning:
        return 'Sua reserva de emergência ainda é limitada. Procure aumentá-la '
            'gradualmente até alcançar pelo menos três meses de despesas mensais.';
      case IndicatorLevel.critical:
        return 'Sua reserva cobre, no máximo, um mês de despesas mensais. Priorize a '
            'formação dessa reserva aos poucos, mantendo o dinheiro de imprevistos separado '
            'dos gastos cotidianos.';
    }
  }
}
