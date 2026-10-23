import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_logo_mark.dart';

/// Pantalla temporal: la autenticación real se implementa en una etapa posterior.
class LoginPlaceholderView extends StatelessWidget {
  const LoginPlaceholderView({super.key});

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
                  const SizedBox(height: 16),
                  Text(l10n.brandName, style: AppTypography.fredoka(size: 24)),
                  const SizedBox(height: 4),
                  Text(
                    l10n.salaName,
                    style: AppTypography.nunito(
                      size: 13,
                      color: AppColors.textSoft,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 16,
                          offset: Offset(0, 4),
                          spreadRadius: -12,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.loginComingSoonTitle,
                          textAlign: TextAlign.center,
                          style: AppTypography.fredoka(size: 19),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.loginComingSoonBody,
                          textAlign: TextAlign.center,
                          style: AppTypography.nunito(
                            size: 15,
                            height: 1.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    key: const Key('login-back'),
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
