import 'package:material_ui/material_ui.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

/// Campo de texto con la etiqueta y el borde de la plantilla.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.fieldKey,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
    this.textStyle,
    super.key,
  });

  final String label;
  final Key? fieldKey;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.nunito(
            size: 12,
            weight: FontWeight.w700,
            letterSpacing: 0.7,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          style: textStyle ??
              AppTypography.nunito(size: 15, color: AppColors.textStrong),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            hintText: hintText,
            hintStyle: AppTypography.nunito(
              size: 15,
              color: AppColors.textSoft,
            ),
            errorText: errorText,
            errorStyle: AppTypography.nunito(
              size: 12.5,
              weight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: _border(AppColors.loginBorder),
            enabledBorder: _border(AppColors.loginBorder),
            focusedBorder: _border(AppColors.primary),
            errorBorder: _border(AppColors.primaryDark),
            focusedErrorBorder: _border(AppColors.primaryDark),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }
}
