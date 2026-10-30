import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_logo_mark.dart';

class ActivationHeader extends StatelessWidget {
  const ActivationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.65),
                blurRadius: 26,
                offset: const Offset(0, 12),
                spreadRadius: -10,
              ),
            ],
          ),
          child: const AppLogoMark(size: 58),
        ),
        const SizedBox(height: 22),
        Text(
          l10n.activateAccountTitle,
          style: AppTypography.fredoka(
            size: 32,
            weight: FontWeight.w600,
            height: 1.15,
            color: AppColors.textStrong,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.activateAccountSubtitle,
          style: AppTypography.nunito(
            size: 15.5,
            height: 1.55,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 26),
      ],
    );
  }
}
