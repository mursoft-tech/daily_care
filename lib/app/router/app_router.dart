import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/core/views/route_error_view.dart';
import '../../ui/features/account_activation/views/activate_account_view.dart';
import '../../ui/features/feed/views/home_view.dart';
import '../../ui/features/kids/views/child_profile_view.dart';
import '../../ui/features/kids/views/kids_view.dart';
import '../../ui/features/kids/views/new_child_view.dart';
import '../../ui/features/login/views/login_view.dart';
import '../providers.dart';
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: AppRoutes.kids,
        builder: (context, state) => const KidsView(),
      ),
      GoRoute(
        path: AppRoutes.newChild,
        builder: (context, state) => const NewChildView(),
      ),
      GoRoute(
        path: AppRoutes.childProfile,
        builder: (context, state) => ChildProfileView(
          childId: state.pathParameters['childId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.activateAccount,
        builder: (context, state) => ActivateAccountView(
          code: state.uri.queryParameters['codigo'] ??
              ref.read(demoInvitationCodeProvider),
        ),
      ),
      GoRoute(
        path: RouteErrorView.path,
        builder: (context, state) => const RouteErrorView(),
      ),
    ],
    onException: (context, state, router) => router.go(RouteErrorView.path),
  );

  ref.onDispose(router.dispose);
  return router;
});
