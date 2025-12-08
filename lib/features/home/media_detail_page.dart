import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/core/constants.dart';
import 'package:project/core/di.dart';
import 'package:project/features/collections/media_collections_cubit.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'home_media_item.dart';
import 'home_repository.dart';
import 'home_page.dart'; // для MediaPosterCard
import 'package:project/core/theme.dart';

class MediaDetailPage extends StatefulWidget {
  final HomeMediaItem item;

  const MediaDetailPage({super.key, required this.item});

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  late final HomeRepository _repository = getIt<HomeRepository>();
  late final MediaCollectionsCubit _collectionsCubit =
      getIt<MediaCollectionsCubit>();

  bool _loading = true;
  String _error = '';
  Map<String, dynamic>? _details;
  List<dynamic> _reviews = [];
  List<HomeMediaItem> _recommendations = [];
  String? _trailerKey;

  YoutubePlayerController? _youtubeController;
  bool _watchRecorded = false;
  StreamSubscription<YoutubePlayerValue>? _playerValueSubscription;

  Future<void> _showAuthDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Потрібна авторизація'),
        content: const Text('Увійдіть, щоб додати до вподобань.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamed(AppConstants.loginRoute);
            },
            child: const Text('Увійти'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _youtubeController?.close();
    _playerValueSubscription?.cancel();
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
        final recs = await _repository.fetchMovieRecommendations(
          widget.item.id,
        );

        trailerKey = _extractTrailerKey(videos);

        setState(() {
          _details = details;
          _reviews = reviews;
          _recommendations = recs
              .map((m) => HomeMediaItem.fromMovie(m))
              .toList();
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
          _recommendations = recs
              .map((t) => HomeMediaItem.fromTvShow(t))
              .toList();
          _trailerKey = trailerKey;
        });
      }

      if (trailerKey != null && trailerKey.isNotEmpty) {
        _youtubeController?.close();
        _youtubeController = YoutubePlayerController.fromVideoId(
          videoId: trailerKey,
          autoPlay: false,
          params: const YoutubePlayerParams(showFullscreenButton: true),
        );
        _playerValueSubscription?.cancel();
        _playerValueSubscription = _youtubeController!.listen(
          _handlePlayerValueChanged,
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
    final colors = theme.colorScheme;
    final title = _details != null
        ? (widget.item.isMovie
              ? (_details!['title'] as String? ?? widget.item.title)
              : (_details!['name'] as String? ?? widget.item.title))
        : widget.item.title;

    return Scaffold(
      backgroundColor: colors.background,
      body: Container(
        decoration: AppGradients.background(context),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
                  ? Center(
                      child: Text(
                        _error,
                        style: TextStyle(color: colors.onBackground),
                      ),
                    )
                  : RefreshIndicator(
                      edgeOffset: 80,
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                              child: Row(
                                children: [
                                  Icon(
                                    widget.item.isMovie ? Icons.movie : Icons.tv,
                                    color: colors.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colors.onBackground,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildFavoriteAction(),
                                ],
                              ),
                            ),
                            _buildHeroSection(),
                            const SizedBox(height: 18),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTrailerSection(),
                                  const SizedBox(height: 18),
                                  _buildOverviewSection(),
                                  const SizedBox(height: 18),
                                  _buildCharacteristics(),
                                  const SizedBox(height: 18),
                                  _buildReviewsSection(),
                                  const SizedBox(height: 18),
                                  _buildRecommendationsSection(),
                                  const SizedBox(height: 30),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final posterPathFromApi = _details != null
        ? _details!['poster_path'] as String?
        : null;
    final posterPath = posterPathFromApi ?? widget.item.posterPath;

    final ratingFromApi = _details != null
        ? (_details!['vote_average'] as num?)?.toDouble()
        : null;
    final rating = ratingFromApi ?? widget.item.rating;

    final title = _details != null
        ? (widget.item.isMovie
              ? (_details!['title'] as String? ?? widget.item.title)
              : (_details!['name'] as String? ?? widget.item.title))
        : widget.item.title;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: posterPath != null && posterPath.isNotEmpty
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w300$posterPath',
                      width: 128,
                      height: 188,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 128,
                      height: 188,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueGrey.shade900,
                            Colors.blueGrey.shade700,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.movie,
                        size: 48,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onBackground,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant.withOpacity(
                            theme.brightness == Brightness.light ? 0.7 : 0.25,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.outlineVariant.withOpacity(0.8),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 6),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (_details != null &&
                          (_details!['vote_count'] as int?) != null)
                        _ChipBadge(
                          icon: Icons.people_outline,
                          label: '${_details!['vote_count']} голосів',
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_details != null)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if ((_details!['original_language'] as String?) != null)
                          _ChipBadge(
                            icon: Icons.language,
                            label:
                                (_details!['original_language'] as String).toUpperCase(),
                          ),
                        if ((_details!['runtime'] as int?) != null)
                          _ChipBadge(
                            icon: Icons.schedule,
                            label: '${_details!['runtime']} хв',
                          ),
                        if ((_details!['number_of_seasons'] as int?) != null)
                          _ChipBadge(
                            icon: Icons.tv,
                            label: 'Сезонів: ${_details!['number_of_seasons']}',
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteAction() {
    final colors = Theme.of(context).colorScheme;
    return BlocBuilder<MediaCollectionsCubit, MediaCollectionsState>(
      bloc: _collectionsCubit,
      builder: (context, state) {
        final isFavorite = state.authorized && state.isFavorite(widget.item);
        return IconButton.filled(
          style: IconButton.styleFrom(
            backgroundColor: colors.surfaceVariant.withOpacity(
              Theme.of(context).brightness == Brightness.light ? 1 : 0.2,
            ),
          ),
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? colors.primary : colors.onSurface,
          ),
          onPressed:
              state.authorized ? () => _collectionsCubit.toggleFavorite(widget.item) : _showAuthDialog,
        );
      },
    );
  }

  Widget _buildTrailerSection() {
    if (_trailerKey == null || _youtubeController == null) {
      // якщо немає робочого трейлера – просто не показуємо секцію
      return const SizedBox.shrink();
    }

    return _Section(
      title: 'Трейлер',
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: YoutubePlayer(controller: _youtubeController!),
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    final colors = Theme.of(context).colorScheme;
    final overview =
        _details != null &&
            (_details!['overview'] as String?)?.isNotEmpty == true
        ? _details!['overview'] as String
        : '';

    return _Section(
      title: 'Опис',
      child: Text(
        overview.isNotEmpty ? overview : 'Опис відсутній',
        style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
      ),
    );
  }

  Widget _buildCharacteristics() {
    if (_details == null) return const SizedBox.shrink();

    final genres =
        (_details!['genres'] as List<dynamic>?)
            ?.map((g) => (g as Map<String, dynamic>)['name'] as String?)
            .whereType<String>()
            .toList() ??
        [];

    final releaseDate = widget.item.isMovie
        ? _details!['release_date'] as String?
        : _details!['first_air_date'] as String?;

    return _Section(
      title: 'Характеристики',
      child: _GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (releaseDate != null && releaseDate.isNotEmpty)
              _buildCharacteristicRow('Дата виходу', releaseDate),
            if (genres.isNotEmpty)
              _buildCharacteristicRow('Жанри', genres.join(', ')),
            if ((_details!['status'] as String?) != null)
              _buildCharacteristicRow('Статус', _details!['status'] as String),
            if ((_details!['vote_count'] as int?) != null)
              _buildCharacteristicRow(
                'Кількість голосів',
                (_details!['vote_count'] as int).toString(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristicRow(String label, String value) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors.onBackground,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    if (_reviews.isEmpty) {
      return _Section(
        title: 'Відгуки',
        child: Text(
          'Ще немає відгуків',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return _Section(
      title: 'Відгуки',
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final review = _reviews[index] as Map<String, dynamic>;
          final author = review['author'] as String? ?? 'Анонім';
          final content = review['content'] as String? ?? '';

          return _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        author,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemCount: _reviews.length,
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    if (_recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<MediaCollectionsCubit, MediaCollectionsState>(
      bloc: _collectionsCubit,
      builder: (context, collectionsState) {
        final canModify = collectionsState.authorized;
        return _Section(
          title: 'Рекомендовані',
          child: SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final item = _recommendations[index];
                return MediaPosterCard(
                  item: item,
                  isFavorite: canModify ? collectionsState.isFavorite(item) : false,
                  onFavoriteToggle:
                      canModify ? () => _collectionsCubit.toggleFavorite(item) : _showAuthDialog,
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
        );
      },
    );
  }

  void _handlePlayerValueChanged(YoutubePlayerValue value) {
    if (_watchRecorded) return;
    if (value.playerState == PlayerState.playing) {
      _collectionsCubit.recordWatch(widget.item);
      _watchRecorded = true;
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colors.onBackground,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.light ? 0.08 : 0.25,
            ),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ChipBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ChipBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(
          theme.brightness == Brightness.light ? 1 : 0.18,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colors.onBackground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
