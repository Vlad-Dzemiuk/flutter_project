import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'domain/entities/user.dart';
import 'domain/usecases/sign_in_usecase.dart';
import 'domain/usecases/register_usecase.dart';
import 'data/mappers/user_mapper.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  final SignInUseCase signInUseCase;
  final RegisterUseCase registerUseCase;

  AuthBloc({
    required this.repository,
    required this.signInUseCase,
    required this.registerUseCase,
  }) : super(AuthInitial()) {
    on<SignInEvent>(_onSignIn);
    on<RegisterEvent>(_onRegister);
    on<SignOutEvent>(_onSignOut);
  }

  User? get currentUser {
    final localUser = repository.currentUser;
    return localUser != null ? UserMapper.toEntity(localUser) : null;
  }

  Future<void> _onSignIn(
    SignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Використання use case замість прямого виклику репозиторію
      final user = await signInUseCase(
        SignInParams(email: event.email, password: event.password),
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      final errorMessage = _getUserFriendlyError(e);
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Використання use case замість прямого виклику репозиторію
      final user = await registerUseCase(
        RegisterParams(email: event.email, password: event.password),
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      final errorMessage = _getUserFriendlyError(e);
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await repository.signOut();
      emit(AuthInitial());
    } catch (e) {
      final errorMessage = _getUserFriendlyError(e);
      emit(AuthError(errorMessage));
    }
  }

  String _getUserFriendlyError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    final errorMessage = error.toString();
    
    // Обробка помилок з локальної бази даних (Drift)
    if (errorMessage.contains('Користувача з таким email не знайдено') ||
        errorString.contains('user-not-found')) {
      return 'Користувача з таким email не знайдено. Перевірте email або зареєструйтеся.';
    }
    
    if (errorMessage.contains('Невірний пароль') ||
        errorString.contains('wrong-password') ||
        errorString.contains('invalid-credential')) {
      return 'Невірний пароль. Спробуйте ще раз.';
    }
    
    if (errorMessage.contains('Користувач з таким email вже існує') ||
        errorString.contains('email-already-in-use') ||
        errorString.contains('email-already-exists')) {
      return 'Цей email вже зареєстровано. Використайте інший email або увійдіть.';
    }
    
    if (errorMessage.contains('Email не може бути порожнім')) {
      return 'Введіть email.';
    }
    
    if (errorMessage.contains('Пароль не може бути порожнім')) {
      return 'Введіть пароль.';
    }
    
    if (errorMessage.contains('Невірний формат email') ||
        errorString.contains('invalid-email')) {
      return 'Невірний формат email. Перевірте введені дані.';
    }
    
    if (errorString.contains('weak-password')) {
      return 'Пароль занадто слабкий. Використайте мінімум 6 символів.';
    }
    
    if (errorString.contains('network') || 
        errorString.contains('socketexception') ||
        errorString.contains('failed host lookup')) {
      return 'Немає інтернет-з\'єднання. Перевірте підключення до мережі.';
    }
    
    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return 'Час очікування вичерпано. Перевірте інтернет-з\'єднання.';
    }
    
    // Якщо помилка містить конкретне повідомлення, повертаємо його
    if (errorMessage.isNotEmpty && !errorMessage.contains('exception')) {
      return errorMessage;
    }
    
    // Для інших помилок повертаємо загальне повідомлення
    return 'Сталася помилка: ${errorMessage.isNotEmpty ? errorMessage : "Невідома помилка"}. Спробуйте пізніше.';
  }
}

