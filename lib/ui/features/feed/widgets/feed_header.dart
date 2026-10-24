import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';

class FeedHeader extends StatelessWidget {
  const FeedHeader({
    required this.name,
    required this.childCount,
    required this.date,
    super.key,
  });

  final String name;
  final int childCount;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formattedDate = DateFormat(
      'EEEE d MMM',
      Localizations.localeOf(context).toLanguageTag(),
    ).format(date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.eyebrow,
            style: AppTypography.nunito(
              size: 12.5,
              weight: FontWeight.w800,
              color: AppColors.primaryDark,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(l10n.greeting(name), style: AppTypography.fredoka(size: 30)),
          const SizedBox(height: 5),
          Text(
            l10n.summary(childCount, formattedDate),
            style: AppTypography.nunito(size: 14.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
