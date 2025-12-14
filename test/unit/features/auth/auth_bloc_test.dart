import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/auth/auth_bloc.dart';
import 'package:project/features/auth/auth_event.dart';
import 'package:project/features/auth/auth_state.dart';
import 'package:project/features/auth/auth_repository.dart';
import 'package:project/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:project/features/auth/domain/usecases/register_usecase.dart';
import 'package:project/features/auth/data/models/local_user.dart';
import 'package:project/features/auth/domain/entities/user.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockRepository;
  late MockSignInUseCase mockSignInUseCase;
  late MockRegisterUseCase mockRegisterUseCase;

  setUpAll(() {
    registerFallbackValue(
      const SignInParams(email: 'test@example.com', password: 'password'),
    );
    registerFallbackValue(
      const RegisterParams(email: 'test@example.com', password: 'password'),
    );
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    mockSignInUseCase = MockSignInUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    authBloc = AuthBloc(
      repository: mockRepository,
      signInUseCase: mockSignInUseCase,
      registerUseCase: mockRegisterUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when SignInEvent is successful',
      build: () {
        final user = User(
          id: 1,
          email: 'test@example.com',
          displayName: 'Test User',
        );
        when(() => mockSignInUseCase(any())).thenAnswer((_) async => user);
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const SignInEvent(email: 'test@example.com', password: 'password123'),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having(
          (state) => state.user.email,
          'email',
          'test@example.com',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when SignInEvent fails',
      build: () {
        when(
          () => mockSignInUseCase(any()),
        ).thenThrow(Exception('Invalid credentials'));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const SignInEvent(email: 'test@example.com', password: 'wrong'),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when RegisterEvent is successful',
      build: () {
        final user = User(
          id: 1,
          email: 'test@example.com',
          displayName: 'Test User',
        );
        when(() => mockRegisterUseCase(any())).thenAnswer((_) async => user);
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const RegisterEvent(email: 'test@example.com', password: 'password123'),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthInitial] when SignOutEvent is successful',
      build: () {
        when(() => mockRepository.signOut()).thenAnswer((_) async => {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignOutEvent()),
      expect: () => [isA<AuthInitial>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthError] when SignOutEvent fails',
      build: () {
        when(
          () => mockRepository.signOut(),
        ).thenThrow(Exception('Sign out failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignOutEvent()),
      expect: () => [isA<AuthError>()],
    );

    test('currentUser returns User when repository has currentUser', () {
      // Arrange
      final localUser = TestDataFactory.createLocalUser();
      when(() => mockRepository.currentUser).thenReturn(localUser);

      // Act
      final user = authBloc.currentUser;

      // Assert
      expect(user, isA<User>());
      expect(user?.email, 'test@example.com');
    });

    test('currentUser returns null when repository has no currentUser', () {
      // Arrange
      when(() => mockRepository.currentUser).thenReturn(null);

      // Act
      final user = authBloc.currentUser;

      // Assert
      expect(user, isNull);
    });
  });
}

class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}
