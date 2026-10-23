import 'package:material_ui/material_ui.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import 'app_avatar.dart';
import 'app_icon.dart';
import 'app_link.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, this.selectedIndex = 0, super.key});

  final Widget child;
  final int selectedIndex;

  static const _largeBreakpoint = 900.0;
  static const _mediumBreakpoint = 600.0;
  static const _accountName = 'Caro Giménez';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= _largeBreakpoint) {
          return Scaffold(
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Sidebar(
                  key: const Key('app-sidebar'),
                  selectedIndex: selectedIndex,
                ),
                Expanded(child: child),
              ],
            ),
          );
        }

        if (width >= _mediumBreakpoint) {
          return Scaffold(
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AppRail(
                  key: const Key('app-rail'),
                  selectedIndex: selectedIndex,
                ),
                Expanded(child: child),
              ],
            ),
          );
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: _AppBottomBar(
            key: const Key('app-bottom-nav'),
            selectedIndex: selectedIndex,
          ),
        );
      },
    );
  }
}

class _Destination {
  const _Destination(this.asset, this.label);

  final String asset;
  final String label;
}

List<_Destination> _destinations(AppLocalizations l10n) => [
  _Destination('assets/icons/home.svg', l10n.navFeed),
  _Destination('assets/icons/children.svg', l10n.navChildren),
  _Destination('assets/icons/bell.svg', l10n.navNotices),
  _Destination('assets/icons/account.svg', l10n.navAccount),
];

void _onDestination(BuildContext context, int index) {
  if (index == 0) return;
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(context).comingSoon)),
  );
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selectedIndex, super.key});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = _destinations(l10n);

    return Container(
      width: 248,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppLink(
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 22),
              child: Row(
                children: [
                  const _LogoMark(size: 38),
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
              child: _SidebarDestination(
                destination: destinations[i],
                active: i == selectedIndex,
                onTap: () => _onDestination(context, i),
              ),
            ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const AppAvatar(
                  label: 'C',
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
                        AppShell._accountName,
                        style: AppTypography.nunito(
                          size: 14,
                          weight: FontWeight.w800,
                          color: AppColors.textStrong,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        l10n.teacherRole,
                        style: AppTypography.nunito(
                          size: 12,
                          color: AppColors.textSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                AppLink(
                  tooltip: l10n.logoutTooltip,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AppIcon(
                      asset: 'assets/icons/logout.svg',
                      size: 16,
                      color: AppColors.textMuted,
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

class _LogoMark extends StatelessWidget {
  const _LogoMark({this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.logoGradientStart, AppColors.logoGradientEnd],
        ),
      ),
      child: AppIcon(
        asset: 'assets/icons/logo_sun.svg',
        size: size * 0.55,
        color: AppColors.white,
      ),
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

class _SidebarDestination extends StatelessWidget {
  const _SidebarDestination({
    required this.destination,
    required this.active,
    required this.onTap,
  });

  final _Destination destination;
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

class _AppRail extends StatelessWidget {
  const _AppRail({required this.selectedIndex, super.key});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = _destinations(l10n);

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => _onDestination(context, index),
      labelType: NavigationRailLabelType.none,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.navActiveBackground,
      useIndicator: true,
      minWidth: 76,
      leading: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 12),
        child: AppLink(child: const _LogoMark(size: 38)),
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: AppLink(
          tooltip: l10n.logoutTooltip,
          child: const AppAvatar(
            label: 'C',
            backgroundColor: AppColors.avatarCoral,
            foregroundColor: AppColors.white,
            size: 36,
          ),
        ),
      ),
      destinations: [
        for (var i = 0; i < destinations.length; i++)
          NavigationRailDestination(
            icon: AppIcon(
              asset: destinations[i].asset,
              color: i == selectedIndex
                  ? AppColors.navActiveForeground
                  : AppColors.navInactive,
            ),
            selectedIcon: AppIcon(
              asset: destinations[i].asset,
              color: AppColors.navActiveForeground,
            ),
            label: Text(destinations[i].label),
          ),
      ],
    );
  }
}

class _AppBottomBar extends StatelessWidget {
  const _AppBottomBar({required this.selectedIndex, super.key});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = _destinations(l10n);

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => _onDestination(context, index),
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.navActiveBackground,
      height: 72,
      destinations: [
        for (var i = 0; i < destinations.length; i++)
          NavigationDestination(
            icon: AppIcon(
              asset: destinations[i].asset,
              color: AppColors.navInactive,
            ),
            selectedIcon: AppIcon(
              asset: destinations[i].asset,
              color: AppColors.navActiveForeground,
            ),
            label: destinations[i].label,
          ),
      ],
    );
  }
}
