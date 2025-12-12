import 'package:get_it/get_it.dart';
import '../features/home/home_repository.dart';
import '../features/home/home_api_service.dart';
import '../features/auth/auth_repository.dart';
import '../features/auth/auth_bloc.dart';
import '../features/collections/media_collections_bloc.dart';
import '../features/collections/domain/repositories/media_collections_repository.dart';
import '../features/home/home_bloc.dart';
import '../features/search/search_bloc.dart';
import '../features/favorites/favorites_bloc.dart';
import '../core/storage/media_collections_storage.dart';
import '../core/loading_state.dart';
// Repositories (domain interfaces)
import '../features/search/domain/repositories/search_repository.dart';
import '../features/favorites/domain/repositories/favorites_repository.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
// Repositories (data implementations)
import '../features/search/data/repositories/search_repository_impl.dart';
import '../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
// Use Cases
import '../features/home/domain/usecases/get_popular_content_usecase.dart';
import '../features/home/domain/usecases/search_media_usecase.dart';
import '../features/home/domain/usecases/get_movie_details_usecase.dart';
import '../features/home/domain/usecases/get_movie_videos_usecase.dart';
import '../features/home/domain/usecases/get_tv_details_usecase.dart';
import '../features/home/domain/usecases/search_by_name_usecase.dart';
import '../features/auth/domain/usecases/sign_in_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/profile/domain/usecases/update_profile_usecase.dart';
import '../features/profile/domain/usecases/get_user_profile_usecase.dart';
import '../features/favorites/domain/usecases/get_favorites_usecase.dart';
import '../features/collections/domain/usecases/get_media_collections_usecase.dart';
import '../features/collections/domain/usecases/toggle_favorite_usecase.dart';
import '../features/collections/domain/usecases/add_to_watchlist_usecase.dart';
import '../features/search/domain/usecases/search_by_filters_usecase.dart';
import '../features/settings/settings_bloc.dart';
import '../features/profile/profile_bloc.dart';
import '../core/storage/auth_db.dart';
import '../core/storage/local_cache_db.dart';
import '../core/storage/user_prefs.dart';
import '../core/network/dio_client.dart';
import '../core/auth/firebase_auth_service.dart';
import '../core/auth/jwt_token_service.dart';
import '../core/auth/auth_method.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Initialize databases
  // Initialize Drift database for auth
  await AuthDb.instance.database.then((db) => db.ensureInitialized());
  // Initialize Drift database for cache
  await LocalCacheDb.instance.database.then((db) => db.ensureInitialized());
  // Initialize Hive for user preferences
  await UserPrefs.instance.init();
  // Initialize Drift database for media collections
  await MediaCollectionsStorage.instance.database.then((db) => db.ensureInitialized());
  
  // Auth Services
  getIt.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());
  getIt.registerLazySingleton<JwtTokenService>(() => JwtTokenService.instance);
  
  // Determine auth method from environment or use default (local)
  // Можна встановити AUTH_METHOD в .env файлі: local, firebase, jwt
  final authMethodString = dotenv.env['AUTH_METHOD']?.toLowerCase() ?? 'local';
  AuthMethod authMethod;
  switch (authMethodString) {
    case 'firebase':
      authMethod = AuthMethod.firebase;
      break;
    case 'jwt':
      authMethod = AuthMethod.jwt;
      break;
    case 'local':
    default:
      authMethod = AuthMethod.local;
      break;
  }
  
  // Repositories (must be registered before DioClient to pass AuthRepository)
  final authRepository = AuthRepository(
    authMethod: authMethod,
    firebaseAuthService: getIt<FirebaseAuthService>(),
    jwtTokenService: getIt<JwtTokenService>(),
  );
  
  // Ініціалізуємо AuthRepository (перевіряє збережений стан)
  await authRepository.initialize();
  
  getIt.registerLazySingleton<AuthRepository>(() => authRepository);
  
  // HTTP Client (with AuthRepository for auth headers)
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(authRepository: getIt<AuthRepository>()),
  );
  
  // API Services
  final homeApiService = HomeApiService();
  getIt.registerLazySingleton<HomeApiService>(() => homeApiService);

  // Repositories
  getIt.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl());
  getIt.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(homeApiService),
  );
  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(),
  );
  getIt.registerLazySingleton<MediaCollectionsRepository>(
    () => MediaCollectionsRepository(MediaCollectionsStorage.instance),
  );
  getIt.registerLazySingleton<MediaCollectionsBloc>(
    () => MediaCollectionsBloc(
      getMediaCollectionsUseCase: getIt<GetMediaCollectionsUseCase>(),
      toggleFavoriteUseCase: getIt<ToggleFavoriteUseCase>(),
      addToWatchlistUseCase: getIt<AddToWatchlistUseCase>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );

  // Services
  getIt.registerLazySingleton<LoadingStateService>(() => LoadingStateService());

  // Use Cases
  getIt.registerFactory<GetPopularContentUseCase>(
    () => GetPopularContentUseCase(getIt<HomeRepository>()),
  );
  getIt.registerFactory<SearchMediaUseCase>(
    () => SearchMediaUseCase(getIt<HomeRepository>()),
  );
  getIt.registerFactory<GetMovieDetailsUseCase>(
    () => GetMovieDetailsUseCase(getIt<HomeRepository>()),
  );
  getIt.registerFactory<GetMovieVideosUseCase>(
    () => GetMovieVideosUseCase(getIt<HomeRepository>()),
  );
  getIt.registerFactory<GetTvDetailsUseCase>(
    () => GetTvDetailsUseCase(getIt<HomeRepository>()),
  );
  getIt.registerFactory<SearchByNameUseCase>(
    () => SearchByNameUseCase(getIt<HomeRepository>()),
  );
  getIt.registerFactory<SignInUseCase>(
    () => SignInUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<RegisterUseCase>(
    () => RegisterUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<GetUserProfileUseCase>(
    () => GetUserProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerFactory<GetFavoritesUseCase>(
    () => GetFavoritesUseCase(getIt<FavoritesRepository>()),
  );
  getIt.registerFactory<GetMediaCollectionsUseCase>(
    () => GetMediaCollectionsUseCase(getIt<MediaCollectionsRepository>()),
  );
  getIt.registerFactory<ToggleFavoriteUseCase>(
    () => ToggleFavoriteUseCase(getIt<MediaCollectionsRepository>()),
  );
  getIt.registerFactory<AddToWatchlistUseCase>(
    () => AddToWatchlistUseCase(getIt<MediaCollectionsRepository>()),
  );
  getIt.registerFactory<SearchByFiltersUseCase>(
    () => SearchByFiltersUseCase(getIt<SearchRepository>()),
  );

  // BLoCs / Cubits
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      getPopularContentUseCase: getIt<GetPopularContentUseCase>(),
      searchMediaUseCase: getIt<SearchMediaUseCase>(),
    ),
  );
  // Global state для auth, favorites, settings
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      repository: getIt<AuthRepository>(),
      signInUseCase: getIt<SignInUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
    ),
  );
  getIt.registerLazySingleton<FavoritesBloc>(
    () => FavoritesBloc(
      getFavoritesUseCase: getIt<GetFavoritesUseCase>(),
    ),
  );
  getIt.registerFactory<SearchBloc>(
    () => SearchBloc(
      searchByFiltersUseCase: getIt<SearchByFiltersUseCase>(),
    ),
  );
  getIt.registerLazySingleton<SettingsBloc>(
    () => SettingsBloc(),
  );
  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getUserProfileUseCase: getIt<GetUserProfileUseCase>(),
    ),
  );
}
