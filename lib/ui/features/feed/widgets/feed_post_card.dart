import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/models/post.dart';
import '../../../../domain/models/post_audience.dart';
import '../../../../domain/models/post_type.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_link.dart';
import '../../../core/widgets/dashed_box.dart';
import 'post_type_badge.dart';

class FeedPostCard extends StatelessWidget {
  const FeedPostCard({required this.post, super.key});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final avatar = _avatarFor(post.childColorToken);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(
                label: post.childInitial ?? '',
                backgroundColor: avatar.background,
                foregroundColor: avatar.foreground,
                iconAsset: post.type == PostType.announcement
                    ? 'assets/icons/megaphone.svg'
                    : null,
                semanticLabel: post.childName,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.childName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.fredoka(size: 16.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.postMeta(post.timeLabel),
                      style: AppTypography.nunito(
                        size: 12.5,
                        color: AppColors.textSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              PostTypeBadge(type: post.type),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _audienceLabel(l10n, post),
            style: AppTypography.nunito(size: 12.5, color: AppColors.textSoft),
          ),
          const SizedBox(height: 10),
          Text(
            post.body,
            style: AppTypography.nunito(
              size: 15.5,
              height: 1.55,
              color: AppColors.textBody,
            ),
          ),
          if (post.hasPhoto) ...[
            const SizedBox(height: 14),
            AppLink(
              borderRadius: BorderRadius.circular(16),
              child: DashedBox(
                backgroundColor: AppColors.photoBackground,
                borderColor: AppColors.photoBorder,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppIcon(
                      asset: 'assets/icons/image.svg',
                      size: 30,
                      color: AppColors.photoIcon,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.photoLabel(post.photoLabel!),
                      style: AppTypography.nunito(
                        size: 13.5,
                        color: AppColors.photoIcon,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Semantics(
                  label: l10n.likesSemantics(post.likes),
                  child: ExcludeSemantics(
                    child: Row(
                      children: [
                        const AppIcon(
                          asset: 'assets/icons/heart.svg',
                          size: 19,
                          color: AppColors.primaryDark,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          '${post.likes}',
                          style: AppTypography.nunito(
                            size: 14,
                            weight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                AppLink(
                  borderRadius: BorderRadius.circular(8),
                  child: Semantics(
                    label: l10n.commentsSemantics(post.comments),
                    child: ExcludeSemantics(
                      child: Row(
                        children: [
                          const AppIcon(
                            asset: 'assets/icons/comment.svg',
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            '${post.comments}',
                            style: AppTypography.nunito(
                              size: 14,
                              weight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                AppLink(
                  borderRadius: BorderRadius.circular(8),
                  child: Text(
                    l10n.edit,
                    style: AppTypography.nunito(
                      size: 14,
                      weight: FontWeight.w800,
                      color: AppColors.link,
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

  String _audienceLabel(AppLocalizations l10n, Post post) {
    return switch (post.audience) {
      PostAudience.family => l10n.audienceFamily(post.childName),
      PostAudience.room => l10n.audienceAll,
    };
  }

  ({Color background, Color foreground}) _avatarFor(String token) {
    return switch (token) {
      'blue' => (
        background: AppColors.avatarBlueBackground,
        foreground: AppColors.avatarBlueForeground,
      ),
      'announcement' => (
        background: AppColors.announcementBackground,
        foreground: AppColors.announcementForeground,
      ),
      _ => (background: AppColors.avatarCoral, foreground: AppColors.white),
    };
  }
}
