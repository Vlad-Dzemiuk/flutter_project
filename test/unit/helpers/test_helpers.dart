import 'package:mocktail/mocktail.dart';
import 'package:project/features/auth/auth_repository.dart';
import 'package:project/features/home/home_repository.dart';
import 'package:project/features/collections/domain/repositories/media_collections_repository.dart';
import 'package:project/features/search/domain/repositories/search_repository.dart';
import 'package:project/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:project/features/profile/domain/repositories/profile_repository.dart';
import 'package:project/core/auth/firebase_auth_service.dart';
import 'package:project/core/auth/jwt_token_service.dart';
import 'package:project/core/storage/secure_storage_service.dart';
import 'package:project/features/home/domain/usecases/search_media_usecase.dart';
import 'package:project/features/home/domain/usecases/get_popular_content_usecase.dart';
import 'package:project/features/home/domain/usecases/get_movie_details_usecase.dart';
import 'package:project/features/home/domain/usecases/get_tv_details_usecase.dart';
import 'package:project/features/home/domain/usecases/get_movie_videos_usecase.dart';
import 'package:project/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:project/features/auth/data/models/local_user.dart';
import 'package:project/features/home/data/models/movie_model.dart';
import 'package:project/features/home/data/models/tv_show_model.dart';
import 'package:project/features/home/home_media_item.dart';
import 'package:project/features/collections/media_collection_entry.dart';

/// Mock classes for testing
class MockAuthRepository extends Mock implements AuthRepository {}

class MockHomeRepository extends Mock implements HomeRepository {}

class MockMediaCollectionsRepository extends Mock
    implements MediaCollectionsRepository {}

class MockSearchRepository extends Mock implements SearchRepository {}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

class MockJwtTokenService extends Mock implements JwtTokenService {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockSearchMediaUseCase extends Mock implements SearchMediaUseCase {}

class MockGetPopularContentUseCase extends Mock
    implements GetPopularContentUseCase {}

class MockGetMovieDetailsUseCase extends Mock
    implements GetMovieDetailsUseCase {}

class MockGetTvDetailsUseCase extends Mock implements GetTvDetailsUseCase {}

class MockGetMovieVideosUseCase extends Mock implements GetMovieVideosUseCase {}

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

/// Test data factories
class TestDataFactory {
  static LocalUser createLocalUser({
    int? id,
    String? email,
    String? displayName,
    String? avatarUrl,
  }) {
    return LocalUser(
      id: id ?? 1,
      email: email ?? 'test@example.com',
      displayName: displayName ?? 'Test User',
      avatarUrl: avatarUrl,
    );
  }

  static Movie createMovie({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    double? voteAverage,
  }) {
    return Movie(
      id: id ?? 1,
      title: title ?? 'Test Movie',
      overview: overview ?? 'Test overview',
      posterPath: posterPath ?? '/poster.jpg',
      voteAverage: voteAverage ?? 8.5,
    );
  }

  static TvShow createTvShow({
    int? id,
    String? name,
    String? overview,
    String? posterPath,
    double? voteAverage,
  }) {
    return TvShow(
      id: id ?? 1,
      name: name ?? 'Test TV Show',
      overview: overview ?? 'Test overview',
      posterPath: posterPath ?? '/poster.jpg',
      voteAverage: voteAverage ?? 8.5,
    );
  }

  static HomeMediaItem createHomeMediaItem({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    double? rating,
    bool? isMovie,
  }) {
    return HomeMediaItem(
      id: id ?? 1,
      title: title ?? 'Test Media',
      overview: overview ?? 'Test overview',
      posterPath: posterPath ?? '/poster.jpg',
      rating: rating ?? 8.5,
      isMovie: isMovie ?? true,
    );
  }

  static MediaCollectionEntry createMediaCollectionEntry({
    String? key,
    int? mediaId,
    bool? isMovie,
    String? title,
    String? overview,
    String? posterPath,
    double? rating,
    DateTime? updatedAt,
  }) {
    return MediaCollectionEntry(
      key: key ?? 'movie_1',
      mediaId: mediaId ?? 1,
      isMovie: isMovie ?? true,
      title: title ?? 'Test Media',
      overview: overview ?? 'Test overview',
      posterPath: posterPath ?? '/poster.jpg',
      rating: rating ?? 8.5,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
