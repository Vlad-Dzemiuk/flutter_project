import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/profile/edit_profile_page.dart';
import 'package:project/features/auth/auth_repository.dart';
import 'package:project/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:project/core/di.dart';
import 'package:project/features/auth/data/mappers/user_mapper.dart';
import '../../unit/helpers/widget_test_helpers.dart';
import '../../unit/helpers/test_helpers.dart';

void main() {
  group('EditProfilePage', () {
    late MockAuthRepository mockAuthRepository;
    late MockUpdateProfileUseCase mockUpdateProfileUseCase;

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(const UpdateProfileParams());
    });

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockUpdateProfileUseCase = MockUpdateProfileUseCase();

      // Register dependencies in GetIt
      if (getIt.isRegistered<AuthRepository>()) {
        getIt.unregister<AuthRepository>();
      }
      if (getIt.isRegistered<UpdateProfileUseCase>()) {
        getIt.unregister<UpdateProfileUseCase>();
      }
      getIt.registerLazySingleton<AuthRepository>(() => mockAuthRepository);
      getIt.registerLazySingleton<UpdateProfileUseCase>(
        () => mockUpdateProfileUseCase,
      );

      // Setup mock AuthRepository
      when(
        () => mockAuthRepository.currentUser,
      ).thenReturn(TestDataFactory.createLocalUser());
      when(
        () => mockAuthRepository.authStateChanges(),
      ).thenAnswer((_) => Stream.value(TestDataFactory.createLocalUser()));

      // Setup mock UpdateProfileUseCase
      when(() => mockUpdateProfileUseCase(any())).thenAnswer(
        (_) async => UserMapper.toEntity(TestDataFactory.createLocalUser()),
      );
    });

    tearDown(() {
      if (getIt.isRegistered<AuthRepository>()) {
        getIt.unregister<AuthRepository>();
      }
      if (getIt.isRegistered<UpdateProfileUseCase>()) {
        getIt.unregister<UpdateProfileUseCase>();
      }
    });

    testWidgets('displays edit profile page', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(child: const EditProfilePage()),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EditProfilePage), findsOneWidget);
    });

    testWidgets('displays name input field', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(child: const EditProfilePage()),
      );

      await tester.pumpAndSettle();

      // EditProfilePage uses TextField, not TextFormField
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('displays save button', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(child: const EditProfilePage()),
      );

      await tester.pumpAndSettle();

      // EditProfilePage uses FilledButton, not ElevatedButton
      expect(find.byType(FilledButton), findsWidgets);
    });
  });
}
