import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/models/guardian.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/dashed_box.dart';
import '../view_models/child_profile_view_model.dart';
import '../view_models/link_parent_view_model.dart';

class LinkParentView extends ConsumerStatefulWidget {
  const LinkParentView({required this.childId, super.key});

  final String childId;

  @override
  ConsumerState<LinkParentView> createState() => _LinkParentViewState();
}

class _LinkParentViewState extends ConsumerState<LinkParentView> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(AppLocalizations l10n) async {
    final notifier = ref.read(linkParentViewModelProvider(widget.childId).notifier);
    final success = await notifier.submit();
    if (success && mounted) {
      ref.invalidate(childProfileViewModelProvider(widget.childId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.linkParentSuccess(_nameController.text.trim()),
          ),
        ),
      );
      context.go(AppRoutes.childProfilePath(widget.childId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(linkParentViewModelProvider(widget.childId));

    return Scaffold(
      backgroundColor: AppColors.loginBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth < 600 ? 20.0 : 40.0;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontal,
                        vertical: 36,
                      ),
                      child: switch (state) {
                        AsyncData(:final value) => _buildCard(context, l10n, value),
                        AsyncError() => _buildError(context, l10n),
                        _ => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(),
                            ),
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

  Widget _buildError(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.childProfileNotFound,
            style: AppTypography.fredoka(
              size: 20,
              weight: FontWeight.w600,
              color: AppColors.textStrong,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.kids),
            child: Text(l10n.backToKids),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    AppLocalizations l10n,
    LinkParentFormState form,
  ) {
    final notifier = ref.read(linkParentViewModelProvider(widget.childId).notifier);

    String? nameErrorText;
    if (form.nameError == 'required') {
      nameErrorText = l10n.linkParentNameRequired;
    }

    String? emailErrorText;
    if (form.emailError == 'required') {
      emailErrorText = l10n.linkParentEmailRequired;
    } else if (form.emailError == 'invalid') {
      emailErrorText = l10n.linkParentEmailInvalid;
    } else if (form.emailError == 'alreadyLinked') {
      emailErrorText = l10n.linkParentEmailAlreadyLinked;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBF4EC),
        border: Border.all(color: const Color(0xFFECE0D0)),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(63, 54, 46, 0.16),
            blurRadius: 36,
            offset: Offset(0, 16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFECE0D0)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.linkParentTitle,
                        style: AppTypography.fredoka(
                          size: 18,
                          weight: FontWeight.w600,
                          color: const Color(0xFF3F362E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.linkParentSubtitle(form.child.fullName),
                        style: AppTypography.nunito(
                          size: 13,
                          color: const Color(0xFFA89A8B),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  key: const Key('link-parent-close-button'),
                  onTap: () => context.go(AppRoutes.childProfilePath(widget.childId)),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0E6D8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const AppIcon(
                      asset: 'assets/icons/close.svg',
                      size: 16,
                      color: Color(0xFF94887B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3ECFB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 20, color: Color(0xFF4E72C8)),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          l10n.linkParentBanner(form.child.firstName),
                          style: AppTypography.nunito(
                            size: 13.5,
                            color: const Color(0xFF3F5694),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Name field
                AppTextField(
                  fieldKey: const Key('link-parent-name-input'),
                  label: l10n.linkParentNameLabel,
                  hintText: l10n.linkParentNamePlaceholder,
                  controller: _nameController,
                  errorText: nameErrorText,
                  onChanged: notifier.setName,
                ),
                const SizedBox(height: 18),

                // Email field
                AppTextField(
                  fieldKey: const Key('link-parent-email-input'),
                  label: l10n.linkParentEmailLabel,
                  hintText: l10n.linkParentEmailPlaceholder,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  errorText: emailErrorText,
                  onChanged: notifier.setEmail,
                ),
                const SizedBox(height: 18),

                // Relationship buttons
                Text(
                  l10n.linkParentRelationshipLabel,
                  style: AppTypography.nunito(
                    size: 12,
                    weight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: const Color(0xFF94887B),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _RelationshipButton(
                      label: l10n.linkParentRoleMother,
                      isSelected: form.relationship == GuardianRelationship.mother,
                      onTap: () => notifier.setRelationship(GuardianRelationship.mother),
                    ),
                    const SizedBox(width: 9),
                    _RelationshipButton(
                      label: l10n.linkParentRoleFather,
                      isSelected: form.relationship == GuardianRelationship.father,
                      onTap: () => notifier.setRelationship(GuardianRelationship.father),
                    ),
                    const SizedBox(width: 9),
                    _RelationshipButton(
                      label: l10n.linkParentRoleGuardian,
                      isSelected: form.relationship == GuardianRelationship.guardian,
                      onTap: () => notifier.setRelationship(GuardianRelationship.guardian),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Invitation Code Box
                DashedBox(
                  height: 125,
                  radius: 16,
                  backgroundColor: const Color(0xFFFBF1D6),
                  borderColor: const Color(0xFFE6D08A),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.linkParentCodeLabel,
                          style: AppTypography.nunito(
                            size: 12,
                            weight: FontWeight.w800,
                            letterSpacing: 0.7,
                            color: const Color(0xFFA88526),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          form.invitationCode,
                          key: const Key('link-parent-invitation-code'),
                          style: AppTypography.fredoka(
                            size: 32,
                            weight: FontWeight.w600,
                            letterSpacing: 7,
                            color: const Color(0xFF8A7234),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.linkParentCodeExpires,
                          style: AppTypography.nunito(
                            size: 12.5,
                            color: const Color(0xFFA88526),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit button
                InkWell(
                  key: const Key('link-parent-submit-button'),
                  onTap: form.isSubmitting ? null : () => _handleSubmit(l10n),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF4977E), Color(0xFFEE8164)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(238, 129, 100, 0.45),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                        const SizedBox(width: 9),
                        Text(
                          l10n.linkParentSubmit,
                          style: AppTypography.nunito(
                            size: 15.5,
                            weight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RelationshipButton extends StatelessWidget {
  const _RelationshipButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? const Color(0xFF9FB8EC) : const Color(0xFFECE0D0),
              width: 1.5,
            ),
            color: isSelected ? const Color(0xFFCCD8F4) : const Color(0xFFFFFDF9),
          ),
          child: Text(
            label,
            style: AppTypography.nunito(
              size: 14,
              weight: FontWeight.w800,
              color: isSelected ? const Color(0xFF4E72C8) : const Color(0xFF6E6359),
            ),
          ),
        ),
      ),
    );
  }
}
