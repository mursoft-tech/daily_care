sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.failure);

  final AppFailure failure;
}

sealed class AppFailure {
  const AppFailure();
}

final class DataFailure extends AppFailure {
  const DataFailure();
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure();
}

/// El correo ya pertenece a un tutor vinculado al mismo niño.
final class GuardianAlreadyLinkedFailure extends AppFailure {
  const GuardianAlreadyLinkedFailure();
}
