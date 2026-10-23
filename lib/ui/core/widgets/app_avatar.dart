import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme/app_typography.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.size = 44,
    this.iconAsset,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final double size;
  final String? iconAsset;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final content = iconAsset == null
        ? Text(
            label,
            style: AppTypography.fredoka(
              size: size * 0.39,
              color: foregroundColor,
            ),
          )
        : SvgPicture.asset(
            iconAsset!,
            width: size * 0.45,
            height: size * 0.45,
            colorFilter: ColorFilter.mode(foregroundColor, BlendMode.srcIn),
          );

    return Semantics(
      label: semanticLabel,
      image: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: content,
      ),
    );
  }
}
