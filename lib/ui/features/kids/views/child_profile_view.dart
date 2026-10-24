import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_link.dart';
import '../../../core/widgets/app_shell.dart';
import '../view_models/child_profile_view_model.dart';
import '../widgets/linked_parents_card.dart';
import '../widgets/profile_allergy_banner.dart';
import '../widgets/profile_back_link.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';

class ChildProfileView extends ConsumerWidget {
  const ChildProfileView({required this.childId, super.key});

  static const _twoColumnBreakpoint = 640.0;
  static const _sideWidth = 300.0;
  static const _columnGap = 26.0;

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(childProfileViewModelProvider(childId));
    final l10n = AppLocalizations.of(context);

    void goBack() => context.go(AppRoutes.kids);

    return AppShell(
      selectedIndex: 1,
      onLogout: () => context.go(AppRoutes.login),
      child: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth < 600 ? 20.0 : 40.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(horizontal, 34, horizontal, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProfileBackLink(onTap: goBack),
                      const SizedBox(height: 20),
                      switch (profile) {
                        AsyncData(:final value) => value.notFound
                            ? _ProfileNotFound(onBack: goBack)
                            : _ProfileContent(state: value),
                        AsyncError() => _ProfileError(
                          onRetry: () => ref
                              .read(
                                childProfileViewModelProvider(
                                  childId,
                                ).notifier,
                              )
                              .retry(),
                        ),
                        _ => _ProfileLoading(label: l10n.childProfileLoading),
                      },
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.state});

  final ChildProfileState state;

  @override
  Widget build(BuildContext context) {
    final child = state.child!;
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileHeader(child: child, ageYears: state.ageYears!),
        if (child.allergy != null) ...[
          const SizedBox(height: 18),
          ProfileAllergyBanner(allergy: child.allergy!),
        ],
        const SizedBox(height: 18),
        ProfileInfoCard(child: child),
      ],
    );
    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _DaySummaryButton(),
        const SizedBox(height: 14),
        LinkedParentsCard(guardians: child.guardians),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ChildProfileView._twoColumnBreakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: ChildProfileView._columnGap),
              SizedBox(width: ChildProfileView._sideWidth, child: right),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [left, const SizedBox(height: 26), right],
        );
      },
    );
  }
}

class _DaySummaryButton extends StatelessWidget {
  const _DaySummaryButton();

  @override
  Widget build(BuildContext context) {
    return AppLink(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.textStrong,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppIcon(
              asset: 'assets/icons/logo_sun.svg',
              size: 18,
              color: AppColors.white,
            ),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                AppLocalizations.of(context).childProfileDaySummary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.nunito(
                  size: 15,
                  weight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileLoading extends StatelessWidget {
  const _ProfileLoading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Semantics(
          label: label,
          child: const CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Text(
            l10n.childProfileError,
            textAlign: TextAlign.center,
            style: AppTypography.nunito(size: 15, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              side: const BorderSide(color: AppColors.primaryDark),
            ),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

class _ProfileNotFound extends StatelessWidget {
  const _ProfileNotFound({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Text(
            l10n.childProfileNotFound,
            textAlign: TextAlign.center,
            style: AppTypography.fredoka(size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.childProfileNotFoundBody,
            textAlign: TextAlign.center,
            style: AppTypography.nunito(
              size: 14.5,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          AppLink(
            onTap: onBack,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.backToKids,
                style: AppTypography.nunito(
                  size: 14,
                  weight: FontWeight.w700,
                  color: AppColors.navInactive,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
