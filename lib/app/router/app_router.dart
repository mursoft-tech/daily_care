import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/features/feed/views/home_view.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [GoRoute(path: '/', builder: (context, state) => const HomeView())],
    errorBuilder: (context, state) => const HomeView(),
  );

  ref.onDispose(router.dispose);
  return router;
});
