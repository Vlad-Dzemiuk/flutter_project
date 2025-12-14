import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/profile/profile_bloc.dart';
import 'package:project/features/profile/profile_event.dart';
import 'package:project/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:project/features/profile/domain/repositories/profile_repository.dart';

void main() {
  late ProfileBloc profileBloc;
  late MockGetUserProfileUseCase mockGetUserProfileUseCase;

  setUpAll(() {
    registerFallbackValue(const GetUserProfileParams(userId: 1));
  });

  setUp(() {
    mockGetUserProfileUseCase = MockGetUserProfileUseCase();
    // Mock the use case to return a default value to prevent errors during initialization
    when(() => mockGetUserProfileUseCase(any())).thenAnswer(
      (_) async => UserProfile(
        name: 'Initial User',
        username: 'initial',
        avatarPath: '',
      ),
    );
    profileBloc = ProfileBloc(getUserProfileUseCase: mockGetUserProfileUseCase);
  });

  tearDown(() {
    profileBloc.close();
  });

  group('ProfileBloc', () {
    test('initial state is ProfileState with loading false', () async {
      // Wait for the initial LoadProfileEvent to complete
      await Future.delayed(const Duration(milliseconds: 100));
      // After initial load, state should have loading false
      expect(profileBloc.state.loading, false);
      // Error may be set if initial load fails, so we don't check it here
      // User may be set if initial load succeeds
    });

    blocTest<ProfileBloc, ProfileState>(
      'emits [loading: true, loading: false, user] when LoadProfileEvent is successful',
      build: () {
        final userProfile = UserProfile(
          name: 'Test User',
          username: 'testuser',
          avatarPath: '/avatar.jpg',
        );
        when(
          () => mockGetUserProfileUseCase(any()),
        ).thenAnswer((_) async => userProfile);
        return ProfileBloc(getUserProfileUseCase: mockGetUserProfileUseCase);
      },
      wait: const Duration(
        milliseconds: 200,
      ), // Wait for initial LoadProfileEvent to complete
      skip:
          2, // Skip initial LoadProfileEvent states (loading: true, loading: false)
      act: (bloc) => bloc.add(const LoadProfileEvent()),
      expect: () => [
        isA<ProfileState>().having((s) => s.loading, 'loading', true),
        isA<ProfileState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.user?.name, 'user.name', 'Test User'),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits error message for unauthorized errors',
      build: () {
        when(
          () => mockGetUserProfileUseCase(any()),
        ).thenThrow(Exception('Unauthorized: Permission denied'));
        return ProfileBloc(getUserProfileUseCase: mockGetUserProfileUseCase);
      },
      wait: const Duration(
        milliseconds: 200,
      ), // Wait for initial LoadProfileEvent to complete
      skip: 2, // Skip initial LoadProfileEvent states
      act: (bloc) => bloc.add(const LoadProfileEvent()),
      expect: () => [
        isA<ProfileState>().having((s) => s.loading, 'loading', true),
        isA<ProfileState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.error, 'error', contains('Недостатньо прав')),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits error message for not found errors',
      build: () {
        when(
          () => mockGetUserProfileUseCase(any()),
        ).thenThrow(Exception('NotFoundException: 404'));
        return ProfileBloc(getUserProfileUseCase: mockGetUserProfileUseCase);
      },
      wait: const Duration(
        milliseconds: 200,
      ), // Wait for initial LoadProfileEvent to complete
      skip: 2, // Skip initial LoadProfileEvent states
      act: (bloc) => bloc.add(const LoadProfileEvent()),
      expect: () => [
        isA<ProfileState>().having((s) => s.loading, 'loading', true),
        isA<ProfileState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.error, 'error', contains('не знайдено')),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits generic error message for unknown errors',
      build: () {
        when(
          () => mockGetUserProfileUseCase(any()),
        ).thenThrow(Exception('Unknown error'));
        return ProfileBloc(getUserProfileUseCase: mockGetUserProfileUseCase);
      },
      wait: const Duration(
        milliseconds: 200,
      ), // Wait for initial LoadProfileEvent to complete
      skip: 2, // Skip initial LoadProfileEvent states
      act: (bloc) => bloc.add(const LoadProfileEvent()),
      expect: () => [
        isA<ProfileState>().having((s) => s.loading, 'loading', true),
        isA<ProfileState>().having((s) => s.loading, 'loading', false).having(
              (s) => s.error,
              'error',
              contains('Не вдалося завантажити профіль'),
            ),
      ],
    );
  });
}

class MockGetUserProfileUseCase extends Mock implements GetUserProfileUseCase {}
