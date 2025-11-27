import '../errors/failures.dart';




abstract class UseCase<type, Params> {
  Future<type> call(Params params);
}


class NoParams {
  const NoParams();
}


class Result<T> {
  final T? data;
  final Failure? failure;

  const Result._({this.data, this.failure});

  
  factory Result.success(T data) => Result._(data: data);

  
  factory Result.failure(Failure failure) => Result._(failure: failure);

  
  bool get isSuccess => data != null && failure == null;

  
  bool get isFailure => failure != null;

  
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

  
  Result<T> mapError(Failure Function(Failure failure) mapper) {
    if (isFailure) {
      return Result.failure(mapper(failure!));
    }
    return this;
  }
}
