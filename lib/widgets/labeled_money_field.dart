import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/money_input_formatter.dart';

/// Um campo de valor em reais com ícone e rótulo em cima.
/// O valor é formatado em reais enquanto o usuário digita.
class LabeledMoneyField extends StatelessWidget {
  const LabeledMoneyField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.validator,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 36),
          child: TextFormField(
            controller: controller,
            validator: validator,
            textInputAction: textInputAction,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            // Escreve "1.234,56" a cada tecla
            inputFormatters: const [MoneyInputFormatter()],
            style: const TextStyle(fontSize: 16, color: AppColors.textDark),
            decoration: const InputDecoration(
              prefixText: 'R\$ ',
              hintText: '0,00',
            ),
          ),
        ),
      ],
    );
  }
}
