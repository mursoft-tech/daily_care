import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LoginRole {
  staff,
  family,
}

enum LoginErrorType {
  none,
  invalidEmail,
  emptyPassword,
  invalidCredentials,
}

class LoginState {
  final LoginRole role;
  final String email;
  final String password;
  final bool isLoading;
  final LoginErrorType errorType;
  final bool isAuthenticated;

  const LoginState({
    this.role = LoginRole.staff,
    this.email = 'caro@opendaycare.com',
    this.password = '',
    this.isLoading = false,
    this.errorType = LoginErrorType.none,
    this.isAuthenticated = false,
  });

  LoginState copyWith({
    LoginRole? role,
    String? email,
    String? password,
    bool? isLoading,
    LoginErrorType? errorType,
    bool? isAuthenticated,
  }) {
    return LoginState(
      role: role ?? this.role,
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorType: errorType ?? this.errorType,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class LoginViewModel extends Notifier<LoginState> {
  static final RegExp _emailRegExp = RegExp(
    r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  @override
  LoginState build() {
    return const LoginState();
  }

  void selectRole(LoginRole role) {
    final suggestedEmail = role == LoginRole.staff
        ? 'caro@opendaycare.com'
        : 'lucia.fernandez@gmail.com';

    state = state.copyWith(
      role: role,
      email: suggestedEmail,
      errorType: LoginErrorType.none,
    );
  }

  void setEmail(String email) {
    state = state.copyWith(
      email: email,
      errorType: LoginErrorType.none,
    );
  }

  void setPassword(String password) {
    state = state.copyWith(
      password: password,
      errorType: LoginErrorType.none,
    );
  }

  bool submit() {
    final trimmedEmail = state.email.trim();
    final trimmedPassword = state.password.trim();

    // Permitir "admin" como excepción o validar formato de email
    final isEmailValid = trimmedEmail.toLowerCase() == 'admin' ||
        _emailRegExp.hasMatch(trimmedEmail);

    if (!isEmailValid) {
      state = state.copyWith(errorType: LoginErrorType.invalidEmail);
      return false;
    }

    if (trimmedPassword.isEmpty) {
      state = state.copyWith(errorType: LoginErrorType.emptyPassword);
      return false;
    }

    // Credenciales hardcodeadas: admin / admin123 o admin@opendaycare.com / admin123
    final isAuthValid =
        (trimmedEmail.toLowerCase() == 'admin' ||
            trimmedEmail.toLowerCase() == 'admin@opendaycare.com' || trimmedEmail.toLowerCase() == 'caro@opendaycare.com') &&
        trimmedPassword == 'admin123';

    if (!isAuthValid) {
      state = state.copyWith(
        errorType: LoginErrorType.invalidCredentials,
        isAuthenticated: false,
      );
      return false;
    }

    state = state.copyWith(
      errorType: LoginErrorType.none,
      isAuthenticated: true,
    );
    return true;
  }
}

final loginViewModelProvider =
    NotifierProvider<LoginViewModel, LoginState>(LoginViewModel.new);
