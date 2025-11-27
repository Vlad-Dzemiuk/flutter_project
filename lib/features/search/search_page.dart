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

          return Scaffold(
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Пошук за назвою...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_searchController.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchResults = [];
                                      });
                                    },
                                  ),
                                IconButton(
                                  icon: Icon(
                                    _showFilters
                                        ? Icons.filter_list
                                        : Icons.filter_list_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showFilters = !_showFilters;
                                    });
                                  },
                                ),
                              ],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showFilters) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _genreController,
                          decoration: const InputDecoration(
                            labelText: 'Жанр (наприклад: Action, Comedy)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _yearController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Рік',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Рейтинг: ${_rating.toStringAsFixed(1)}',
                                  ),
                                  Slider(
                                    min: 0,
                                    max: 10,
                                    divisions: 20,
                                    value: _rating,
                                    onChanged: (val) =>
                                        setState(() => _rating = val),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _searchByFilters,
                            child: const Text('Пошук за фільтрами'),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
                Expanded(
                  child:
                      _searchController.text.trim().isNotEmpty ||
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
              ],
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty && !_searching) {
      return const Center(child: Text('Нічого не знайдено'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return MediaPosterCard(
          item: item,
          isFavorite: canModify ? collectionsState.isFavorite(item) : false,
          onFavoriteToggle: canModify
              ? () {
                  collectionsCubit.toggleFavorite(item);
                }
              : () {
                  showDialog(
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
                            Navigator.of(
                              context,
                            ).pushNamed(AppConstants.loginRoute);
                          },
                          child: const Text('Увійти'),
                        ),
                      ],
                    ),
                  );
                },
          onTap: () async {
            // Зберігаємо в історію тільки для авторизованих користувачів
            if (canModify) {
              await _addToHistory(item);
            }
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => MediaDetailPage(item: item)),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentSearches(
    MediaCollectionsState collectionsState,
    bool canModify,
    MediaCollectionsCubit collectionsCubit,
  ) {
    // Показуємо історію тільки для авторизованих користувачів
    if (!canModify) {
      return const Center(
        child: Text(
          'Історія пошуку доступна тільки для авторизованих користувачів',
        ),
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
              ? const Center(child: Text('Історія пошуку порожня'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.62,
                  ),
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
                    return MediaPosterCard(
                      width: double.infinity,
                      item: item,
                      isFavorite: collectionsState.isFavorite(item),
                      onFavoriteToggle: () {
                        collectionsCubit.toggleFavorite(item);
                      },
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MediaDetailPage(item: item),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
