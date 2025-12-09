import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/core/constants.dart';
import 'package:project/core/di.dart';
import 'package:project/features/collections/media_collections_bloc.dart';
import 'package:project/features/collections/media_collections_event.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'home_media_item.dart';
import 'home_repository.dart';
import 'domain/usecases/get_movie_details_usecase.dart';
import 'domain/usecases/get_tv_details_usecase.dart';
import 'data/models/movie_model.dart';
import 'data/models/tv_show_model.dart';
import 'home_page.dart'; // для MediaPosterCard
import 'package:project/core/responsive.dart';
import 'package:project/core/theme.dart';
import 'package:project/core/page_transitions.dart';
import 'package:project/shared/widgets/animated_loading_widget.dart';
import 'package:project/shared/widgets/auth_dialog.dart';

class MediaDetailPage extends StatefulWidget {
  final HomeMediaItem item;

  const MediaDetailPage({super.key, required this.item});

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  late final GetMovieDetailsUseCase _getMovieDetailsUseCase =
      getIt<GetMovieDetailsUseCase>();
  late final GetTvDetailsUseCase _getTvDetailsUseCase =
      getIt<GetTvDetailsUseCase>();
  late final MediaCollectionsBloc _collectionsBloc =
      getIt<MediaCollectionsBloc>();

  bool _loading = true;
  String _error = '';
  Map<String, dynamic>? _details;
  List<dynamic> _reviews = [];
  List<HomeMediaItem> _recommendations = [];
  bool _loadingRecommendations = false;
  String? _trailerKey;

  YoutubePlayerController? _youtubeController;
  bool _watchRecorded = false;
  StreamSubscription<YoutubePlayerValue>? _playerValueSubscription;

  Future<void> _showAuthDialog() async {
    await AuthDialog.show(
      context,
      title: 'Потрібна авторизація',
      message: 'Увійдіть, щоб додати до вподобань.',
      icon: Icons.favorite_border,
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
        // Використання use case замість прямого виклику репозиторію
        final result = await _getMovieDetailsUseCase(
          GetMovieDetailsParams(movieId: widget.item.id),
        );
        
        final details = result['details'] as Map<String, dynamic>;
        final videos = result['videos'] as List<dynamic>;
        final reviews = result['reviews'] as List<dynamic>;
        final recommendations = result['recommendations'] as List<dynamic>;

        trailerKey = _extractTrailerKey(videos);

        setState(() {
          _details = details;
          _reviews = reviews;
          _trailerKey = trailerKey;
        });
        
        // Завантажуємо рекомендації
        final recs = recommendations.cast<Movie>();
        final recommendationItems = recs.map((m) => HomeMediaItem.fromMovie(m)).toList();
        setState(() {
          _recommendations = recommendationItems;
        });
      } else {
        // Використання use case замість прямого виклику репозиторію
        final result = await _getTvDetailsUseCase(
          GetTvDetailsParams(tvId: widget.item.id),
        );
        
        final details = result['details'] as Map<String, dynamic>;
        final videos = result['videos'] as List<dynamic>;
        final reviews = result['reviews'] as List<dynamic>;
        final recommendations = result['recommendations'] as List<TvShow>;

        trailerKey = _extractTrailerKey(videos);

        setState(() {
          _details = details;
          _reviews = reviews;
          _trailerKey = trailerKey;
        });
        
        // Завантажуємо рекомендації
        final recommendationItems = recommendations.map((t) => HomeMediaItem.fromTvShow(t)).toList();
        setState(() {
          _recommendations = recommendationItems;
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

    // Завантажуємо рекомендації окремо, щоб помилки не блокували відображення інших даних
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    // Рекомендації тепер завантажуються в _loadData() для обох типів
    // Цей метод залишено для сумісності, але він більше не використовується
    return;
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
              ? const AnimatedLoadingWidget(message: 'Завантаження...')
              : _error.isNotEmpty
                  ? Center(
                      child: Text(
                        _error,
                        style: TextStyle(color: colors.onBackground),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = Responsive.isDesktop(context);
                        final isTablet = Responsive.isTablet(context);
                        final isLandscape = Responsive.isLandscape(context);
                        final horizontalPadding = Responsive.getHorizontalPadding(context);
                        final verticalPadding = Responsive.getVerticalPadding(context);
                        final spacing = Responsive.getSpacing(context);

                        return RefreshIndicator(
                          edgeOffset: 80,
                          onRefresh: _loadData,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isLandscape
                                    ? (isDesktop ? 1600 : isTablet ? 1400 : double.infinity)
                                    : (isDesktop ? 1200 : double.infinity),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? horizontalPadding.left : 0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(
                                          horizontalPadding.left,
                                          verticalPadding.top,
                                          horizontalPadding.right,
                                          verticalPadding.bottom,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              widget.item.isMovie ? Icons.movie : Icons.tv,
                                              color: colors.primary,
                                              size: isLandscape
                                                  ? (isDesktop ? 32 : isTablet ? 28 : 24)
                                                  : (isDesktop ? 28 : 24),
                                            ),
                                            SizedBox(width: spacing * 0.6),
                                            Expanded(
                                              child: Text(
                                                title,
                                                maxLines: isLandscape
                                                    ? (isDesktop ? 4 : isTablet ? 3 : 2)
                                                    : (isDesktop ? 3 : 2),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: colors.onBackground,
                                                  fontSize: isLandscape
                                                      ? (isDesktop ? 30 : isTablet ? 26 : 22)
                                                      : (isDesktop ? 26 : isTablet ? 22 : 20),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: spacing * 0.5),
                                            _buildFavoriteAction(),
                                          ],
                                        ),
                                      ),
                                      _buildHeroSection(),
                                      SizedBox(height: spacing * 1.5),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: horizontalPadding.left,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildTrailerSection(),
                                            SizedBox(height: spacing * 1.5),
                                            _buildOverviewSection(),
                                            SizedBox(height: spacing * 1.5),
                                            _buildCharacteristics(),
                                            SizedBox(height: spacing * 1.5),
                                            _buildReviewsSection(),
                                            SizedBox(height: spacing * 1.5),
                                            _buildRecommendationsSection(),
                                            SizedBox(height: verticalPadding.bottom * 2),
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
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isLandscape = Responsive.isLandscape(context);
    final horizontalPadding = Responsive.getHorizontalPadding(context);
    final spacing = Responsive.getSpacing(context);
    
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

    // Адаптивні розміри постеру з урахуванням орієнтації
    final posterWidth = isLandscape
        ? (isDesktop ? 240.0 : isTablet ? 200.0 : 160.0)
        : (isDesktop ? 200.0 : isTablet ? 160.0 : 128.0);
    final posterHeight = isLandscape
        ? (isDesktop ? 360.0 : isTablet ? 300.0 : 240.0)
        : (isDesktop ? 300.0 : isTablet ? 240.0 : 188.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding.left),
      child: _GlassCard(
        padding: EdgeInsets.all(
          isLandscape
              ? (isDesktop ? 28 : isTablet ? 24 : 18)
              : (isDesktop ? 24 : isTablet ? 18 : 14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'poster_${widget.item.id}_${widget.item.isMovie ? 'movie' : 'tv'}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
                child: posterPath != null && posterPath.isNotEmpty
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w300$posterPath',
                        width: posterWidth,
                        height: posterHeight,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: posterWidth,
                        height: posterHeight,
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
                          size: isDesktop ? 64 : isTablet ? 56 : 48,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: isLandscape ? (isDesktop ? 5 : 4) : (isDesktop ? 4 : 3),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onBackground,
                      fontSize: isLandscape
                          ? (isDesktop ? 28 : isTablet ? 24 : 20)
                          : (isDesktop ? 24 : isTablet ? 20 : 18),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: spacing * 0.7),
                  Wrap(
                    spacing: spacing * 0.7,
                    runSpacing: spacing * 0.7,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 14 : 10,
                          vertical: isDesktop ? 8 : 6,
                        ),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: isDesktop ? 20 : 16,
                              color: Colors.amber,
                            ),
                            SizedBox(width: 6),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: isDesktop ? 16 : 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_details != null &&
                          (_details!['vote_count'] as int?) != null)
                        _ChipBadge(
                          icon: Icons.people_outline,
                          label: '${_details!['vote_count']} голосів',
                        ),
                    ],
                  ),
                  SizedBox(height: spacing),
                  if (_details != null)
                    Wrap(
                      spacing: spacing * 0.7,
                      runSpacing: spacing * 0.7,
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
    return BlocBuilder<MediaCollectionsBloc, MediaCollectionsState>(
      bloc: _collectionsBloc,
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
              state.authorized ? () => _collectionsBloc.add(ToggleFavoriteEvent(widget.item)) : _showAuthDialog,
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
    final isDesktop = Responsive.isDesktop(context);
    final overview =
        _details != null &&
            (_details!['overview'] as String?)?.isNotEmpty == true
        ? _details!['overview'] as String
        : '';

    return _Section(
      title: 'Опис',
      child: Text(
        overview.isNotEmpty ? overview : 'Опис відсутній',
        style: TextStyle(
          color: colors.onSurfaceVariant,
          height: 1.4,
          fontSize: isDesktop ? 16 : 14,
        ),
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
    final isDesktop = Responsive.isDesktop(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 6 : 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors.onBackground,
              fontSize: isDesktop ? 16 : 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: isDesktop ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isLandscape = Responsive.isLandscape(context);
    final spacing = Responsive.getSpacing(context);
    
    if (_reviews.isEmpty) {
      return _Section(
        title: 'Відгуки',
        child: Text(
          'Ще немає відгуків',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: isLandscape
                ? (isDesktop ? 18 : isTablet ? 16 : 14)
                : (isDesktop ? 16 : 14),
          ),
        ),
      );
    }

    // Використовуємо GridView для desktop та tablet в landscape
    final useGridView = isDesktop || (isTablet && isLandscape);
    final reviewColumns = isLandscape
        ? (isDesktop ? 3 : isTablet ? 2 : 2)
        : (isDesktop ? 2 : 2);

    return _Section(
      title: 'Відгуки',
      child: useGridView
          ? GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: reviewColumns,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: isLandscape ? 1.3 : 1.2,
              ),
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
                          Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              author,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onBackground,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing * 0.5),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            content,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              height: 1.35,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: _reviews.length,
            )
          : ListView.separated(
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
                          Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 18,
                          ),
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
              separatorBuilder: (_, __) => SizedBox(height: spacing),
              itemCount: _reviews.length,
            ),
    );
  }

  Widget _buildRecommendationsSection() {
    debugPrint('_buildRecommendationsSection: _loadingRecommendations=$_loadingRecommendations, _recommendations.length=${_recommendations.length}');
    
    // Показуємо секцію навіть під час завантаження або якщо є рекомендації
    if (_loadingRecommendations) {
      return _Section(
        title: 'Рекомендовані',
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_recommendations.isEmpty) {
      debugPrint('Рекомендації порожні, не показуємо секцію');
      return const SizedBox.shrink();
    }

    debugPrint('Відображаємо ${_recommendations.length} рекомендацій');

    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isLandscape = Responsive.isLandscape(context);
    final spacing = Responsive.getSpacing(context);
    final columns = Responsive.getGridColumnCount(context);

    return BlocBuilder<MediaCollectionsBloc, MediaCollectionsState>(
      bloc: _collectionsBloc,
      builder: (context, collectionsState) {
        final canModify = collectionsState.authorized;
        // На desktop та tablet в landscape використовуємо GridView
        final useGridView = isDesktop || (isTablet && isLandscape);
        
        return _Section(
          title: 'Рекомендовані',
          child: useGridView
              ? GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: Responsive.getMediaCardAspectRatio(context),
                  ),
                  itemBuilder: (context, index) {
                    final item = _recommendations[index];
                    return MediaPosterCard(
                      item: item,
                      isFavorite: canModify ? collectionsState.isFavorite(item) : false,
                      onFavoriteToggle: canModify
                          ? () => _collectionsBloc.add(ToggleFavoriteEvent(item))
                          : _showAuthDialog,
                      onTap: () {
                        Navigator.of(context).push(
                          DetailPageRoute(child: MediaDetailPage(item: item)),
                        );
                      },
                    );
                  },
                  itemCount: _recommendations.length,
                )
              : SizedBox(
                  height: isTablet ? 280 : 260,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final item = _recommendations[index];
                      // Розраховуємо ширину картки для горизонтального списку
                      final cardHeight = isTablet ? 280.0 : 260.0;
                      final cardWidth = cardHeight * (2 / 3);
                      return MediaPosterCard(
                        item: item,
                        width: cardWidth,
                        isFavorite: canModify ? collectionsState.isFavorite(item) : false,
                        onFavoriteToggle: canModify
                            ? () => _collectionsBloc.add(ToggleFavoriteEvent(item))
                            : _showAuthDialog,
                        onTap: () {
                          Navigator.of(context).push(
                            DetailPageRoute(child: MediaDetailPage(item: item)),
                          );
                        },
                      );
                    },
                    separatorBuilder: (_, __) => SizedBox(width: spacing),
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
      _collectionsBloc.add(RecordWatchEvent(widget.item));
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
    final isDesktop = Responsive.isDesktop(context);
    final spacing = Responsive.getSpacing(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colors.onBackground,
            fontSize: isDesktop ? 20 : 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: spacing),
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
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(
          isDesktop ? 22 : isTablet ? 20 : 18,
        ),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.light ? 0.08 : 0.25,
            ),
            blurRadius: isDesktop ? 18 : 14,
            offset: Offset(0, isDesktop ? 12 : 10),
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
    final isDesktop = Responsive.isDesktop(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 12 : 10,
        vertical: isDesktop ? 8 : 6,
      ),
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
          Icon(
            icon,
            size: isDesktop ? 18 : 16,
            color: colors.onSurfaceVariant,
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colors.onBackground,
              fontWeight: FontWeight.w700,
              fontSize: isDesktop ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
