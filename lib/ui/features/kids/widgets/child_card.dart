import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/models/child.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_link.dart';
import 'child_avatar_palette.dart';

class ChildCard extends StatefulWidget {
  const ChildCard({
    required this.child,
    required this.ageYears,
    this.onTap,
    super.key,
  });

  final Child child;
  final int ageYears;
  final VoidCallback? onTap;

  @override
  State<ChildCard> createState() => _ChildCardState();
}

class _ChildCardState extends State<ChildCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final child = widget.child;
    final palette = childAvatarPalette(child.colorToken);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: _hovered ? AppColors.cardHoverBorder : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 14,
              offset: Offset(0, 4),
              spreadRadius: -12,
            ),
          ],
        ),
        child: AppLink(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Semantics(
            label: _semanticLabel(l10n, child),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  AppAvatar(
                    label: child.initial,
                    semanticLabel: child.fullName,
                    backgroundColor: palette.background,
                    foregroundColor: palette.foreground,
                    size: 48,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.fredoka(size: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${l10n.childAge(widget.ageYears)} · '
                          '${l10n.linkedParents(child.linkedParents)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.nunito(
                            size: 13,
                            color: AppColors.textSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _trailing(l10n, child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _trailing(AppLocalizations l10n, Child child) {
    if (child.hasAllergy) {
      return _ChildBadge(
        label: _allergyBadgeLabel(child),
        background: AppColors.allergyBackground,
        foreground: AppColors.allergyForeground,
      );
    }
    if (child.linkedParents == 0) {
      return _ChildBadge(
        label: l10n.linkParentBadge,
        background: AppColors.linkParentBackground,
        foreground: AppColors.linkParentForeground,
      );
    }
    return const AppIcon(
      asset: 'assets/icons/chevron-right.svg',
      size: 18,
      color: AppColors.cardChevron,
    );
  }

  String _semanticLabel(AppLocalizations l10n, Child child) {
    final parts = [
      child.fullName,
      l10n.childAge(widget.ageYears),
      l10n.linkedParents(child.linkedParents),
      if (child.hasAllergy)
        child.allergies.map((allergy) => allergy.label).join(', '),
    ];
    return parts.join('. ');
  }

  String _allergyBadgeLabel(Child child) {
    final first = child.allergies.first.label;
    final extra = child.allergies.length - 1;
    return extra > 0 ? '$first +$extra' : first;
  }
}

class _ChildBadge extends StatelessWidget {
  const _ChildBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.nunito(
          size: 11,
          weight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}
