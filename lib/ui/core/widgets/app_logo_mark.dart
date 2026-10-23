import 'package:material_ui/material_ui.dart';

import '../../../app/theme/app_colors.dart';
import 'app_icon.dart';

class AppLogoMark extends StatelessWidget {
  const AppLogoMark({this.size = 40, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.logoGradientStart, AppColors.logoGradientEnd],
        ),
      ),
      child: AppIcon(
        asset: 'assets/icons/logo_sun.svg',
        size: size * 0.55,
        color: AppColors.white,
      ),
    );
  }
}
