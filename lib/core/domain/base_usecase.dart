/// Базовий клас для всіх use cases
/// 
/// [Type] - тип результату, який повертає use case
/// [Params] - параметри для виконання use case
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Базовий клас для use cases без параметрів
abstract class UseCaseNoParams<Type> {
  Future<Type> call();
}

/// Клас для use cases, які не потребують параметрів
class NoParams {
  const NoParams();
}


