import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../domain/models/post_type.dart';
import '../../../../l10n/app_localizations.dart';

typedef PostTypePresentation = ({
  Color background,
  Color foreground,
  String label,
});

PostTypePresentation postTypePresentation(
  FeedColors colors,
  AppLocalizations l10n,
  PostType type,
) {
  return switch (type) {
    PostType.food => (
      background: colors.foodBackground,
      foreground: colors.foodForeground,
      label: l10n.typeFood,
    ),
    PostType.nap => (
      background: colors.napBackground,
      foreground: colors.napForeground,
      label: l10n.typeNap,
    ),
    PostType.activity => (
      background: colors.activityBackground,
      foreground: colors.activityForeground,
      label: l10n.typeActivity,
    ),
    PostType.achievement => (
      background: colors.achievementBackground,
      foreground: colors.achievementForeground,
      label: l10n.typeAchievement,
    ),
    PostType.mood => (
      background: colors.moodBackground,
      foreground: colors.moodForeground,
      label: l10n.typeMood,
    ),
    PostType.photo => (
      background: colors.photoTypeBackground,
      foreground: colors.photoTypeForeground,
      label: l10n.typePhoto,
    ),
    PostType.announcement => (
      background: colors.announcementBackground,
      foreground: colors.announcementForeground,
      label: l10n.typeAnnouncement,
    ),
  };
}
