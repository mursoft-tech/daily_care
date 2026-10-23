import 'package:material_ui/material_ui.dart';

import '../../../l10n/app_localizations.dart';

class AppLink extends StatelessWidget {
  const AppLink({
    required this.child,
    this.onTap,
    this.tooltip,
    this.borderRadius,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? tooltip;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final link = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Semantics(
        link: true,
        child: InkWell(
          onTap: onTap ?? () => _showComingSoon(context),
          borderRadius: borderRadius ?? BorderRadius.circular(10),
          child: child,
        ),
      ),
    );

    final message = tooltip;
    if (message == null) return link;
    return Tooltip(message: message, child: link);
  }

  void _showComingSoon(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).comingSoon)),
    );
  }
}
