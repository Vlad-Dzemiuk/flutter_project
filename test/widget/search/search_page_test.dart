import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/search/search_page.dart';
import 'package:project/features/collections/media_collections_bloc.dart';
import 'package:project/core/di.dart';
import 'package:project/features/home/domain/usecases/search_media_usecase.dart';
import 'package:project/features/auth/auth_repository.dart';
import '../../unit/helpers/widget_test_helpers.dart';
import '../../unit/helpers/test_helpers.dart';

void main() {
  group('SearchPage', () {
    late MediaCollectionsBloc mediaCollectionsBloc;
    late MockSearchMediaUseCase mockSearchMediaUseCase;
    late MockAuthRepository mockAuthRepository;

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(const SearchMediaParams());
    });

    setUp(() {
      mediaCollectionsBloc = WidgetTestHelper.createMockMediaCollectionsBloc();
      mockSearchMediaUseCase = MockSearchMediaUseCase();
      mockAuthRepository = MockAuthRepository();

      // Register dependencies in GetIt
      if (getIt.isRegistered<SearchMediaUseCase>()) {
        getIt.unregister<SearchMediaUseCase>();
      }
      if (getIt.isRegistered<AuthRepository>()) {
        getIt.unregister<AuthRepository>();
      }
      if (getIt.isRegistered<MediaCollectionsBloc>()) {
        getIt.unregister<MediaCollectionsBloc>();
      }
      getIt.registerLazySingleton<SearchMediaUseCase>(
        () => mockSearchMediaUseCase,
      );
      getIt.registerLazySingleton<AuthRepository>(() => mockAuthRepository);
      getIt.registerLazySingleton<MediaCollectionsBloc>(
        () => mediaCollectionsBloc,
      );

      // Setup mock AuthRepository
      when(() => mockAuthRepository.currentUser).thenReturn(null);
      when(
        () => mockAuthRepository.authStateChanges(),
      ).thenAnswer((_) => Stream.value(null));

      // Setup mock SearchMediaUseCase
      when(() => mockSearchMediaUseCase(any())).thenAnswer(
        (_) async => const SearchMediaResult(results: [], hasMore: false),
      );
    });

    tearDown(() {
      mediaCollectionsBloc.close();
      if (getIt.isRegistered<SearchMediaUseCase>()) {
        getIt.unregister<SearchMediaUseCase>();
      }
      if (getIt.isRegistered<AuthRepository>()) {
        getIt.unregister<AuthRepository>();
      }
      if (getIt.isRegistered<MediaCollectionsBloc>()) {
        getIt.unregister<MediaCollectionsBloc>();
      }
    });

    testWidgets('displays search page', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const SearchPage(),
          mediaCollectionsBloc: mediaCollectionsBloc,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SearchPage), findsOneWidget);
    });

    testWidgets('displays search input field', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const SearchPage(),
          mediaCollectionsBloc: mediaCollectionsBloc,
        ),
      );

      await tester.pumpAndSettle();

      // There should be at least one TextField (the main search field)
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('displays filter toggle button', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const SearchPage(),
          mediaCollectionsBloc: mediaCollectionsBloc,
        ),
      );

      await tester.pumpAndSettle();

      // Initially shows Icons.tune_rounded, after toggle shows Icons.tune
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    });

    testWidgets('can enter search query', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const SearchPage(),
          mediaCollectionsBloc: mediaCollectionsBloc,
        ),
      );

      await tester.pumpAndSettle();

      // Find the main search TextField (first one)
      final searchFields = find.byType(TextField);
      expect(searchFields, findsWidgets);

      final searchField = searchFields.first;
      await tester.tap(searchField);
      await tester.enterText(searchField, 'test query');
      await tester.pump();

      expect(find.text('test query'), findsOneWidget);
    });

    testWidgets('can toggle filters visibility', (WidgetTester tester) async {
      // Set a larger screen size to avoid overflow issues
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const SearchPage(),
          mediaCollectionsBloc: mediaCollectionsBloc,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Initially shows Icons.tune_rounded
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);

      final filterButton = find.byIcon(Icons.tune_rounded);
      await tester.tap(filterButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // After toggle, should show Icons.tune
      expect(find.byIcon(Icons.tune), findsOneWidget);

      // Filters should be visible (more TextFields)
      expect(find.byType(TextField), findsAtLeastNWidgets(2));
    });
  });
}
