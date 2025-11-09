import '../errors/failures.dart';

/// Classe base para todos os Use Cases
/// Type: Tipo de retorno do Use Case
/// Params: Tipo dos parâmetros de entrada
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Para Use Cases que não precisam de parâmetros
class NoParams {
  const NoParams();
}

/// Resultado que pode conter sucesso ou erro
class Result<T> {
  final T? data;
  final Failure? failure;

  const Result._({this.data, this.failure});

  /// Cria um resultado de sucesso
  factory Result.success(T data) => Result._(data: data);

  /// Cria um resultado de erro
  factory Result.failure(Failure failure) => Result._(failure: failure);

  /// Verifica se o resultado é um sucesso
  bool get isSuccess => data != null && failure == null;

  /// Verifica se o resultado é um erro
  bool get isFailure => failure != null;

  /// Executa uma função se o resultado for sucesso
  Result<R> map<R>(R Function(T data) mapper) {
    if (isSuccess) {
      try {
        return Result.success(mapper(data as T));
      } catch (e) {
        return Result.failure(ValidationFailure(e.toString()));
      }
    }
    return Result.failure(failure!);
  }

  /// Executa uma função se o resultado for erro
  Result<T> mapError(Failure Function(Failure failure) mapper) {
    if (isFailure) {
      return Result.failure(mapper(failure!));
    }
    return this;
  }
}
