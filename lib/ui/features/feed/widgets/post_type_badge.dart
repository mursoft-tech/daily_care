import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/models/post_type.dart';
import '../../../../l10n/app_localizations.dart';

class PostTypeBadge extends StatelessWidget {
  const PostTypeBadge({required this.type, super.key});

  final PostType type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<FeedColors>()!;

    final (background, foreground, label) = switch (type) {
      PostType.achievement => (
        colors.achievementBackground,
        colors.achievementForeground,
        l10n.typeAchievement,
      ),
      PostType.activity => (
        colors.activityBackground,
        colors.activityForeground,
        l10n.typeActivity,
      ),
      PostType.announcement => (
        colors.announcementBackground,
        colors.announcementForeground,
        l10n.typeAnnouncement,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: AppTypography.nunito(
              size: 12,
              weight: FontWeight.w800,
              color: foreground,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
