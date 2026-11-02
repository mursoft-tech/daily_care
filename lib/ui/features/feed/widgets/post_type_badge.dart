import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/models/post_type.dart';
import '../../../../l10n/app_localizations.dart';
import 'post_type_presentation.dart';

class PostTypeBadge extends StatelessWidget {
  const PostTypeBadge({required this.type, super.key});

  final PostType type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<FeedColors>()!;
    final presentation = postTypePresentation(colors, l10n, type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: presentation.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: presentation.foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            presentation.label,
            style: AppTypography.nunito(
              size: 12,
              weight: FontWeight.w800,
              color: presentation.foreground,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
