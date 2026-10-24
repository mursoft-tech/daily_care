import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';

typedef AvatarPalette = ({Color background, Color foreground});

AvatarPalette childAvatarPalette(String token) {
  return switch (token) {
    'blue' => (
      background: AppColors.avatarBlueBackground,
      foreground: AppColors.avatarBlueForeground,
    ),
    'pink' => (
      background: AppColors.avatarPinkBackground,
      foreground: AppColors.avatarPinkForeground,
    ),
    'green' => (
      background: AppColors.avatarGreenBackground,
      foreground: AppColors.avatarGreenForeground,
    ),
    'yellow' => (
      background: AppColors.avatarYellowBackground,
      foreground: AppColors.avatarYellowForeground,
    ),
    'purple' => (
      background: AppColors.avatarPurpleBackground,
      foreground: AppColors.avatarPurpleForeground,
    ),
    _ => (background: AppColors.avatarCoral, foreground: AppColors.white),
  };
}

AvatarPalette guardianAvatarPalette(String token) {
  final background = switch (token) {
    'blue' => AppColors.guardianBlueBackground,
    'pink' => AppColors.avatarPinkBackground,
    'green' => AppColors.avatarGreenBackground,
    'yellow' => AppColors.avatarYellowBackground,
    'purple' => AppColors.avatarPurpleBackground,
    _ => AppColors.avatarCoral,
  };
  return (background: background, foreground: AppColors.white);
}
