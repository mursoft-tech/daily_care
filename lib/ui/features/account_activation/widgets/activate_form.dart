import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/use_cases/activate_account.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_link.dart';
import '../../../core/widgets/app_text_field.dart';
import '../view_models/activate_account_view_model.dart';
import 'activation_header.dart';
import 'consent_checkbox.dart';
import 'invitation_card.dart';

class ActivateForm extends ConsumerStatefulWidget {
  const ActivateForm({required this.code, super.key});

  final String code;

  @override
  ConsumerState<ActivateForm> createState() => _ActivateFormState();
}

class _ActivateFormState extends ConsumerState<ActivateForm> {
  late final TextEditingController _codeController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    final provider = activateAccountViewModelProvider(widget.code);
    final initial = ref.read(provider).requireValue;
    _codeController = TextEditingController(text: initial.code);
    _emailController = TextEditingController(text: initial.email);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final accepted = await ref
        .read(activateAccountViewModelProvider(widget.code).notifier)
        .submit();

    if (accepted && mounted) {
      context.go(AppRoutes.home);
    }
  }

  String? _codeError(AppLocalizations l10n, ActivationError? error) {
    return error == ActivationError.invalidCode
        ? l10n.activateInvalidCodeError
        : null;
  }

  String? _emailError(AppLocalizations l10n, ActivationError? error) {
    return switch (error) {
      ActivationError.invalidEmail => l10n.loginInvalidEmailError,
      ActivationError.emailMismatch => l10n.activateEmailMismatchError,
      _ => null,
    };
  }

  String? _passwordError(AppLocalizations l10n, ActivationError? error) {
    return switch (error) {
      ActivationError.emptyPassword => l10n.loginEmptyPasswordError,
      ActivationError.weakPassword => l10n.activateWeakPasswordError,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(activateAccountViewModelProvider(widget.code));
    final form = state.requireValue;
    final notifier = ref.read(
      activateAccountViewModelProvider(widget.code).notifier,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const ActivationHeader(),
        if (form.invitation != null) ...[
          InvitationCard(invitation: form.invitation!),
          const SizedBox(height: 22),
        ],
        AppTextField(
          label: l10n.activateCodeLabel,
          fieldKey: const Key('activate-code-input'),
          controller: _codeController,
          textStyle: AppTypography.fredoka(
            size: 18,
            weight: FontWeight.w700,
            letterSpacing: 3,
            color: AppColors.textStrong,
          ),
          onChanged: notifier.setCode,
          errorText: _codeError(l10n, form.errorType),
        ),
        const SizedBox(height: 18),
        AppTextField(
          label: l10n.loginEmailLabel,
          fieldKey: const Key('activate-email-input'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: notifier.setEmail,
          errorText: _emailError(l10n, form.errorType),
        ),
        const SizedBox(height: 18),
        AppTextField(
          label: l10n.activatePasswordLabel,
          fieldKey: const Key('activate-password-input'),
          controller: _passwordController,
          obscureText: true,
          onChanged: notifier.setPassword,
          errorText: _passwordError(l10n, form.errorType),
        ),
        const SizedBox(height: 18),
        ConsentCheckbox(
          key: const Key('activate-consent-checkbox'),
          value: form.photoConsent,
          onChanged: notifier.setPhotoConsent,
          errorText: form.errorType == ActivationError.consentRequired
              ? l10n.activateConsentRequiredError
              : null,
        ),
        const SizedBox(height: 24),
        _GradientButton(
          label: l10n.activateSubmitButton,
          onTap: _handleSubmit,
        ),
        if (form.submitFailed) ...[
          const SizedBox(height: 10),
          Text(
            l10n.activateGenericError,
            textAlign: TextAlign.center,
            style: AppTypography.nunito(
              size: 12.5,
              weight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        ],
        const SizedBox(height: 22),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${l10n.activateHaveAccountPrompt} ',
              style: AppTypography.nunito(
                size: 14.5,
                color: AppColors.textMuted,
              ),
            ),
            AppLink(
              key: const Key('activate-sign-in-link'),
              onTap: () => context.go(AppRoutes.login),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                  vertical: 2,
                ),
                child: Text(
                  l10n.activateSignInLink,
                  style: AppTypography.nunito(
                    size: 14.5,
                    weight: FontWeight.w800,
                    color: AppColors.link,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primarySoft, AppColors.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.7),
            blurRadius: 22,
            offset: const Offset(0, 10),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('activate-submit-button'),
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: Text(
                label,
                style: AppTypography.nunito(
                  size: 16,
                  weight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
