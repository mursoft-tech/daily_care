import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/models/child.dart';
import '../../../../domain/models/post_type.dart';
import '../../../../domain/use_cases/create_post.dart';
import '../../../../domain/value_objects/post_draft.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_link.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/dashed_box.dart';
import '../../kids/view_models/kids_view_model.dart';
import '../../kids/widgets/child_avatar_palette.dart';
import '../view_models/create_post_view_model.dart';
import 'post_type_presentation.dart';

class CreatePostForm extends ConsumerStatefulWidget {
  const CreatePostForm({
    required this.isSaving,
    required this.errors,
    required this.onSubmit,
    required this.onCancel,
    super.key,
  });

  final bool isSaving;
  final List<PostDraftError> errors;
  final Future<void> Function(PostDraft draft) onSubmit;
  final VoidCallback onCancel;

  @override
  ConsumerState<CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends ConsumerState<CreatePostForm> {
  late final TextEditingController _bodyController;
  final Set<String> _selectedChildIds = <String>{};
  PostType _type = PostType.activity;

  @override
  void initState() {
    super.initState();
    _bodyController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(createPostViewModelProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  void _clearError() =>
      ref.read(createPostViewModelProvider.notifier).clearErrors();

  void _toggleChild(String childId) {
    setState(() {
      if (!_selectedChildIds.remove(childId)) {
        _selectedChildIds.add(childId);
      }
    });
    _clearError();
  }

  void _selectRoom() {
    setState(_selectedChildIds.clear);
    _clearError();
  }

  void _selectType(PostType type) {
    setState(() => _type = type);
    _clearError();
  }

  Future<void> _submit() async {
    if (widget.isSaving) return;

    await widget.onSubmit(
      PostDraft(
        childIds: _selectedChildIds.toList(growable: false),
        type: _type,
        body: _bodyController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<FeedColors>()!;
    final children =
        ref.watch(kidsViewModelProvider).value?.all ?? const <Child>[];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.loginBackground,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowStrong,
            blurRadius: 50,
            offset: Offset(0, 20),
            spreadRadius: -24,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ComposerHeader(
            isSaving: widget.isSaving,
            onCancel: widget.onCancel,
            onPublish: _submit,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 24, 26, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionLabel(l10n.composerFor),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    _RecipientChip(
                      label: l10n.composerRoomAudience,
                      selected: _selectedChildIds.isEmpty,
                      onTap: _selectRoom,
                      chipKey: const Key('composer-recipient-room'),
                    ),
                    for (final child in children)
                      _RecipientChip(
                        label: child.firstName,
                        initial: child.initial,
                        colorToken: child.colorToken,
                        selected: _selectedChildIds.contains(child.id),
                        onTap: () => _toggleChild(child.id),
                        chipKey: Key('composer-recipient-${child.id}'),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                _SectionLabel(l10n.composerType),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    for (final type in PostType.values)
                      _TypeChip(
                        type: type,
                        presentation: postTypePresentation(colors, l10n, type),
                        selected: _type == type,
                        onTap: () => _selectType(type),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                AppTextField(
                  label: l10n.composerDescription,
                  fieldKey: const Key('composer-description'),
                  controller: _bodyController,
                  hintText: l10n.composerDescriptionHint,
                  maxLines: 5,
                  onChanged: (_) => _clearError(),
                  errorText: widget.errors.contains(PostDraftError.bodyRequired)
                      ? l10n.composerBodyRequired
                      : null,
                ),
                if (widget.errors.contains(PostDraftError.saveFailed)) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.composerSaveError,
                    textAlign: TextAlign.center,
                    style: AppTypography.nunito(
                      size: 12.5,
                      weight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                _SectionLabel(l10n.composerPhotos),
                const Row(
                  children: [
                    _PhotoPlaceholder(),
                    SizedBox(width: 12),
                    _AddPhotoTile(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposerHeader extends StatelessWidget {
  const _ComposerHeader({
    required this.isSaving,
    required this.onCancel,
    required this.onPublish,
  });

  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          AppLink(
            key: const Key('composer-cancel'),
            onTap: onCancel,
            borderRadius: BorderRadius.circular(8),
            child: Text(
              l10n.composerCancel,
              style: AppTypography.nunito(
                size: 15,
                weight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                l10n.newPost,
                textAlign: TextAlign.center,
                style: AppTypography.fredoka(size: 18),
              ),
            ),
          ),
          if (isSaving)
            Semantics(
              label: l10n.composerSaving,
              child: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryDark,
                ),
              ),
            )
          else
            AppLink(
              key: const Key('composer-publish'),
              onTap: onPublish,
              borderRadius: BorderRadius.circular(8),
              child: Text(
                l10n.composerPublish,
                style: AppTypography.nunito(
                  size: 15,
                  weight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: AppTypography.nunito(
          size: 12,
          weight: FontWeight.w800,
          letterSpacing: 0.7,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _RecipientChip extends StatelessWidget {
  const _RecipientChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.chipKey,
    this.initial,
    this.colorToken,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Key chipKey;
  final String? initial;
  final String? colorToken;

  @override
  Widget build(BuildContext context) {
    final palette = childAvatarPalette(colorToken ?? 'coral');
    final foreground = selected ? AppColors.white : AppColors.navInactive;

    return AppLink(
      key: chipKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          initial == null ? 16 : 6,
          6,
          initial == null ? 16 : 14,
          6,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.textStrong : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.textStrong : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (initial != null) ...[
              AppAvatar(
                label: initial!,
                backgroundColor: palette.background,
                foregroundColor: palette.foreground,
                size: 26,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTypography.nunito(
                size: 14,
                weight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.type,
    required this.presentation,
    required this.selected,
    required this.onTap,
  });

  final PostType type;
  final PostTypePresentation presentation;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppLink(
      key: Key('composer-type-${type.name}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: presentation.background,
          border: selected
              ? Border.all(color: AppColors.textStrong, width: 2)
              : null,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              presentation.label,
              style: AppTypography.nunito(
                size: 13.5,
                weight: FontWeight.w800,
                color: presentation.foreground,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              Icon(Icons.check, size: 15, color: presentation.foreground),
            ],
          ],
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.photoBackground,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: AppIcon(
          asset: 'assets/icons/image.svg',
          size: 26,
          color: AppColors.photoIcon,
        ),
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppLink(
      key: const Key('composer-add-photo'),
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 96,
        height: 96,
        child: DashedBox(
          height: 96,
          radius: 14,
          backgroundColor: AppColors.photoBackground,
          borderColor: AppColors.photoBorder,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppIcon(
                asset: 'assets/icons/plus.svg',
                size: 22,
                color: AppColors.link,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.composerAddPhoto,
                style: AppTypography.nunito(
                  size: 12,
                  color: AppColors.photoIcon,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
