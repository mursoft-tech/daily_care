import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_models/login_view_model.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    final initialEmail = ref.read(loginViewModelProvider).email;
    _emailController = TextEditingController(text: initialEmail);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRoleSelected(LoginRole role) {
    ref.read(loginViewModelProvider.notifier).selectRole(role);
    final updatedEmail = ref.read(loginViewModelProvider).email;
    _emailController.text = updatedEmail;
  }

  void _handleLogin() {
    final notifier = ref.read(loginViewModelProvider.notifier);
    notifier.setEmail(_emailController.text);
    notifier.setPassword(_passwordController.text);

    final success = notifier.submit();
    if (success && mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginViewModelProvider);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 392),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.loginTitle,
                style: AppTypography.fredoka(
                  size: 30,
                  color: AppColors.textStrong,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.loginSubtitle,
                style: AppTypography.nunito(
                  size: 15,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                l10n.loginRoleEyebrow,
                style: AppTypography.nunito(
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: _RoleButton(
                      label: l10n.loginRoleStaff,
                      icon: Icons.person_outline,
                      isSelected: state.role == LoginRole.staff,
                      onTap: () => _handleRoleSelected(LoginRole.staff),
                      key: const Key('login-role-staff'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _RoleButton(
                      label: l10n.loginRoleParent,
                      icon: Icons.people_outline,
                      isSelected: state.role == LoginRole.family,
                      onTap: () => _handleRoleSelected(LoginRole.family),
                      key: const Key('login-role-parent'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                l10n.loginEmailLabel,
                style: AppTypography.nunito(
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('login-email-input'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTypography.nunito(
                  size: 15,
                  color: AppColors.textStrong,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.loginBorder, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.loginBorder, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              if (state.errorType == LoginErrorType.invalidEmail) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.loginInvalidEmailError,
                  style: AppTypography.nunito(
                    size: 12.5,
                    weight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Text(
                l10n.loginPasswordLabel,
                style: AppTypography.nunito(
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('login-password-input'),
                controller: _passwordController,
                obscureText: true,
                style: AppTypography.nunito(
                  size: 15,
                  color: AppColors.textStrong,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.white,
                  hintText: l10n.loginPasswordPlaceholder,
                  hintStyle: AppTypography.nunito(
                    size: 15,
                    color: AppColors.textSoft,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.loginBorder, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.loginBorder, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              if (state.errorType == LoginErrorType.emptyPassword) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.loginEmptyPasswordError,
                  style: AppTypography.nunito(
                    size: 12.5,
                    weight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ] else if (state.errorType == LoginErrorType.invalidCredentials) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.loginInvalidCredentialsError,
                  style: AppTypography.nunito(
                    size: 12.5,
                    weight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    key: const Key('login-forgot-password-link'),
                    onTap: () {},
                    child: Text(
                      l10n.loginForgotPassword,
                      style: AppTypography.nunito(
                        size: 13.5,
                        weight: FontWeight.w700,
                        color: AppColors.link,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primarySoft,
                      AppColors.primary,
                    ],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.primaryShadow,
                      blurRadius: 22,
                      offset: Offset(0, 10),
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: const Key('login-submit-button'),
                    borderRadius: BorderRadius.circular(15),
                    onTap: _handleLogin,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Center(
                        child: Text(
                          l10n.loginSubmitButton,
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
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${l10n.loginInvitationPrompt} ',
                    style: AppTypography.nunito(
                      size: 14.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      key: const Key('login-activate-account-link'),
                      onTap: () {},
                      child: Text(
                        l10n.loginActivateAccount,
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
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final background = isSelected ? AppColors.navActiveBackground : AppColors.white;
    final borderColor = isSelected ? AppColors.avatarCoral : AppColors.loginBorder;
    final foreground = isSelected ? AppColors.primaryDark : AppColors.navInactive;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.nunito(
                  size: 14,
                  weight: FontWeight.w700,
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
