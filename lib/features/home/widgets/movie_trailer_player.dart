import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:project/core/di.dart' as di;
import 'package:project/core/storage/local_cache_db.dart';
import 'package:project/features/home/domain/entities/video.dart';
import 'package:project/features/home/domain/usecases/get_movie_videos_usecase.dart';
import 'package:project/features/home/home_media_item.dart';
import 'package:project/features/collections/media_collections_bloc.dart';
import 'package:project/features/collections/media_collections_event.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Provider для відео фільму
final movieVideosProvider =
    FutureProvider.family<List<Video>, int>((ref, movieId) async {
  try {
    if (kDebugMode) {
      debugPrint('movieVideosProvider: Завантаження відео для фільму $movieId');
    }
    final getMovieVideos = di.getIt<GetMovieVideosUseCase>();
    final result = await getMovieVideos(GetMovieVideosParams(movieId: movieId));
    if (kDebugMode) {
      debugPrint('movieVideosProvider: Отримано ${result.length} відео');
    }
    return result;
  } catch (e, stack) {
    if (kDebugMode) {
      debugPrint('movieVideosProvider: Помилка - $e');
      debugPrint('Stack: $stack');
    }
    rethrow;
  }
});

/// Віджет для відтворення трейлерів фільмів/серіалів
class MovieTrailerPlayer extends ConsumerStatefulWidget {
  const MovieTrailerPlayer({
    super.key,
    required this.movieId,
    this.mediaItem,
  });

  final int movieId;
  final HomeMediaItem? mediaItem;

  @override
  ConsumerState<MovieTrailerPlayer> createState() => _MovieTrailerPlayerState();
}

class _MovieTrailerPlayerState extends ConsumerState<MovieTrailerPlayer> {
  YoutubePlayerController? _controller;
  String? _currentVideoKey;
  bool _hasVideoError = false;
  String? _errorMessage; // Повідомлення про помилку для відображення
  StreamSubscription<YoutubePlayerValue>? _playerValueSubscription;
  final Set<String> _failedVideoKeys = {}; // Список ключів, які не вдалося відтворити
  bool _isClearingCache = false; // Прапорець для запобігання подвійного очищення
  bool _watchRecorded = false; // Прапорець для запобігання подвійного додавання до watchlist
  late final MediaCollectionsBloc _collectionsBloc = di.getIt<MediaCollectionsBloc>();

  @override
  void dispose() {
    _playerValueSubscription?.cancel();
    _controller?.close();
    _failedVideoKeys.clear();
    super.dispose();
  }

  @override
  void didUpdateWidget(MovieTrailerPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Очищаємо список невдалих ключів при зміні фільму
    if (oldWidget.movieId != widget.movieId) {
      _failedVideoKeys.clear();
      _currentVideoKey = null;
      _hasVideoError = false;
      _errorMessage = null;
      _watchRecorded = false; // Скидаємо прапорець при зміні фільму
    }
  }

  /// Витягує video ID з різних форматів YouTube URL
  /// Підтримує формати:
  /// - https://www.youtube.com/embed/VIDEO_ID
  /// - https://www.youtube.com/watch?v=VIDEO_ID
  /// - https://youtu.be/VIDEO_ID
  /// - VIDEO_ID (якщо вже є ID)
  String _extractVideoId(String key) {
    if (key.isEmpty) return key;
    
    // Якщо це вже просто ID (без URL), повертаємо як є
    if (!key.contains('http') && !key.contains('youtube') && !key.contains('youtu.be')) {
      return key;
    }
    
    // Обробка embed URL: https://www.youtube.com/embed/VIDEO_ID
    final embedMatch = RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]+)').firstMatch(key);
    if (embedMatch != null) {
      return embedMatch.group(1)!;
    }
    
    // Обробка watch URL: https://www.youtube.com/watch?v=VIDEO_ID
    final watchMatch = RegExp(r'[?&]v=([a-zA-Z0-9_-]+)').firstMatch(key);
    if (watchMatch != null) {
      return watchMatch.group(1)!;
    }
    
    // Обробка youtu.be URL: https://youtu.be/VIDEO_ID
    final shortMatch = RegExp(r'youtu\.be/([a-zA-Z0-9_-]+)').firstMatch(key);
    if (shortMatch != null) {
      return shortMatch.group(1)!;
    }
    
    // Спробуємо використати вбудований метод, якщо він доступний
    try {
      final convertedId = YoutubePlayerController.convertUrlToId(key);
      if (convertedId != null && convertedId.isNotEmpty) {
        return convertedId;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('MovieTrailerPlayer: Помилка конвертації URL через convertUrlToId: $e');
      }
    }
    
    // Якщо нічого не спрацювало, повертаємо оригінальний ключ
    // (можливо це вже ID)
    if (kDebugMode) {
      debugPrint('MovieTrailerPlayer: Не вдалося витягти video ID з: "$key", використовуємо як є');
    }
    return key;
  }

  void _initializePlayer(String videoKey) {
    if (_currentVideoKey == videoKey && _controller != null && !_hasVideoError) {
      return;
    }

    if (kDebugMode) {
      debugPrint('MovieTrailerPlayer: Ініціалізація плеєра з ключем: "$videoKey"');
    }
    
    // Витягуємо video ID з ключа (якщо це URL)
    final extractedVideoId = _extractVideoId(videoKey);
    
    if (kDebugMode && extractedVideoId != videoKey) {
      debugPrint('MovieTrailerPlayer: Витягнуто video ID: "$extractedVideoId" з ключа: "$videoKey"');
    }
    
    // Скасовуємо попередню підписку
    _playerValueSubscription?.cancel();
    _controller?.close();
    
    _currentVideoKey = videoKey;
    _hasVideoError = false;
    _errorMessage = null;
    
    try {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: extractedVideoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          enableCaption: true,
          mute: false,
          loop: false,
          enableJavaScript: true,
          playsInline: true,
          origin: 'https://www.youtube-nocookie.com',
        ),
      );
      
      // Додаємо fallback обробку помилок через listen
      _playerValueSubscription = _controller!.listen((value) {
        // Відстежуємо запуск відео для додавання до watchlist
        if (!_watchRecorded && 
            value.playerState == PlayerState.playing && 
            widget.mediaItem != null) {
          _handleVideoPlaybackStarted();
        }
        
        // Обробляємо помилки (YoutubeError.none - це нормальний стан, не помилка)
        if (value.error != YoutubeError.none) {
          // Визначаємо повідомлення про помилку в залежності від типу помилки
          String errorMsg = _getErrorMessage(context, value.error);
          
          if (kDebugMode) {
            debugPrint('MovieTrailerPlayer: Помилка відтворення відео - ${value.error}');
            debugPrint('MovieTrailerPlayer: Повідомлення про помилку: $errorMsg');
          }
          
          // Додаємо ключ до списку невдалих спроб
          if (videoKey.isNotEmpty && !_failedVideoKeys.contains(videoKey)) {
            _failedVideoKeys.add(videoKey);
            
            // Очищаємо кеш відео при помилці відтворення (відео може бути видалене)
            // Виконуємо з невеликою затримкою, щоб уникнути занадто частих перезавантажень
            if (!_isClearingCache) {
              _isClearingCache = true;
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  _clearVideoCacheAndInvalidate();
                  _isClearingCache = false;
                }
              });
            }
          }
          
          // Показуємо повідомлення про недоступність відео
          if (mounted) {
            setState(() {
              _hasVideoError = true;
              _errorMessage = errorMsg;
            });
          }
        } else if (value.error == YoutubeError.none && _hasVideoError) {
          // Якщо помилка зникла, скидаємо стан помилки
          if (mounted) {
            setState(() {
              _hasVideoError = false;
              _errorMessage = null;
            });
          }
        }
      });
      
      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('MovieTrailerPlayer: Помилка ініціалізації плеєра: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      
      // Очищаємо кеш відео при помилці ініціалізації
      if (videoKey.isNotEmpty) {
        _failedVideoKeys.add(videoKey);
      }
      _clearVideoCacheAndInvalidate();
      
      _currentVideoKey = null;
      _controller = null;
      _hasVideoError = true;
      _errorMessage = 'Не вдалося ініціалізувати плеєр';
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Обробляє запуск відтворення відео - додає фільм/серіал до watchlist
  void _handleVideoPlaybackStarted() {
    if (_watchRecorded || widget.mediaItem == null) return;
    
    // Перевіряємо чи користувач авторизований
    final currentState = _collectionsBloc.state;
    if (!currentState.authorized) {
      if (kDebugMode) {
        debugPrint('MovieTrailerPlayer: Користувач не авторизований, пропускаємо додавання до watchlist');
      }
      return;
    }
    
    _watchRecorded = true;
    
    if (kDebugMode) {
      debugPrint('MovieTrailerPlayer: Відео почало відтворюватися, додаємо до watchlist: ${widget.mediaItem!.title}');
    }
    
    // Додаємо фільм/серіал до watchlist через RecordWatchEvent
    _collectionsBloc.add(RecordWatchEvent(widget.mediaItem!));
  }

  /// Отримує зрозуміле повідомлення про помилку на основі типу помилки YouTube
  String _getErrorMessage(BuildContext context, YoutubeError error) {
    final l10n = AppLocalizations.of(context)!;
    // Використовуємо тільки існуючі значення enum YoutubeError
    // Доступні значення: none, unknown, videoNotFound, html5Error
    if (error == YoutubeError.none) {
      return '';
    } else if (error == YoutubeError.videoNotFound) {
      return l10n.videoUnavailable;
    } else if (error == YoutubeError.unknown) {
      return l10n.videoUnavailable;
    } else {
      // Для будь-яких інших помилок (наприклад, html5Error якщо існує)
      // показуємо загальне повідомлення
      return l10n.videoUnavailable;
    }
  }

  /// Очищає кеш відео для поточного фільму при помилці відтворення
  /// та інвалідує provider для завантаження свіжих даних
  Future<void> _clearVideoCacheAndInvalidate() async {
    try {
      final cacheKey = 'movie_videos_${widget.movieId}';
      await LocalCacheDb.instance.deleteJson(cacheKey);
      if (kDebugMode) {
        debugPrint('MovieTrailerPlayer: Очищено кеш відео для фільму ${widget.movieId}');
      }
      
      // Інвалідуємо provider, щоб завантажити свіжі дані
      if (mounted) {
        ref.invalidate(movieVideosProvider(widget.movieId));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('MovieTrailerPlayer: Помилка очищення кешу: $e');
      }
    } finally {
      _isClearingCache = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final videosAsync = ref.watch(movieVideosProvider(widget.movieId));

    return videosAsync.when(
      data: (videos) {
        if (kDebugMode) {
          debugPrint('MovieTrailerPlayer: Отримано ${videos.length} відео');
        }

        // Пріоритет вибору:
        // 1. Офіційні Trailer
        // 2. Будь-які Trailer
        // 3. Офіційні Teaser
        // 4. Будь-які Teaser
        // 5. Будь-які YouTube відео
        // Всі варіанти фільтруються, щоб виключити вже спробовані (недоступні) ключі

        Video? trailer;

        // 1. Шукаємо офіційні Trailer (виключаючи невдалі ключі)
        final officialTrailers = videos.where((video) {
          return video.site == 'YouTube' && 
                 video.key.isNotEmpty &&
                 video.type.toLowerCase().trim() == 'trailer' &&
                 video.official &&
                 !_failedVideoKeys.contains(video.key.trim());
        }).toList();
        
        if (kDebugMode) {
          debugPrint('MovieTrailerPlayer: Знайдено ${officialTrailers.length} офіційних трейлерів (виключено ${_failedVideoKeys.length} невдалих)');
        }
        
        if (officialTrailers.isNotEmpty) {
          trailer = officialTrailers.first;
        } else {
          // 2. Шукаємо будь-які Trailer (виключаючи невдалі ключі)
          final anyTrailers = videos.where((video) =>
            video.site == 'YouTube' &&
            video.key.isNotEmpty &&
            video.type.toLowerCase().trim() == 'trailer' &&
            !_failedVideoKeys.contains(video.key.trim())
          ).toList();
          
          if (anyTrailers.isNotEmpty) {
            trailer = anyTrailers.first;
          } else {
            // 3. Шукаємо офіційні Teaser (виключаючи невдалі ключі)
            final officialTeasers = videos.where((video) =>
              video.site == 'YouTube' &&
              video.key.isNotEmpty &&
              video.type.toLowerCase().trim() == 'teaser' &&
              video.official &&
              !_failedVideoKeys.contains(video.key.trim())
            ).toList();
            
            if (officialTeasers.isNotEmpty) {
              trailer = officialTeasers.first;
            } else {
              // 4. Шукаємо будь-які Teaser (виключаючи невдалі ключі)
              final anyTeasers = videos.where((video) =>
                video.site == 'YouTube' &&
                video.key.isNotEmpty &&
                video.type.toLowerCase().trim() == 'teaser' &&
                !_failedVideoKeys.contains(video.key.trim())
              ).toList();
              
              if (anyTeasers.isNotEmpty) {
                trailer = anyTeasers.first;
              } else {
                // 5. Беремо будь-яке YouTube відео (виключаючи невдалі ключі)
                final anyYouTube = videos.where((video) =>
                  video.site == 'YouTube' && 
                  video.key.isNotEmpty &&
                  !_failedVideoKeys.contains(video.key.trim())
                ).toList();
                if (anyYouTube.isNotEmpty) {
                  trailer = anyYouTube.first;
                }
              }
            }
          }
        }

        if (trailer == null || trailer.key.isEmpty) {
          if (kDebugMode) {
            debugPrint('MovieTrailerPlayer: Немає доступних YouTube відео. Всього відео: ${videos.length}');
          }
          return _buildNoTrailerWidget(context);
        }

        if (kDebugMode) {
          debugPrint('MovieTrailerPlayer: Вибрано відео - key: "${trailer.key}", name: "${trailer.name}", type: "${trailer.type}"');
        }

        // Ініціалізуємо контролер
        final videoKey = trailer.key.trim();
        
        // Перевіряємо валідність ключа
        if (videoKey.isEmpty) {
          return _buildNoTrailerWidget(context);
        }
        
        // Ініціалізуємо або оновлюємо контролер синхронно
        // Якщо ключ змінився - переініціалізуємо
        if (_currentVideoKey != videoKey) {
          // Якщо вибрано нове відео (не те, що було з помилкою), скидаємо помилку
          _hasVideoError = false;
          _errorMessage = null;
          _initializePlayer(videoKey);
        } else if (_hasVideoError && _controller == null) {
          // Якщо є помилка і контролер не створено, спробуємо переініціалізувати
          _hasVideoError = false;
          _errorMessage = null;
          _initializePlayer(videoKey);
        }

        // Якщо є помилка після ініціалізації і контролер не створено, показуємо віджет помилки
        if (_hasVideoError && _controller == null) {
          return _buildNoTrailerWidget(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.trailer,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _hasVideoError
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage ?? AppLocalizations.of(context)!.videoUnavailable,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              if (_failedVideoKeys.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  AppLocalizations.of(context)!.tryingToFindAnotherVideo,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[500],
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    : _controller != null
                        ? YoutubePlayer(
                            controller: _controller!,
                            aspectRatio: 16 / 9,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              trailer.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Трейлер',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
      error: (error, stack) {
        if (kDebugMode) {
          debugPrint('MovieTrailerPlayer: Помилка завантаження відео - $error');
          debugPrint('Stack trace: $stack');
        }
        return _buildNoTrailerWidget(context);
      },
    );
  }

  Widget _buildNoTrailerWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Трейлер',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.video_library_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.trailerUnavailable,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

