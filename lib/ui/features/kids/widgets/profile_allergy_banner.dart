import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/value_objects/allergy.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_icon.dart';

class ProfileAllergyBanner extends StatelessWidget {
  const ProfileAllergyBanner({required this.allergy, super.key});

  final Allergy allergy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.allergyBannerBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.allergyBannerIconBackground,
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: const AppIcon(
              asset: 'assets/icons/alert-triangle.svg',
              size: 22,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        l10n.childProfileAllergyTitle,
                        style: AppTypography.nunito(
                          size: 15,
                          weight: FontWeight.w800,
                          color: AppColors.allergyBannerTitle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _AllergyChip(label: allergy.label),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  allergy.notes,
                  style: AppTypography.nunito(
                    size: 14.5,
                    height: 1.5,
                    color: AppColors.allergyBannerBody,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllergyChip extends StatelessWidget {
  const _AllergyChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.allergyBannerIconBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.nunito(
          size: 10.5,
          weight: FontWeight.w800,
          color: AppColors.white,
        ),
      ),
    );
  }
}
