import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/core/di.dart' as di;
import 'package:project/features/home/domain/entities/video.dart';
import 'package:project/features/home/domain/usecases/get_movie_videos_usecase.dart';
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
  });

  final int movieId;

  @override
  ConsumerState<MovieTrailerPlayer> createState() => _MovieTrailerPlayerState();
}

class _MovieTrailerPlayerState extends ConsumerState<MovieTrailerPlayer> {
  YoutubePlayerController? _controller;
  String? _currentVideoKey;

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  void _initializePlayer(String videoKey) {
    if (_currentVideoKey == videoKey && _controller != null) {
      return;
    }

    if (kDebugMode) {
      debugPrint('MovieTrailerPlayer: Ініціалізація плеєра з ключем: "$videoKey"');
    }
    
    _controller?.close();
    _currentVideoKey = videoKey;
    
    try {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoKey,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          enableCaption: true,
          mute: false,
          loop: false,
          enableJavaScript: true,
          playsInline: true,
        ),
      );
      
      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('MovieTrailerPlayer: Помилка ініціалізації плеєра: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      _currentVideoKey = null;
      _controller = null;
      if (mounted) {
        setState(() {});
      }
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

        Video? trailer;

        // 1. Шукаємо офіційні Trailer
        final officialTrailers = videos.where((video) {
          return video.site == 'YouTube' && 
                 video.key.isNotEmpty &&
                 video.type.toLowerCase().trim() == 'trailer' &&
                 video.official;
        }).toList();
        
        if (kDebugMode) {
          debugPrint('MovieTrailerPlayer: Знайдено ${officialTrailers.length} офіційних трейлерів');
        }
        
        if (officialTrailers.isNotEmpty) {
          trailer = officialTrailers.first;
        } else {
          // 2. Шукаємо будь-які Trailer
          final anyTrailers = videos.where((video) =>
            video.site == 'YouTube' &&
            video.key.isNotEmpty &&
            video.type.toLowerCase().trim() == 'trailer'
          ).toList();
          
          if (anyTrailers.isNotEmpty) {
            trailer = anyTrailers.first;
          } else {
            // 3. Шукаємо офіційні Teaser
            final officialTeasers = videos.where((video) =>
              video.site == 'YouTube' &&
              video.key.isNotEmpty &&
              video.type.toLowerCase().trim() == 'teaser' &&
              video.official
            ).toList();
            
            if (officialTeasers.isNotEmpty) {
              trailer = officialTeasers.first;
            } else {
              // 4. Шукаємо будь-які Teaser
              final anyTeasers = videos.where((video) =>
                video.site == 'YouTube' &&
                video.key.isNotEmpty &&
                video.type.toLowerCase().trim() == 'teaser'
              ).toList();
              
              if (anyTeasers.isNotEmpty) {
                trailer = anyTeasers.first;
              } else {
                // 5. Беремо будь-яке YouTube відео
                final anyYouTube = videos.where((video) =>
                  video.site == 'YouTube' && video.key.isNotEmpty
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
        
        // Ініціалізуємо або оновлюємо контролер, якщо потрібно
        if (_currentVideoKey != videoKey) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _currentVideoKey != videoKey) {
              _initializePlayer(videoKey);
            }
          });
        }

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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _controller != null
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
                  'Трейлер недоступний',
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

