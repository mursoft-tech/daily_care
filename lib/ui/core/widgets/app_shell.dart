import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../domain/models/session_user.dart';
import '../../../l10n/app_localizations.dart';
import 'app_avatar.dart';
import 'app_icon.dart';
import 'app_link.dart';
import 'app_logo_mark.dart';
import 'app_logout_button.dart';
import 'app_navigation_panel.dart';

class AppShell extends ConsumerWidget {
  const AppShell({
    required this.child,
    required this.onLogout,
    this.selectedIndex = 0,
    super.key,
  });

  final Widget child;
  final VoidCallback onLogout;
  final int selectedIndex;

  static const _largeBreakpoint = 900.0;
  static const _mediumBreakpoint = 600.0;
  static const _sidebarWidth = 248.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionUser = ref.watch(sessionUserProvider);

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
                  sessionUser: sessionUser,
                  onLogout: onLogout,
                ),
                Expanded(child: SafeArea(child: child)),
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
                  sessionUser: sessionUser,
                  onLogout: onLogout,
                ),
                Expanded(child: SafeArea(child: child)),
              ],
            ),
          );
        }

        return _CompactShell(
          selectedIndex: selectedIndex,
          sessionUser: sessionUser,
          onLogout: onLogout,
          child: child,
        );
      },
    );
  }
}

void _onDestination(BuildContext context, int index) {
  if (index == 0) return;
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(context).comingSoon)),
  );
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selectedIndex,
    required this.sessionUser,
    required this.onLogout,
    super.key,
  });

  final int selectedIndex;
  final SessionUser sessionUser;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppShell._sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: AppNavigationPanel(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onDestination(context, index),
        onLogout: onLogout,
        sessionUser: sessionUser,
      ),
    );
  }
}

class _CompactShell extends StatelessWidget {
  const _CompactShell({
    required this.child,
    required this.selectedIndex,
    required this.sessionUser,
    required this.onLogout,
  });

  final Widget child;
  final int selectedIndex;
  final SessionUser sessionUser;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final availableWidth = MediaQuery.sizeOf(context).width;
    final panelWidth = math.min(
      AppShell._sidebarWidth,
      availableWidth * 0.85,
    );

    return Scaffold(
      appBar: AppBar(
        key: const Key('app-top-bar'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        titleSpacing: 0,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
        leading: Builder(
          builder: (buttonContext) => IconButton(
            key: const Key('app-menu-button'),
            tooltip: l10n.menuTooltip,
            onPressed: () => Scaffold.of(buttonContext).openDrawer(),
            icon: const AppIcon(
              asset: 'assets/icons/menu.svg',
              size: 22,
              color: AppColors.textStrong,
            ),
          ),
        ),
        title: Row(
          children: [
            const AppLogoMark(size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.brandName,
                    style: AppTypography.fredoka(size: 16, height: 1),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.salaName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.nunito(
                      size: 11,
                      color: AppColors.textSoft,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          AppAvatar(
            label: sessionUser.initial,
            semanticLabel: sessionUser.fullName,
            backgroundColor: AppColors.avatarCoral,
            foregroundColor: AppColors.white,
            size: 34,
          ),
          const SizedBox(width: 6),
          AppLogoutButton(
            key: const Key('app-bar-logout'),
            onLogout: onLogout,
            visualSize: 36,
            iconSize: 17,
          ),
          const SizedBox(width: 12),
        ],
      ),
      drawer: Drawer(
        key: const Key('app-drawer'),
        width: panelWidth,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Builder(
              builder: (drawerContext) => AppNavigationPanel(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  Scaffold.of(drawerContext).closeDrawer();
                  _onDestination(drawerContext, index);
                },
                onLogout: () {
                  Scaffold.of(drawerContext).closeDrawer();
                  onLogout();
                },
                sessionUser: sessionUser,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(child: child),
    );
  }
}

class _AppRail extends StatelessWidget {
  const _AppRail({
    required this.selectedIndex,
    required this.sessionUser,
    required this.onLogout,
    super.key,
  });

  final int selectedIndex;
  final SessionUser sessionUser;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = appNavigationDestinations(l10n);

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => _onDestination(context, index),
      labelType: NavigationRailLabelType.none,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.navActiveBackground,
      useIndicator: true,
      minWidth: 76,
      leading: const Padding(
        padding: EdgeInsets.only(top: 16, bottom: 12),
        child: AppLink(child: AppLogoMark(size: 38)),
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: AppLogoutButton(
          key: const Key('app-rail-logout'),
          onLogout: onLogout,
          child: AppAvatar(
            label: sessionUser.initial,
            semanticLabel: sessionUser.fullName,
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
