import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/models/child.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_link.dart';
import 'child_avatar_palette.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.child,
    required this.ageYears,
    super.key,
  });

  static const _stackBreakpoint = 380.0;

  final Child child;
  final int ageYears;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = childAvatarPalette(child.colorToken);

    final avatar = AppAvatar(
      label: child.initial,
      semanticLabel: child.fullName,
      backgroundColor: palette.background,
      foregroundColor: palette.foreground,
      size: 84,
    );
    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(child.fullName, style: AppTypography.fredoka(size: 28)),
        const SizedBox(height: 3),
        Text(
          '${l10n.childAge(ageYears)} · ${l10n.salaName}',
          style: AppTypography.nunito(size: 15, color: AppColors.textMuted),
        ),
      ],
    );
    const edit = _EditButton();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _stackBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  avatar,
                  const SizedBox(width: 18),
                  Expanded(child: identity),
                ],
              ),
              const SizedBox(height: 14),
              edit,
            ],
          );
        }

        return Row(
          children: [
            avatar,
            const SizedBox(width: 18),
            Expanded(child: identity),
            const SizedBox(width: 12),
            edit,
          ],
        );
      },
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton();

  @override
  Widget build(BuildContext context) {
    return AppLink(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          AppLocalizations.of(context).edit,
          style: AppTypography.nunito(
            size: 14,
            weight: FontWeight.w700,
            color: AppColors.navInactive,
          ),
        ),
      ),
    );
  }
}
