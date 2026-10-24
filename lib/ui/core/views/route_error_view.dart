import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/app_logo_mark.dart';

/// Destino genérico para rutas inexistentes o errores de navegación.
class RouteErrorView extends StatelessWidget {
  const RouteErrorView({super.key});

  static const path = '/error';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogoMark(size: 56),
                  const SizedBox(height: 20),
                  Text(
                    l10n.routeErrorTitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.fredoka(size: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.routeErrorBody,
                    textAlign: TextAlign.center,
                    style: AppTypography.nunito(
                      size: 15,
                      height: 1.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    key: const Key('route-error-back'),
                    onPressed: () => context.go('/'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      textStyle: AppTypography.nunito(
                        size: 14.5,
                        weight: FontWeight.w800,
                      ),
                    ),
                    child: Text(l10n.backToFeed),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
