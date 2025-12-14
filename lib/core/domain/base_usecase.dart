/// Базовий клас для всіх use cases
///
/// [T] - тип результату, який повертає use case
/// [Params] - параметри для виконання use case
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// Базовий клас для use cases без параметрів
abstract class UseCaseNoParams<T> {
  Future<T> call();
}

/// Клас для use cases, які не потребують параметрів
class NoParams {
  const NoParams();
}
