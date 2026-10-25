import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_logo_mark.dart';

class LoginHeroPanel extends StatelessWidget {
  final bool isMobileBanner;

  const LoginHeroPanel({
    this.isMobileBanner = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (isMobileBanner) {
      return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.6, -1.0),
            end: Alignment(0.6, 1.0),
            colors: [
              AppColors.loginHeroGradientStart,
              AppColors.loginHeroGradientMiddle,
              AppColors.loginHeroGradientEnd,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.loginHeroCircleLight,
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AppLogoMark(size: 38),
                        const SizedBox(width: 10),
                        Text(
                          l10n.brandName,
                          style: AppTypography.fredoka(
                            size: 19,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.loginHeroClaim,
                      style: AppTypography.fredoka(
                        size: 22,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.loginHeroFooter,
                      style: AppTypography.nunito(
                        size: 12,
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.6, -1.0),
          end: Alignment(0.6, 1.0),
          colors: [
            AppColors.loginHeroGradientStart,
            AppColors.loginHeroGradientMiddle,
            AppColors.loginHeroGradientEnd,
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          // Círculo decorativo superior derecho
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 520,
              height: 520,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.loginHeroCircleLight,
              ),
            ),
          ),
          // Círculo decorativo inferior izquierdo
          Positioned(
            bottom: -120,
            left: -90,
            child: Container(
              width: 380,
              height: 380,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.loginHeroCircleSofter,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const AppLogoMark(size: 44),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  l10n.brandName,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.fredoka(
                                    size: 22,
                                    weight: FontWeight.w600,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.loginHeroClaim,
                                style: AppTypography.fredoka(
                                  size: 38,
                                  weight: FontWeight.w600,
                                  height: 1.15,
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(height: 18),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 450),
                                child: Text(
                                  l10n.loginHeroDescription,
                                  style: AppTypography.nunito(
                                    size: 16.5,
                                    height: 1.6,
                                    color: AppColors.white.withValues(alpha: 0.92),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            l10n.loginHeroFooter,
                            style: AppTypography.nunito(
                              size: 14,
                              color: AppColors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
