import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/auth/auth_bloc.dart';
import 'package:project/features/auth/auth_state.dart';
import 'package:project/features/home/home_bloc.dart' show HomeBloc, HomeState;
import 'package:project/features/collections/media_collections_bloc.dart'
    show MediaCollectionsBloc, MediaCollectionsState;
import 'package:project/features/favorites/favorites_bloc.dart'
    show FavoritesBloc, FavoritesState;
import 'package:project/features/search/search_bloc.dart';
import 'package:project/features/search/search_state.dart';
import 'package:project/features/profile/profile_bloc.dart'
    show ProfileBloc, ProfileState;
import 'package:project/features/settings/settings_bloc.dart';
import 'package:project/features/settings/settings_state.dart';
import 'package:project/features/home/home_media_item.dart';
import 'package:project/features/collections/media_collection_entry.dart';
import 'package:project/features/home/data/models/movie_model.dart';
import 'package:project/core/loading_state.dart';
import 'package:project/core/theme.dart';
import 'package:project/core/di.dart';
import 'package:project/core/constants.dart';
import 'package:project/l10n/app_localizations.dart';
import 'package:project/features/auth/data/mappers/user_mapper.dart';
import 'test_helpers.dart';

/// Helper class for widget testing
class WidgetTestHelper {
  /// Creates a MaterialApp wrapper with necessary providers
  static Widget createTestApp({
    required Widget child,
    AuthBloc? authBloc,
    HomeBloc? homeBloc,
    MediaCollectionsBloc? mediaCollectionsBloc,
    FavoritesBloc? favoritesBloc,
    SearchBloc? searchBloc,
    ProfileBloc? profileBloc,
    SettingsBloc? settingsBloc,
    bool setHomePageLoaded = true,
    ThemeMode themeMode = ThemeMode.light,
    Locale locale = const Locale('en'),
  }) {
    // Initialize GetIt for LoadingStateService
    if (!getIt.isRegistered<LoadingStateService>()) {
      getIt.registerLazySingleton<LoadingStateService>(
        () => LoadingStateService(),
      );
    }

    // Set up loading state
    final loadingStateService = getIt<LoadingStateService>();
    if (setHomePageLoaded) {
      loadingStateService.setHomePageLoaded();
    } else {
      loadingStateService.reset();
    }

    // Collect all providers
    final providers = <BlocProvider>[];
    if (authBloc != null) {
      providers.add(BlocProvider<AuthBloc>.value(value: authBloc));
    }
    if (homeBloc != null) {
      providers.add(BlocProvider<HomeBloc>.value(value: homeBloc));
    }
    if (mediaCollectionsBloc != null) {
      providers.add(
        BlocProvider<MediaCollectionsBloc>.value(value: mediaCollectionsBloc),
      );
    }
    if (favoritesBloc != null) {
      providers.add(BlocProvider<FavoritesBloc>.value(value: favoritesBloc));
    }
    if (searchBloc != null) {
      providers.add(BlocProvider<SearchBloc>.value(value: searchBloc));
    }
    if (profileBloc != null) {
      providers.add(BlocProvider<ProfileBloc>.value(value: profileBloc));
    }
    if (settingsBloc != null) {
      providers.add(BlocProvider<SettingsBloc>.value(value: settingsBloc));
    }

    // Use MultiBlocProvider only if there are providers, otherwise just return child
    final wrappedChild = providers.isNotEmpty
        ? MultiBlocProvider(providers: providers, child: child)
        : child;

    // Wrap with ProviderScope for Riverpod support (needed by MovieTrailerPlayer)
    final app = MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: themeMode,
      home: wrappedChild,
      routes: {
        AppConstants.searchRoute: (context) =>
            const Scaffold(body: Center(child: Text('Search Page'))),
        AppConstants.favoritesRoute: (context) =>
            const Scaffold(body: Center(child: Text('Favorites Page'))),
        AppConstants.profileRoute: (context) =>
            const Scaffold(body: Center(child: Text('Profile Page'))),
        AppConstants.loginRoute: (context) =>
            const Scaffold(body: Center(child: Text('Login Page'))),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('Unknown route: ${settings.name}')),
          ),
        );
      },
    );

    return ProviderScope(child: app);
  }

  /// Creates a mock AuthBloc with initial state
  static AuthBloc createMockAuthBloc({
    AuthState? initialState,
    bool isAuthenticated = false,
  }) {
    final bloc = MockAuthBloc();
    final state =
        initialState ??
        (isAuthenticated
            ? AuthAuthenticated(
                UserMapper.toEntity(TestDataFactory.createLocalUser()),
              )
            : AuthInitial());
    when(() => bloc.state).thenReturn(state);
    // Create a stream that emits the current state after subscription
    // Using async* generator to ensure state is emitted after subscription
    when(() => bloc.stream).thenAnswer((_) async* {
      yield state;
    });
    when(() => bloc.isClosed).thenReturn(false);
    when(() => bloc.close()).thenAnswer((_) async {});
    return bloc;
  }

  /// Creates a mock HomeBloc with initial state
  static HomeBloc createMockHomeBloc({
    HomeState? initialState,
    bool isLoading = false,
    List<HomeMediaItem> popularMovies = const [],
    List<HomeMediaItem> popularTvShows = const [],
    List<HomeMediaItem> allMovies = const [],
    List<HomeMediaItem> allTvShows = const [],
    List<HomeMediaItem> searchResults = const [],
  }) {
    final bloc = MockHomeBloc();
    when(() => bloc.state).thenReturn(
      initialState ??
          HomeState(
            loading: isLoading,
            popularMovies: popularMovies,
            popularTvShows: popularTvShows,
            allMovies: allMovies,
            allTvShows: allTvShows,
            searchResults: searchResults,
            error: '',
            searching: false,
            hasMoreResults: false,
            loadingMore: false,
          ),
    );
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => bloc.isClosed).thenReturn(false);
    when(() => bloc.close()).thenAnswer((_) async {});
    return bloc;
  }

  /// Creates a mock MediaCollectionsBloc with initial state
  static MediaCollectionsBloc createMockMediaCollectionsBloc({
    MediaCollectionsState? initialState,
    bool isAuthorized = false,
    List<MediaCollectionEntry> favorites = const [],
    List<MediaCollectionEntry> watchlist = const [],
  }) {
    final bloc = MockMediaCollectionsBloc();
    when(() => bloc.state).thenReturn(
      initialState ??
          MediaCollectionsState(
            authorized: isAuthorized,
            favorites: favorites,
            watchlist: watchlist,
            loading: false,
          ),
    );
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => bloc.isClosed).thenReturn(false);
    when(() => bloc.close()).thenAnswer((_) async {});
    return bloc;
  }

  /// Creates a mock FavoritesBloc with initial state
  static FavoritesBloc createMockFavoritesBloc({
    FavoritesState? initialState,
    bool isLoading = false,
    List<Movie> movies = const [],
  }) {
    final bloc = MockFavoritesBloc();
    when(() => bloc.state).thenReturn(
      initialState ??
          FavoritesState(loading: isLoading, movies: movies, error: ''),
    );
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => bloc.isClosed).thenReturn(false);
    when(() => bloc.close()).thenAnswer((_) async {});
    return bloc;
  }

  /// Creates a mock SearchBloc with initial state
  static SearchBloc createMockSearchBloc({SearchState? initialState}) {
    final bloc = MockSearchBloc();
    when(() => bloc.state).thenReturn(initialState ?? SearchInitial());
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => bloc.isClosed).thenReturn(false);
    when(() => bloc.close()).thenAnswer((_) async {});
    return bloc;
  }

  /// Creates a mock ProfileBloc with initial state
  static ProfileBloc createMockProfileBloc({ProfileState? initialState}) {
    final bloc = MockProfileBloc();
    when(() => bloc.state).thenReturn(initialState ?? const ProfileState());
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => bloc.isClosed).thenReturn(false);
    when(() => bloc.close()).thenAnswer((_) async {});
    return bloc;
  }

  /// Creates a mock SettingsBloc with initial state
  static SettingsBloc createMockSettingsBloc({
    SettingsState? initialState,
    ThemeMode themeMode = ThemeMode.light,
    String languageCode = 'en',
  }) {
    final bloc = MockSettingsBloc();
    when(() => bloc.state).thenReturn(
      initialState ??
          SettingsState(themeMode: themeMode, languageCode: languageCode),
    );
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => bloc.isClosed).thenReturn(false);
    when(() => bloc.close()).thenAnswer((_) async {});
    return bloc;
  }
}

/// Mock BLoC classes
class MockAuthBloc extends Mock implements AuthBloc {}

class MockHomeBloc extends Mock implements HomeBloc {}

class MockMediaCollectionsBloc extends Mock implements MediaCollectionsBloc {}

class MockFavoritesBloc extends Mock implements FavoritesBloc {}

class MockSearchBloc extends Mock implements SearchBloc {}

class MockProfileBloc extends Mock implements ProfileBloc {}

class MockSettingsBloc extends Mock implements SettingsBloc {}
