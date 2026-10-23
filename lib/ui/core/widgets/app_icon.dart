import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({required this.asset, this.size = 19, this.color, super.key});

  final String asset;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
