sealed class Failure {
  const Failure();
}

final class NetworkFailure extends Failure {
  const NetworkFailure();
}

final class EdgeUnavailableFailure extends Failure {
  const EdgeUnavailableFailure();
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure();
}

final class ForbiddenFailure extends Failure {
  const ForbiddenFailure();
}

final class UnknownFailure extends Failure {
  const UnknownFailure();
}

final class ValidationFailure extends Failure {
  const ValidationFailure();
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure();
}

final class ConflictFailure extends Failure {
  const ConflictFailure();
}
