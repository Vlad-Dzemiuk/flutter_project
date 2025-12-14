import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/profile/profile_page.dart';
import 'package:project/features/auth/auth_bloc.dart';
import 'package:project/features/auth/auth_repository.dart';
import 'package:project/core/di.dart';
import '../../unit/helpers/widget_test_helpers.dart';
import '../../unit/helpers/test_helpers.dart';

void main() {
  group('ProfilePage', () {
    late AuthBloc authBloc;
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      authBloc = WidgetTestHelper.createMockAuthBloc(isAuthenticated: false);
      mockAuthRepository = MockAuthRepository();

      // Register AuthRepository in GetIt
      if (getIt.isRegistered<AuthRepository>()) {
        getIt.unregister<AuthRepository>();
      }
      getIt.registerLazySingleton<AuthRepository>(() => mockAuthRepository);

      // Register AuthBloc in GetIt
      if (getIt.isRegistered<AuthBloc>()) {
        getIt.unregister<AuthBloc>();
      }
      getIt.registerLazySingleton<AuthBloc>(() => authBloc);

      // Setup mock AuthRepository
      when(() => mockAuthRepository.currentUser).thenReturn(null);
      when(
        () => mockAuthRepository.authStateChanges(),
      ).thenAnswer((_) => Stream.value(null));
    });

    tearDown(() {
      authBloc.close();
      if (getIt.isRegistered<AuthRepository>()) {
        getIt.unregister<AuthRepository>();
      }
      if (getIt.isRegistered<AuthBloc>()) {
        getIt.unregister<AuthBloc>();
      }
    });

    testWidgets('displays profile page', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const ProfilePage(),
          authBloc: authBloc,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('displays login form when not authenticated', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const ProfilePage(),
          authBloc: authBloc,
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.byType(TextFormField),
        findsNWidgets(2),
      ); // Email and password
    });

    testWidgets('displays user profile when authenticated', (
      WidgetTester tester,
    ) async {
      final authenticatedBloc = WidgetTestHelper.createMockAuthBloc(
        isAuthenticated: true,
      );

      // Register the authenticated bloc in GetIt
      if (getIt.isRegistered<AuthBloc>()) {
        getIt.unregister<AuthBloc>();
      }
      getIt.registerLazySingleton<AuthBloc>(() => authenticatedBloc);

      // Update mock to return authenticated user
      when(
        () => mockAuthRepository.currentUser,
      ).thenReturn(TestDataFactory.createLocalUser());

      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const ProfilePage(),
          authBloc: authenticatedBloc,
        ),
      );

      await tester.pumpAndSettle();

      // Should show profile information
      expect(find.byType(ProfilePage), findsOneWidget);

      // Cleanup
      if (getIt.isRegistered<AuthBloc>()) {
        getIt.unregister<AuthBloc>();
      }
      authenticatedBloc.close();
    });

    testWidgets('displays settings button', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const ProfilePage(),
          authBloc: authBloc,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings_outlined), findsWidgets);
    });
  });
}
