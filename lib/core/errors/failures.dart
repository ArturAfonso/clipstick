abstract class Failure {
  const Failure();
}

class CacheFailure extends Failure {
  final String message;

  const CacheFailure(this.message);

  @override
  String toString() => 'CacheFailure: $message';
}

class ValidationFailure extends Failure {
  final String message;

  const ValidationFailure(this.message);

  @override
  String toString() => 'ValidationFailure: $message';
}

class NotFoundFailure extends Failure {
  final String message;

  const NotFoundFailure(this.message);

  @override
  String toString() => 'NotFoundFailure: $message';
}

// Para futuras implementações com Firebase
class NetworkFailure extends Failure {
  final String message;

  const NetworkFailure(this.message);

  @override
  String toString() => 'NetworkFailure: $message';
}

class ServerFailure extends Failure {
  final String message;

  const ServerFailure(this.message);

  @override
  String toString() => 'ServerFailure: $message';
}
