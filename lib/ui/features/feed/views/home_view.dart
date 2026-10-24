import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/providers.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_shell.dart';
import '../view_models/feed_view_model.dart';
import '../widgets/composer_bar.dart';
import '../widgets/feed_header.dart';
import '../widgets/feed_post_card.dart';
import '../widgets/feed_section_label.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  static final _demoDate = DateTime(2025, 6, 17);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedViewModelProvider);
    final sessionUser = ref.watch(sessionUserProvider);
    final l10n = AppLocalizations.of(context);

    return AppShell(
      onLogout: () => context.go(AppRoutes.login),
      child: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth < 600 ? 20.0 : 40.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(horizontal, 34, horizontal, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FeedHeader(
                        name: sessionUser.firstName,
                        childCount: 12,
                        date: _demoDate,
                      ),
                      ComposerBar(initial: sessionUser.initial),
                      const SizedBox(height: 24),
                      FeedSectionLabel(label: l10n.publishedToday),
                      switch (feed) {
                        AsyncData(:final value) => Column(
                          children: [
                            for (final post in value)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: FeedPostCard(post: post),
                              ),
                          ],
                        ),
                        AsyncError() => _FeedError(
                          onRetry: () =>
                              ref.read(feedViewModelProvider.notifier).retry(),
                        ),
                        _ => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Center(
                            child: Semantics(
                              label: l10n.loadingFeed,
                              child: const CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
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

class _FeedError extends StatelessWidget {
  const _FeedError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Text(
            l10n.feedError,
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
