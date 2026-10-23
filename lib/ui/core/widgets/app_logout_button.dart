import 'package:material_ui/material_ui.dart';

import '../../../app/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'app_icon.dart';

/// Acción de cierre de sesión con área táctil de 48 dp.
class AppLogoutButton extends StatelessWidget {
  const AppLogoutButton({
    required this.onLogout,
    this.hitSize = 48,
    this.visualSize = 32,
    this.iconSize = 16,
    this.child,
    super.key,
  });

  final VoidCallback onLogout;
  final double hitSize;
  final double visualSize;
  final double iconSize;

  /// Reemplaza el cuadrado por defecto (por ejemplo, un avatar).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Semantics(
      button: true,
      label: l10n.logoutLabel,
      onTap: onLogout,
      excludeSemantics: true,
      child: InkWell(
        onTap: onLogout,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: hitSize,
          height: hitSize,
          child: Center(
            child: child ?? _LogoutVisual(size: visualSize, iconSize: iconSize),
          ),
        ),
      ),
    );
  }
}

class _LogoutVisual extends StatelessWidget {
  const _LogoutVisual({required this.size, required this.iconSize});

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: AppIcon(
        asset: 'assets/icons/logout.svg',
        size: iconSize,
        color: AppColors.textMuted,
      ),
    );
  }
}
