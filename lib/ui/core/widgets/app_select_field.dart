import 'package:material_ui/material_ui.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

/// Select con la etiqueta y el borde de los campos del template.
class AppSelectField extends StatelessWidget {
  const AppSelectField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.fieldKey,
    this.errorText,
    super.key,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final Key? fieldKey;
  final String? errorText;

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
        DropdownButtonFormField<String>(
          key: fieldKey,
          initialValue: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSoft,
            size: 20,
          ),
          style: AppTypography.nunito(
            size: 15,
            weight: FontWeight.w800,
            color: AppColors.textStrong,
          ),
          dropdownColor: AppColors.white,
          items: [
            for (final item in items)
              DropdownMenuItem<String>(value: item, child: Text(item)),
          ],
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
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
