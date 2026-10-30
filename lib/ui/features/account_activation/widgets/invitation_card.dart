import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/models/account_invitation.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_avatar.dart';

class InvitationCard extends StatelessWidget {
  const InvitationCard({required this.invitation, super.key});

  final AccountInvitation invitation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.loginBorder, width: 1.5),
      ),
      child: Row(
        children: [
          AppAvatar(
            label: invitation.childInitial,
            backgroundColor: AppColors.avatarBlueBackground,
            foregroundColor: AppColors.avatarBlueForeground,
            semanticLabel: invitation.childName,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.activateInvitedTo,
                  style: AppTypography.nunito(
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  l10n.activateChildRoom(
                    invitation.childName,
                    invitation.roomName,
                  ),
                  style: AppTypography.fredoka(
                    size: 17,
                    weight: FontWeight.w600,
                    color: AppColors.textStrong,
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
