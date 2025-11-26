import 'package:flutter/material.dart';
import 'package:project/core/di.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'home_media_item.dart';
import 'home_repository.dart';
import 'home_page.dart'; // для MediaPosterCard

class MediaDetailPage extends StatefulWidget {
  final HomeMediaItem item;

  const MediaDetailPage({super.key, required this.item});

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  late final HomeRepository _repository = getIt<HomeRepository>();

  bool _loading = true;
  String _error = '';
  Map<String, dynamic>? _details;
  List<dynamic> _reviews = [];
  List<HomeMediaItem> _recommendations = [];
  String? _trailerKey;

  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _youtubeController?.close();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      String? trailerKey;

      if (widget.item.isMovie) {
        final details = await _repository.fetchMovieDetails(widget.item.id);
        final videos = await _repository.fetchMovieVideos(widget.item.id);
        final reviews = await _repository.fetchMovieReviews(widget.item.id);
        final recs = await _repository.fetchMovieRecommendations(widget.item.id);

        trailerKey = _extractTrailerKey(videos);

        setState(() {
          _details = details;
          _reviews = reviews;
          _recommendations =
              recs.map((m) => HomeMediaItem.fromMovie(m)).toList();
          _trailerKey = trailerKey;
        });
      } else {
        final details = await _repository.fetchTvDetails(widget.item.id);
        final videos = await _repository.fetchTvVideos(widget.item.id);
        final reviews = await _repository.fetchTvReviews(widget.item.id);
        final recs = await _repository.fetchTvRecommendations(widget.item.id);

        trailerKey = _extractTrailerKey(videos);

        setState(() {
          _details = details;
          _reviews = reviews;
          _recommendations =
              recs.map((t) => HomeMediaItem.fromTvShow(t)).toList();
          _trailerKey = trailerKey;
        });
      }

      if (trailerKey != null && trailerKey.isNotEmpty) {
        _youtubeController?.close();
        _youtubeController = YoutubePlayerController.fromVideoId(
          videoId: trailerKey,
          autoPlay: false,
          params: const YoutubePlayerParams(
            showFullscreenButton: true,
          ),
        );
      }

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String? _extractTrailerKey(List<dynamic> videos) {
    // Беремо перше доступне YouTube-відео (незалежно від типу),
    // щоб максимізувати шанси, що щось відтвориться.
    for (final v in videos) {
      final map = v as Map<String, dynamic>;
      final site = map['site'] as String?;
      if (site != 'YouTube') continue;
      final key = map['key'] as String?;
      if (key != null && key.isNotEmpty) {
        return key;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _details != null
        ? (widget.item.isMovie
            ? (_details!['title'] as String? ?? widget.item.title)
            : (_details!['name'] as String? ?? widget.item.title))
        : widget.item.title;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(theme),
                          const SizedBox(height: 16),
                          _buildTrailerSection(theme),
                          const SizedBox(height: 24),
                          _buildOverviewSection(theme),
                          const SizedBox(height: 24),
                          _buildCharacteristics(theme),
                          const SizedBox(height: 24),
                          _buildReviewsSection(theme),
                          const SizedBox(height: 24),
                          _buildRecommendationsSection(theme),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final posterPathFromApi = _details != null
        ? _details!['poster_path'] as String?
        : null;
    final posterPath = posterPathFromApi ?? widget.item.posterPath;

    final ratingFromApi =
        _details != null ? (_details!['vote_average'] as num?)?.toDouble() : null;
    final rating = ratingFromApi ?? widget.item.rating;

    final title = _details != null
        ? (widget.item.isMovie
            ? (_details!['title'] as String? ?? widget.item.title)
            : (_details!['name'] as String? ?? widget.item.title))
        : widget.item.title;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: posterPath != null && posterPath.isNotEmpty
              ? Image.network(
                  'https://image.tmdb.org/t/p/w300$posterPath',
                  width: 120,
                  height: 180,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 120,
                  height: 180,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.movie, size: 48),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, size: 18, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_details != null)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if ((_details!['original_language'] as String?) != null)
                      Chip(
                        label: Text(
                          'Мова: ${(_details!['original_language'] as String).toUpperCase()}',
                        ),
                      ),
                    if ((_details!['runtime'] as int?) != null)
                      Chip(
                        label: Text(
                            'Тривалість: ${_details!['runtime']} хв'),
                      ),
                    if ((_details!['number_of_seasons'] as int?) != null)
                      Chip(
                        label: Text(
                            'Сезонів: ${_details!['number_of_seasons']}'),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrailerSection(ThemeData theme) {
    if (_trailerKey == null || _youtubeController == null) {
      // якщо немає робочого трейлера – просто не показуємо секцію
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Трейлер',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(controller: _youtubeController!),
        ),
      ],
    );
  }

  Widget _buildOverviewSection(ThemeData theme) {
    final overview =
        _details != null && (_details!['overview'] as String?)?.isNotEmpty == true
            ? _details!['overview'] as String
            : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Опис',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          overview.isNotEmpty ? overview : 'Опис відсутній',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildCharacteristics(ThemeData theme) {
    if (_details == null) return const SizedBox.shrink();

    final genres = (_details!['genres'] as List<dynamic>?)
            ?.map((g) => (g as Map<String, dynamic>)['name'] as String?)
            .whereType<String>()
            .toList() ??
        [];

    final releaseDate = widget.item.isMovie
        ? _details!['release_date'] as String?
        : _details!['first_air_date'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Характеристики',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (releaseDate != null && releaseDate.isNotEmpty)
                  _buildCharacteristicRow('Дата виходу', releaseDate),
                if (genres.isNotEmpty)
                  _buildCharacteristicRow(
                      'Жанри', genres.join(', ')),
                if ((_details!['status'] as String?) != null)
                  _buildCharacteristicRow(
                      'Статус', _details!['status'] as String),
                if ((_details!['vote_count'] as int?) != null)
                  _buildCharacteristicRow(
                      'Кількість голосів',
                      (_details!['vote_count'] as int).toString()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCharacteristicRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(ThemeData theme) {
    if (_reviews.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Відгуки',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text('Ще немає відгуків'),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Відгуки',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final review = _reviews[index] as Map<String, dynamic>;
            final author = review['author'] as String? ?? 'Анонім';
            final content = review['content'] as String? ?? '';

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: _reviews.length,
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection(ThemeData theme) {
    if (_recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Рекомендовані',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final item = _recommendations[index];
              return MediaPosterCard(
                item: item,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MediaDetailPage(item: item),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: _recommendations.length,
          ),
        ),
      ],
    );
  }
}


