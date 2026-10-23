import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/features/feed/views/home_view.dart';
import '../../ui/features/login/views/login_placeholder_view.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeView()),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPlaceholderView(),
      ),
    ],
    errorBuilder: (context, state) => const HomeView(),
  );

  ref.onDispose(router.dispose);
  return router;
});
