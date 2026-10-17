import 'package:flutter/material.dart';

import 'screens/input_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const FinHealthApp());
}

/// Raiz do aplicativo. Abre na tela de entrada de dados.
class FinHealthApp extends StatelessWidget {
  const FinHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinHealth',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const InputScreen(),
    );
  }
}
