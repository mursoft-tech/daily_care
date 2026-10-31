abstract final class AppRoutes {
  static const home = '/';
  static const kids = '/kids';
  static const newChild = '/kids/nuevo';
  static const childProfile = '/kids/:childId';
  static const login = '/login';
  static const activateAccount = '/activar-cuenta';

  static String childProfilePath(String childId) =>
      '/kids/${Uri.encodeComponent(childId)}';
}
