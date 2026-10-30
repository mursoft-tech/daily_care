import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';

class ConsentCheckbox extends StatelessWidget {
  const ConsentCheckbox({
    required this.value,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          key: const Key('consent-semantics'),
          checked: value,
          child: InkWell(
            onTap: () => onChanged(!value),
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.consentBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: value
                            ? AppColors.consentCheckBackground
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: value
                              ? AppColors.consentCheckBackground
                              : AppColors.guardianDashedBorder,
                          width: 1.5,
                        ),
                      ),
                      child: value
                          ? const Icon(
                              Icons.check,
                              size: 15,
                              color: AppColors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.activatePhotoConsent,
                        style: AppTypography.nunito(
                          size: 14,
                          height: 1.45,
                          color: AppColors.consentForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: AppTypography.nunito(
              size: 12.5,
              weight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ],
    );
  }
}
