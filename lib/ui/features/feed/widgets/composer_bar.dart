import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_link.dart';

class ComposerBar extends StatelessWidget {
  const ComposerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppLink(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowStrong,
              blurRadius: 14,
              offset: Offset(0, 4),
              spreadRadius: -10,
            ),
          ],
        ),
        child: Row(
          children: [
            const AppAvatar(
              label: 'C',
              backgroundColor: AppColors.avatarCoral,
              foregroundColor: AppColors.white,
              size: 40,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                l10n.composerHint,
                style: AppTypography.nunito(
                  size: 15,
                  color: AppColors.textSoft,
                ),
              ),
            ),
            AppLink(
              tooltip: l10n.composerPhotoTooltip,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.navActiveBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const AppIcon(
                  asset: 'assets/icons/camera.svg',
                  size: 19,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
