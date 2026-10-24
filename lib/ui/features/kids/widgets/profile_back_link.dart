import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_link.dart';

class ProfileBackLink extends StatelessWidget {
  const ProfileBackLink({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: AppLink(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppIcon(
                asset: 'assets/icons/chevron-left.svg',
                size: 18,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 7),
              Text(
                AppLocalizations.of(context).backToKids,
                style: AppTypography.nunito(
                  size: 14,
                  weight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
