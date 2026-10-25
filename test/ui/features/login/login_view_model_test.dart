import 'package:daily_care/ui/features/login/view_models/login_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginViewModel', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state defaults to staff role and suggested email', () {
      final state = container.read(loginViewModelProvider);
      expect(state.role, LoginRole.staff);
      expect(state.email, 'caro@opendaycare.com');
      expect(state.password, isEmpty);
      expect(state.errorType, LoginErrorType.none);
      expect(state.isAuthenticated, isFalse);
    });

    test('selectRole updates role and suggested email', () {
      final notifier = container.read(loginViewModelProvider.notifier);

      notifier.selectRole(LoginRole.family);
      expect(container.read(loginViewModelProvider).role, LoginRole.family);
      expect(
        container.read(loginViewModelProvider).email,
        'lucia.fernandez@gmail.com',
      );

      notifier.selectRole(LoginRole.staff);
      expect(container.read(loginViewModelProvider).role, LoginRole.staff);
      expect(
        container.read(loginViewModelProvider).email,
        'caro@opendaycare.com',
      );
    });

    test('submit rejects invalid email format', () {
      final notifier = container.read(loginViewModelProvider.notifier);
      notifier.setEmail('correo-invalido');
      notifier.setPassword('admin123');

      final success = notifier.submit();

      expect(success, isFalse);
      expect(
        container.read(loginViewModelProvider).errorType,
        LoginErrorType.invalidEmail,
      );
    });

    test('submit rejects empty password', () {
      final notifier = container.read(loginViewModelProvider.notifier);
      notifier.setEmail('admin@opendaycare.com');
      notifier.setPassword('');

      final success = notifier.submit();

      expect(success, isFalse);
      expect(
        container.read(loginViewModelProvider).errorType,
        LoginErrorType.emptyPassword,
      );
    });

    test('submit rejects incorrect credentials', () {
      final notifier = container.read(loginViewModelProvider.notifier);
      notifier.setEmail('admin@opendaycare.com');
      notifier.setPassword('wrongpassword');

      final success = notifier.submit();

      expect(success, isFalse);
      expect(
        container.read(loginViewModelProvider).errorType,
        LoginErrorType.invalidCredentials,
      );
      expect(container.read(loginViewModelProvider).isAuthenticated, isFalse);
    });

    test('submit succeeds with admin / admin123', () {
      final notifier = container.read(loginViewModelProvider.notifier);
      notifier.setEmail('admin');
      notifier.setPassword('admin123');

      final success = notifier.submit();

      expect(success, isTrue);
      expect(
        container.read(loginViewModelProvider).errorType,
        LoginErrorType.none,
      );
      expect(container.read(loginViewModelProvider).isAuthenticated, isTrue);
    });

    test('submit succeeds with admin@opendaycare.com / admin123', () {
      final notifier = container.read(loginViewModelProvider.notifier);
      notifier.setEmail('admin@opendaycare.com');
      notifier.setPassword('admin123');

      final success = notifier.submit();

      expect(success, isTrue);
      expect(
        container.read(loginViewModelProvider).errorType,
        LoginErrorType.none,
      );
      expect(container.read(loginViewModelProvider).isAuthenticated, isTrue);
    });

    test('submit succeeds with caro@opendaycare.com / admin123', () {
      final notifier = container.read(loginViewModelProvider.notifier);
      notifier.setEmail('caro@opendaycare.com');
      notifier.setPassword('admin123');

      final success = notifier.submit();

      expect(success, isTrue);
      expect(
        container.read(loginViewModelProvider).errorType,
        LoginErrorType.none,
      );
      expect(container.read(loginViewModelProvider).isAuthenticated, isTrue);
    });
  });
}
