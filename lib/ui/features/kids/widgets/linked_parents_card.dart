import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/models/guardian.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_link.dart';
import '../../../core/widgets/dashed_box.dart';
import 'child_avatar_palette.dart';

class LinkedParentsCard extends StatelessWidget {
  const LinkedParentsCard({required this.guardians, super.key});

  final List<Guardian> guardians;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.childProfileParentsTitle,
            style: AppTypography.nunito(
              size: 12.5,
              weight: FontWeight.w800,
              color: AppColors.sectionLabel,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          if (guardians.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                l10n.childProfileNoParents,
                style: AppTypography.nunito(
                  size: 13.5,
                  color: AppColors.textSoft,
                ),
              ),
            )
          else
            for (var i = 0; i < guardians.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _GuardianRow(guardian: guardians[i]),
              ),
          _LinkParentAction(
            label: guardians.isEmpty ? l10n.linkParent : l10n.linkAnotherParent,
          ),
        ],
      ),
    );
  }
}

class _GuardianRow extends StatelessWidget {
  const _GuardianRow({required this.guardian});

  final Guardian guardian;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = guardianAvatarPalette(guardian.colorToken);
    final role = _roleLabel(l10n, guardian.relationship);
    final status = _statusLabel(l10n, guardian);

    return Row(
      children: [
        AppAvatar(
          label: guardian.initial,
          semanticLabel: guardian.fullName,
          backgroundColor: palette.background,
          foregroundColor: palette.foreground,
          size: 40,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                guardian.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.nunito(
                  size: 14.5,
                  weight: FontWeight.w800,
                ),
              ),
              Text(
                '$role · $status',
                maxLines: 2,
                style: AppTypography.nunito(
                  size: 12.5,
                  color: AppColors.textSoft,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _StatusBadge(active: guardian.isActive),
      ],
    );
  }

  String _roleLabel(AppLocalizations l10n, GuardianRelationship relationship) {
    return switch (relationship) {
      GuardianRelationship.mother => l10n.parentRoleMother,
      GuardianRelationship.father => l10n.parentRoleFather,
      GuardianRelationship.guardian => l10n.parentRoleGuardian,
    };
  }

  String _statusLabel(AppLocalizations l10n, Guardian guardian) {
    if (!guardian.isActive) return l10n.parentStatusInvited;
    return switch (guardian.relationship) {
      GuardianRelationship.mother => l10n.parentStatusActiveFemale,
      GuardianRelationship.father => l10n.parentStatusActiveMale,
      GuardianRelationship.guardian => l10n.parentStatusActiveNeutral,
    };
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? AppColors.statusActiveBackground
            : AppColors.statusPendingBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        active ? l10n.parentBadgeActive : l10n.parentBadgePending,
        style: AppTypography.nunito(
          size: 10.5,
          weight: FontWeight.w800,
          color: active
              ? AppColors.statusActiveForeground
              : AppColors.statusPendingForeground,
        ),
      ),
    );
  }
}

class _LinkParentAction extends StatelessWidget {
  const _LinkParentAction({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppLink(
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: DashedBox(
                height: 40,
                radius: 20,
                backgroundColor: Colors.transparent,
                borderColor: AppColors.guardianDashedBorder,
                child: const AppIcon(
                  asset: 'assets/icons/plus.svg',
                  size: 18,
                  color: AppColors.guardianDashedIcon,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                style: AppTypography.nunito(
                  size: 14.5,
                  weight: FontWeight.w800,
                  color: AppColors.link,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
