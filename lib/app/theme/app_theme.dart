import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_typography.dart';

@immutable
class FeedColors extends ThemeExtension<FeedColors> {
  const FeedColors({
    required this.achievementBackground,
    required this.achievementForeground,
    required this.activityBackground,
    required this.activityForeground,
    required this.announcementBackground,
    required this.announcementForeground,
  });

  static const standard = FeedColors(
    achievementBackground: AppColors.achievementBackground,
    achievementForeground: AppColors.achievementForeground,
    activityBackground: AppColors.activityBackground,
    activityForeground: AppColors.activityForeground,
    announcementBackground: AppColors.announcementBackground,
    announcementForeground: AppColors.announcementForeground,
  );

  final Color achievementBackground;
  final Color achievementForeground;
  final Color activityBackground;
  final Color activityForeground;
  final Color announcementBackground;
  final Color announcementForeground;

  @override
  FeedColors copyWith({
    Color? achievementBackground,
    Color? achievementForeground,
    Color? activityBackground,
    Color? activityForeground,
    Color? announcementBackground,
    Color? announcementForeground,
  }) {
    return FeedColors(
      achievementBackground:
          achievementBackground ?? this.achievementBackground,
      achievementForeground:
          achievementForeground ?? this.achievementForeground,
      activityBackground: activityBackground ?? this.activityBackground,
      activityForeground: activityForeground ?? this.activityForeground,
      announcementBackground:
          announcementBackground ?? this.announcementBackground,
      announcementForeground:
          announcementForeground ?? this.announcementForeground,
    );
  }

  @override
  FeedColors lerp(ThemeExtension<FeedColors>? other, double t) {
    if (other is! FeedColors) return this;
    return FeedColors(
      achievementBackground: Color.lerp(
        achievementBackground,
        other.achievementBackground,
        t,
      )!,
      achievementForeground: Color.lerp(
        achievementForeground,
        other.achievementForeground,
        t,
      )!,
      activityBackground: Color.lerp(
        activityBackground,
        other.activityBackground,
        t,
      )!,
      activityForeground: Color.lerp(
        activityForeground,
        other.activityForeground,
        t,
      )!,
      announcementBackground: Color.lerp(
        announcementBackground,
        other.announcementBackground,
        t,
      )!,
      announcementForeground: Color.lerp(
        announcementForeground,
        other.announcementForeground,
        t,
      )!,
    );
  }
}

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textStrong,
    error: AppColors.primaryDark,
    onError: AppColors.white,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: AppTypography.textTheme(),
    dividerTheme: const DividerThemeData(
      color: AppColors.sectionDivider,
      thickness: 1,
    ),
    extensions: const <ThemeExtension<dynamic>>[FeedColors.standard],
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: const WidgetStatePropertyAll(AppColors.scrollThumb),
      thickness: const WidgetStatePropertyAll(8),
      radius: const Radius.circular(8),
      crossAxisMargin: 2,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textStrong,
      contentTextStyle: AppTypography.nunito(size: 14, color: AppColors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
