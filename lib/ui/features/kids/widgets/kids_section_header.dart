import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';

class KidsSectionHeader extends StatelessWidget {
  const KidsSectionHeader({this.count, super.key});

  final int? count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = count;

    return Row(
      children: [
        Text(
          l10n.kidsRoomLabel,
          style: AppTypography.nunito(
            size: 12.5,
            weight: FontWeight.w800,
            color: AppColors.textStrong,
            letterSpacing: 0.8,
          ),
        ),
        if (total != null) ...[
          const SizedBox(width: 12),
          Text(
            l10n.kidsCount(total),
            style: AppTypography.nunito(
              size: 13,
              color: AppColors.textSoft,
            ),
          ),
        ],
        const SizedBox(width: 12),
        const Expanded(
          child: SizedBox(
            height: 1,
            child: ColoredBox(color: AppColors.sectionDivider),
          ),
        ),
      ],
    );
  }
}
