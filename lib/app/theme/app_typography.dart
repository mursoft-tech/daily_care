import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

/// Tipografía de la plantilla: Fredoka para títulos, Nunito para UI y cuerpo.
abstract final class AppTypography {
  static const fredokaFamily = 'Fredoka';
  static const nunitoFamily = 'Nunito';

  static TextStyle fredoka({
    double size = 16,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.textStrong,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fredokaFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle nunito({
    double size = 14.5,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textBody,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: nunitoFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextTheme textTheme() {
    return TextTheme(
      displaySmall: fredoka(size: 30, height: 1.15),
      headlineSmall: fredoka(size: 20),
      titleLarge: fredoka(size: 17),
      titleMedium: fredoka(size: 16.5),
      titleSmall: fredoka(size: 16),
      bodyLarge: nunito(size: 15.5, height: 1.55),
      bodyMedium: nunito(size: 14.5),
      bodySmall: nunito(size: 12.5, color: AppColors.textSoft),
      labelLarge: nunito(size: 14.5, weight: FontWeight.w800),
      labelMedium: nunito(
        size: 12.5,
        weight: FontWeight.w800,
        color: AppColors.sectionLabel,
        letterSpacing: 0.8,
      ),
      labelSmall: nunito(size: 12, weight: FontWeight.w800, letterSpacing: 0.5),
    );
  }
}
