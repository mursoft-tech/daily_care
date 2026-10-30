import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_models/activate_account_view_model.dart';
import '../widgets/activate_form.dart';

class ActivateAccountView extends ConsumerWidget {
  const ActivateAccountView({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = activateAccountViewModelProvider(code);
    final state = ref.watch(provider);

    return Scaffold(
      backgroundColor: AppColors.loginBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth < 600 ? 24.0 : 40.0;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontal,
                        vertical: 40,
                      ),
                      child: switch (state) {
                        AsyncData() => ActivateForm(code: code),
                        AsyncError() => _ActivationLoadError(
                          onRetry: () => ref.read(provider.notifier).retry(),
                        ),
                        _ => _ActivationLoading(
                          label: l10n.activateLoadingInvitation,
                        ),
                      },
                    ),
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

class _ActivationLoading extends StatelessWidget {
  const _ActivationLoading({required this.label});

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

class _ActivationLoadError extends StatelessWidget {
  const _ActivationLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.activateLoadError,
            textAlign: TextAlign.center,
            style: AppTypography.fredoka(size: 20),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            key: const Key('activate-retry-button'),
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
