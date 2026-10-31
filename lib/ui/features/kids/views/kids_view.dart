import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/models/child.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_shell.dart';
import '../view_models/kids_view_model.dart';
import '../widgets/child_card.dart';
import '../widgets/kids_header.dart';
import '../widgets/kids_search_field.dart';
import '../widgets/kids_section_header.dart';

class KidsView extends ConsumerWidget {
  const KidsView({super.key});

  static const _twoColumnBreakpoint = 700.0;
  static const _gridGap = 14.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kids = ref.watch(kidsViewModelProvider);
    final l10n = AppLocalizations.of(context);
    final state = kids.value;

    return AppShell(
      selectedIndex: 1,
      onLogout: () => context.go(AppRoutes.login),
      child: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth < 600 ? 20.0 : 40.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 880),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(horizontal, 34, horizontal, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      KidsHeader(
                        onAddChild: () => context.go(AppRoutes.newChild),
                      ),
                      const SizedBox(height: 22),
                      KidsSearchField(
                        query: state?.query ?? '',
                        onChanged: (query) => ref
                            .read(kidsViewModelProvider.notifier)
                            .search(query),
                      ),
                      const SizedBox(height: 22),
                      KidsSectionHeader(count: state?.all.length),
                      const SizedBox(height: 14),
                      switch (kids) {
                        AsyncData(:final value) => value.visible.isEmpty
                            ? const _EmptyResults()
                            : _KidsGrid(
                                children: value.visible,
                                ageYearsOf: value.ageOf,
                                onChildTap: (child) => context.go(
                                  AppRoutes.childProfilePath(child.id),
                                ),
                              ),
                        AsyncError() => _KidsError(
                          onRetry: () =>
                              ref.read(kidsViewModelProvider.notifier).retry(),
                        ),
                        _ => _KidsLoading(label: l10n.loadingKids),
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

class _KidsGrid extends StatelessWidget {
  const _KidsGrid({
    required this.children,
    required this.ageYearsOf,
    required this.onChildTap,
  });

  final List<Child> children;
  final int Function(Child child) ageYearsOf;
  final void Function(Child child) onChildTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns =
            constraints.maxWidth >= KidsView._twoColumnBreakpoint;
        final itemWidth = twoColumns
            ? (constraints.maxWidth - KidsView._gridGap) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: KidsView._gridGap,
          runSpacing: KidsView._gridGap,
          children: [
            for (final child in children)
              SizedBox(
                width: itemWidth,
                child: ChildCard(
                  child: child,
                  ageYears: ageYearsOf(child),
                  onTap: () => onChildTap(child),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        AppLocalizations.of(context).noKidsResults,
        textAlign: TextAlign.center,
        style: AppTypography.nunito(size: 15, color: AppColors.textMuted),
      ),
    );
  }
}

class _KidsLoading extends StatelessWidget {
  const _KidsLoading({required this.label});

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

class _KidsError extends StatelessWidget {
  const _KidsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Text(
            l10n.kidsError,
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
