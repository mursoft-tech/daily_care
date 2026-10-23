import 'package:material_ui/material_ui.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../domain/models/session_user.dart';
import '../../../l10n/app_localizations.dart';
import 'app_avatar.dart';
import 'app_icon.dart';
import 'app_link.dart';
import 'app_logo_mark.dart';
import 'app_logout_button.dart';

class AppDestination {
  const AppDestination(this.asset, this.label);

  final String asset;
  final String label;
}

List<AppDestination> appNavigationDestinations(AppLocalizations l10n) => [
  AppDestination('assets/icons/home.svg', l10n.navFeed),
  AppDestination('assets/icons/children.svg', l10n.navChildren),
  AppDestination('assets/icons/bell.svg', l10n.navNotices),
  AppDestination('assets/icons/account.svg', l10n.navAccount),
];

String sessionRoleLabel(AppLocalizations l10n, SessionRole role) =>
    switch (role) {
      SessionRole.teacher => l10n.teacherRole,
      SessionRole.family => l10n.familyRole,
    };

/// Contenido de navegación compartido por el sidebar y el drawer.
class AppNavigationPanel extends StatelessWidget {
  const AppNavigationPanel({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onLogout,
    required this.sessionUser,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onLogout;
  final SessionUser sessionUser;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = appNavigationDestinations(l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppLink(
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 22),
            child: Row(
              children: [
                const AppLogoMark(size: 38),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.brandName,
                        style: AppTypography.fredoka(size: 17, height: 1),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.salaName,
                        style: AppTypography.nunito(
                          size: 11.5,
                          color: AppColors.textSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _NewPostButton(label: l10n.newPost),
        const SizedBox(height: 18),
        for (var i = 0; i < destinations.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _PanelDestination(
              destination: destinations[i],
              active: i == selectedIndex,
              onTap: () => onDestinationSelected(i),
            ),
          ),
        const Spacer(),
        _AccountBlock(sessionUser: sessionUser, onLogout: onLogout),
      ],
    );
  }
}

class _NewPostButton extends StatelessWidget {
  const _NewPostButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppLink(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primarySoft, AppColors.primary],
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.primaryShadow,
              blurRadius: 18,
              offset: Offset(0, 8),
              spreadRadius: -8,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppIcon(
              asset: 'assets/icons/plus.svg',
              size: 17,
              color: AppColors.white,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.nunito(
                  size: 14.5,
                  weight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelDestination extends StatelessWidget {
  const _PanelDestination({
    required this.destination,
    required this.active,
    required this.onTap,
  });

  final AppDestination destination;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = active
        ? AppColors.navActiveForeground
        : AppColors.navInactive;

    return AppLink(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: active ? AppColors.navActiveBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            AppIcon(asset: destination.asset, color: foreground),
            const SizedBox(width: 12),
            Text(
              destination.label,
              style: AppTypography.nunito(
                size: 14.5,
                weight: active ? FontWeight.w800 : FontWeight.w600,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountBlock extends StatelessWidget {
  const _AccountBlock({required this.sessionUser, required this.onLogout});

  final SessionUser sessionUser;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.only(top: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          AppAvatar(
            label: sessionUser.initial,
            semanticLabel: sessionUser.fullName,
            backgroundColor: AppColors.avatarCoral,
            foregroundColor: AppColors.white,
            size: 38,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sessionUser.fullName,
                  style: AppTypography.nunito(
                    size: 14,
                    weight: FontWeight.w800,
                    color: AppColors.textStrong,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  sessionRoleLabel(l10n, sessionUser.role),
                  style: AppTypography.nunito(
                    size: 12,
                    color: AppColors.textSoft,
                  ),
                ),
              ],
            ),
          ),
          AppLogoutButton(
            key: const Key('app-panel-logout'),
            onLogout: onLogout,
          ),
        ],
      ),
    );
  }
}
