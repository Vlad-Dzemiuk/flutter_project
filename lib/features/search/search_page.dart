import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/core/constants.dart';
import 'package:project/core/di.dart';
import 'package:project/core/storage/user_prefs.dart';
import 'package:project/features/auth/auth_repository.dart';
import 'package:project/features/collections/media_collections_cubit.dart';
import 'package:project/features/home/home_media_item.dart';
import 'package:project/features/home/home_page.dart';
import 'package:project/features/home/home_repository.dart';
import 'package:project/features/home/media_detail_page.dart';
import 'package:project/features/home/movie_model.dart';
import 'package:project/features/home/tv_show_model.dart';
import 'package:project/core/theme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  double _rating = 5.0;
  bool _showFilters = false;

  late final HomeRepository _repository;
  late final AuthRepository _authRepository;
  Timer? _searchDebounce;
  StreamSubscription<LocalUser?>? _authSubscription;
  List<HomeMediaItem> _searchResults = [];
  List<Map<String, dynamic>> _searchHistory = [];
  bool _loading = false;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _repository = getIt<HomeRepository>();
    _authRepository = getIt<AuthRepository>();
    _loadSearchHistory();
    _searchController.addListener(_onSearchChanged);
    // Слухаємо зміни авторизації
    _authSubscription = _authRepository.authStateChanges().listen((user) {
      _loadSearchHistory();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _authSubscription?.cancel();
    _searchController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    // Завантажуємо історію тільки для авторизованих користувачів
    final isAuthorized = _authRepository.currentUser != null;
    if (!isAuthorized) {
      if (mounted) {
        setState(() {
          _searchHistory = [];
        });
      }
      return;
    }
    final history = await UserPrefs.instance.getSearchHistory();
    if (mounted) {
      setState(() {
        _searchHistory = history;
      });
    }
  }

  Future<void> _addToHistory(HomeMediaItem item) async {
    final itemMap = {
      'id': item.id,
      'title': item.title,
      'overview': item.overview,
      'posterPath': item.posterPath,
      'rating': item.rating,
      'isMovie': item.isMovie,
    };
    await UserPrefs.instance.addToSearchHistory(itemMap);
    await _loadSearchHistory();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _searchDebounce?.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searching = false;
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _searching = true;
      _loading = true;
    });

    try {
      final searchData = await _repository.searchByName(query);
      final movies = (searchData['movies'] as List<dynamic>)
          .cast<Movie>()
          .map((m) => HomeMediaItem.fromMovie(m))
          .toList();
      final tvShows = (searchData['tvShows'] as List<dynamic>)
          .cast<TvShow>()
          .map((t) => HomeMediaItem.fromTvShow(t))
          .toList();

      if (mounted) {
        setState(() {
          _searchResults = [...movies, ...tvShows];
          _loading = false;
          _searching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _searching = false;
        });
      }
    }
  }

  Future<void> _searchByFilters() async {
    final genre = _genreController.text.trim();
    final year = int.tryParse(_yearController.text);

    setState(() {
      _loading = true;
      _searching = true;
    });

    try {
      final moviesData = await _repository.searchMovies(
        genreName: genre.isEmpty ? null : genre,
        year: year,
        rating: _rating,
      );
      final tvData = await _repository.searchTvShows(
        genreName: genre.isEmpty ? null : genre,
        year: year,
        rating: _rating,
      );

      final movies = (moviesData['movies'] as List<dynamic>)
          .cast<Movie>()
          .map((m) => HomeMediaItem.fromMovie(m))
          .toList();
      final tvShows = (tvData['tvShows'] as List<dynamic>)
          .cast<TvShow>()
          .map((t) => HomeMediaItem.fromTvShow(t))
          .toList();

      if (mounted) {
        setState(() {
          _searchResults = [...movies, ...tvShows];
          _loading = false;
          _searching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _searching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<MediaCollectionsCubit>(),
      child: Builder(
        builder: (context) {
          final collectionsCubit = context.watch<MediaCollectionsCubit>();
          final collectionsState = collectionsCubit.state;
          final canModify = collectionsState.authorized;

          final theme = Theme.of(context);
          final colors = theme.colorScheme;

          return Scaffold(
            backgroundColor: colors.background,
            body: Container(
              decoration: AppGradients.background(context),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: colors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Пошук',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: colors.onBackground,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceVariant.withOpacity(
                                theme.brightness == Brightness.light ? 1 : 0.18,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colors.outlineVariant.withOpacity(0.8),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    theme.brightness == Brightness.light
                                        ? 0.08
                                        : 0.25,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search,
                                    color: colors.onSurfaceVariant),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    style: TextStyle(
                                      color: colors.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Введіть назву...',
                                      hintStyle: TextStyle(
                                        color: colors.onSurfaceVariant,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty)
                                  IconButton(
                                    icon: Icon(Icons.close,
                                        color: colors.onSurfaceVariant),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchResults = [];
                                      });
                                    },
                                  ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _showFilters = !_showFilters;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: colors.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _showFilters
                                          ? Icons.tune
                                          : Icons.tune_rounded,
                                      color: colors.onPrimary,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedCrossFade(
                      crossFadeState: _showFilters
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 250),
                      firstChild: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colors.surfaceVariant.withOpacity(
                              theme.brightness == Brightness.light ? 1 : 0.16,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: colors.outlineVariant.withOpacity(0.8),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _InputTile(
                                      controller: _genreController,
                                      label:
                                          'Жанр (наприклад: Action, Comedy)',
                                      icon: Icons.category_outlined,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _InputTile(
                                      controller: _yearController,
                                      label: 'Рік',
                                      keyboardType: TextInputType.number,
                                      icon: Icons.calendar_month_outlined,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Рейтинг',
                                              style: TextStyle(
                                                color: colors.onSurface,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: colors.surfaceVariant
                                                    .withOpacity(
                                                  theme.brightness ==
                                                          Brightness.light
                                                      ? 1
                                                      : 0.18,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                _rating.toStringAsFixed(1),
                                                style: TextStyle(
                                                  color: colors.onSurface,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Slider(
                                          min: 0,
                                          max: 10,
                                          divisions: 20,
                                          activeColor: colors.primary,
                                          value: _rating,
                                          onChanged: (val) => setState(
                                            () => _rating = val,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    foregroundColor: theme.brightness ==
                                            Brightness.light
                                        ? Colors.white
                                        : colors.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: _searchByFilters,
                                  icon: const Icon(Icons.search),
                                  label: const Text(
                                    'Пошук за фільтрами',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      secondChild: const SizedBox.shrink(),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant.withOpacity(
                            theme.brightness == Brightness.light ? 0.4 : 0.08,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          border: Border.all(
                            color: colors.outlineVariant.withOpacity(0.8),
                          ),
                        ),
                        child: _searchController.text.trim().isNotEmpty ||
                                _searchResults.isNotEmpty
                            ? _buildSearchResults(
                                collectionsState,
                                canModify,
                                collectionsCubit,
                              )
                            : _buildRecentSearches(
                                collectionsState,
                                canModify,
                                collectionsCubit,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(
    MediaCollectionsState collectionsState,
    bool canModify,
    MediaCollectionsCubit collectionsCubit,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty && !_searching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 64,
              color: colors.onSurfaceVariant.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Нічого не знайдено',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.onBackground,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        final isFavorite = canModify && collectionsState.isFavorite(item);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.outlineVariant.withOpacity(0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  theme.brightness == Brightness.light ? 0.08 : 0.25,
                ),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () async {
              // Зберігаємо в історію тільки для авторизованих користувачів
              if (canModify) {
                await _addToHistory(item);
              }
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => MediaDetailPage(item: item)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 120,
                      width: 90,
                      child: item.posterPath != null &&
                              item.posterPath!.isNotEmpty
                          ? Image.network(
                              'https://image.tmdb.org/t/p/w300${item.posterPath}',
                              fit: BoxFit.cover,
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blueGrey.shade900,
                                    Colors.blueGrey.shade700,
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.movie,
                                color: colors.onSurfaceVariant.withOpacity(0.7),
                                size: 32,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.onBackground,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.overview,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurfaceVariant.withOpacity(0.7),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceVariant.withOpacity(
                                  theme.brightness == Brightness.light
                                      ? 0.7
                                      : 0.25,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colors.outlineVariant.withOpacity(0.8),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item.rating.toStringAsFixed(1),
                                    style: TextStyle(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: canModify
                                  ? () {
                                      collectionsCubit.toggleFavorite(item);
                                    }
                                  : () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Потрібна авторизація'),
                                          content: const Text(
                                              'Увійдіть, щоб додати до вподобань.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(),
                                              child: const Text('Скасувати'),
                                            ),
                                            FilledButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                                Navigator.of(context).pushNamed(
                                                    AppConstants.loginRoute);
                                              },
                                              child: const Text('Увійти'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border_rounded,
                                color: isFavorite
                                    ? const Color(0xFFFF6B6B)
                                    : colors.onSurfaceVariant.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentSearches(
    MediaCollectionsState collectionsState,
    bool canModify,
    MediaCollectionsCubit collectionsCubit,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    
    // Показуємо історію тільки для авторизованих користувачів
    if (!canModify) {
      return _UnauthorizedMessage(
        onLogin: () {
          Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Історія пошуку',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (_searchHistory.isNotEmpty)
                TextButton(
                  onPressed: () async {
                    await UserPrefs.instance.clearSearchHistory();
                    await _loadSearchHistory();
                  },
                  child: const Text('Очистити'),
                ),
            ],
          ),
        ),
        Expanded(
          child: _searchHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_outlined,
                        size: 64,
                        color: colors.onSurfaceVariant.withOpacity(0.6),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Історія пошуку порожня',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colors.onBackground,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: _searchHistory.length,
                  itemBuilder: (context, index) {
                    final itemMap = _searchHistory[index];
                    final item = HomeMediaItem(
                      id: itemMap['id'] as int,
                      title: itemMap['title'] as String,
                      overview: itemMap['overview'] as String,
                      posterPath: itemMap['posterPath'] as String?,
                      rating: (itemMap['rating'] as num).toDouble(),
                      isMovie: itemMap['isMovie'] as bool,
                    );
                    final isFavorite = collectionsState.isFavorite(item);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colors.outlineVariant.withOpacity(0.8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              theme.brightness == Brightness.light
                                  ? 0.08
                                  : 0.25,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MediaDetailPage(item: item),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: SizedBox(
                                  height: 120,
                                  width: 90,
                                  child: item.posterPath != null &&
                                          item.posterPath!.isNotEmpty
                                      ? Image.network(
                                          'https://image.tmdb.org/t/p/w300${item.posterPath}',
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.blueGrey.shade900,
                                                Colors.blueGrey.shade700,
                                              ],
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.movie,
                                            color: colors.onSurfaceVariant
                                                .withOpacity(0.7),
                                            size: 32,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: colors.onBackground,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.overview,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant
                                            .withOpacity(0.7),
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colors.surfaceVariant
                                                .withOpacity(
                                              theme.brightness ==
                                                      Brightness.light
                                                  ? 0.7
                                                  : 0.25,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: colors.outlineVariant
                                                  .withOpacity(0.8),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                size: 16,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                item.rating.toStringAsFixed(1),
                                                style: TextStyle(
                                                  color: colors.onSurface,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          onPressed: () {
                                            collectionsCubit.toggleFavorite(item);
                                          },
                                          icon: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border_rounded,
                                            color: isFavorite
                                                ? const Color(0xFFFF6B6B)
                                                : colors.onSurfaceVariant
                                                    .withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _InputTile extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  const _InputTile({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(
          theme.brightness == Brightness.light ? 1 : 0.18,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.8)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(color: colors.onSurface),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: TextStyle(color: colors.onSurfaceVariant),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnauthorizedMessage extends StatelessWidget {
  const _UnauthorizedMessage({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      decoration: AppGradients.background(context),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.search_outlined,
                  color: colors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Історія пошуку недоступна',
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Увійдіть, щоб зберігати та переглядати історію пошуку.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onBackground.withOpacity(0.65),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onLogin,
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Увійти',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
