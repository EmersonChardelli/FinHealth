import 'package:flutter/material.dart';

/// Cores e estilos do FinHealth, definidos para o aplicativo.
class AppColors {
  AppColors._();

  /// Azul escuro da barra superior e do botão principal.
  static const Color primary = Color(0xFF1B4F9C);

  /// Azul mais escuro, usado nos títulos e nos rótulos dos campos.
  static const Color textDark = Color(0xFF1F3B6E);

  /// Cinza dos textos secundários.
  static const Color textMuted = Color(0xFF6B7A90);

  /// Azul muito claro do fundo das telas.
  static const Color background = Color(0xFFEDF2F9);

  /// Branco dos cartões.
  static const Color card = Colors.white;

  /// Cinza claro das bordas dos campos e das barras vazias.
  static const Color border = Color(0xFFD6DEEA);

  /// Verde da faixa boa.
  static const Color good = Color(0xFF4CAF50);

  /// Laranja da faixa de atenção.
  static const Color warning = Color(0xFFF2A93B);

  /// Vermelho da faixa crítica.
  static const Color critical = Color(0xFFE0514A);

  /// As três cores de referência da cor contínua do score. Tons fechados o
  /// bastante para o número ficar legível sobre o cartão branco.
  static const Color scoreRed = Color(0xFFD93B2E);
  static const Color scoreYellow = Color(0xFFE0A800);
  static const Color scoreGreen = Color(0xFF2E9E4F);
}

/// Tema do aplicativo. Monta o [ThemeData] a partir dessas cores.
class AppTheme {
  AppTheme._();

  static const double _radius = 12;

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: _fieldBorder(AppColors.border),
        enabledBorder: _fieldBorder(AppColors.border),
        focusedBorder: _fieldBorder(AppColors.primary),
        errorBorder: _fieldBorder(AppColors.critical),
        focusedErrorBorder: _fieldBorder(AppColors.critical),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color),
    );
  }
}
