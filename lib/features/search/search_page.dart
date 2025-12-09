import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/core/constants.dart';
import 'package:project/core/di.dart';
import 'package:project/core/responsive.dart';
import 'package:project/core/storage/user_prefs.dart';
import 'package:project/features/auth/auth_repository.dart';
import 'package:project/features/collections/media_collections_bloc.dart';
import 'package:project/features/collections/media_collections_event.dart';
import 'package:project/features/home/home_media_item.dart';
import 'package:project/features/home/home_page.dart';
import 'package:project/features/home/domain/usecases/search_media_usecase.dart';
import 'package:project/features/home/media_detail_page.dart';
import 'package:project/core/theme.dart';
import 'package:project/core/page_transitions.dart';
import 'package:project/shared/widgets/loading_wrapper.dart';
import 'package:project/shared/widgets/animated_loading_widget.dart';
import 'package:project/shared/widgets/auth_dialog.dart';

import '../auth/data/models/local_user.dart';

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

  late final SearchMediaUseCase _searchMediaUseCase;
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
    _searchMediaUseCase = getIt<SearchMediaUseCase>();
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
    if (query.trim().isEmpty) {
      return;
    }

    setState(() {
      _searching = true;
      _loading = true;
    });

    try {
      // Використання use case замість прямого виклику репозиторію
      final result = await _searchMediaUseCase(
        SearchMediaParams(query: query, page: 1),
      );

      if (mounted) {
        setState(() {
          _searchResults = result.results;
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
      // Використання use case замість прямого виклику репозиторію
      final result = await _searchMediaUseCase(
        SearchMediaParams(
          genreName: genre.isEmpty ? null : genre,
          year: year,
          rating: _rating,
          page: 1,
        ),
      );

      if (mounted) {
        setState(() {
          _searchResults = result.results;
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
    return LoadingWrapper(
      child: BlocProvider.value(
        value: getIt<MediaCollectionsBloc>(),
        child: Builder(
          builder: (context) {
            final collectionsBloc = context.watch<MediaCollectionsBloc>();
            final collectionsState = collectionsBloc.state;
            final canModify = collectionsState.authorized;

            final theme = Theme.of(context);
            final colors = theme.colorScheme;

            return Scaffold(
              backgroundColor: colors.surface,
              body: Container(
                decoration: AppGradients.background(context),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final horizontalPadding = Responsive
                          .getHorizontalPadding(context);

                      return Column(
                        children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding.left,
                                Responsive.isMobile(context) ? 12 : 16,
                                horizontalPadding.right,
                                Responsive.getSpacing(context) / 2,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.search,
                                        color: colors.primary,
                                        size: Responsive.isMobile(context)
                                            ? 24
                                            : 28,
                                      ),
                                      SizedBox(
                                          width: Responsive.isMobile(context)
                                              ? 12
                                              : 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Text(
                                            'Пошук',
                                            style: TextStyle(
                                              fontSize: Responsive.isMobile(
                                                  context) ? 20 : 24,
                                              fontWeight: FontWeight.w700,
                                              color: colors.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height: Responsive.getSpacing(context)),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Responsive.isMobile(context)
                                          ? 14
                                          : 18,
                                      vertical: Responsive.isMobile(context)
                                          ? 10
                                          : 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.surfaceContainerHighest.withValues(alpha:
                                        theme.brightness == Brightness.light
                                            ? 1
                                            : 0.18,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: colors.outlineVariant
                                            .withValues(alpha: 0.8),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha:
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
                                            color: colors.onSurfaceVariant,
                                            size: Responsive.isMobile(context)
                                                ? 20
                                                : 24),
                                        SizedBox(
                                            width: Responsive.isMobile(context)
                                                ? 10
                                                : 12),
                                        Expanded(
                                          child: TextField(
                                            controller: _searchController,
                                            style: TextStyle(
                                              color: colors.onSurface,
                                              fontSize: Responsive.isMobile(
                                                  context) ? 16 : 18,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Введіть назву...',
                                              hintStyle: TextStyle(
                                                color: colors.onSurfaceVariant,
                                                fontSize: Responsive.isMobile(
                                                    context) ? 16 : 18,
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
                                        SizedBox(
                                            width: Responsive.isMobile(context)
                                                ? 4
                                                : 8),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _showFilters = !_showFilters;
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(
                                              12),
                                          child: Container(
                                            padding: EdgeInsets.all(
                                                Responsive.isMobile(context)
                                                    ? 8
                                                    : 10),
                                            decoration: BoxDecoration(
                                              color: colors.primary,
                                              borderRadius: BorderRadius
                                                  .circular(12),
                                            ),
                                            child: Icon(
                                              _showFilters
                                                  ? Icons.tune
                                                  : Icons.tune_rounded,
                                              color: colors.onPrimary,
                                              size: Responsive.isMobile(context)
                                                  ? 18
                                                  : 20,
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
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding.left,
                                  0,
                                  horizontalPadding.right,
                                  Responsive.getSpacing(context) / 2,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(
                                      Responsive.isMobile(context) ? 14 : 18),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerHighest.withValues(alpha:
                                      theme.brightness == Brightness.light
                                          ? 1
                                          : 0.16,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: colors.outlineVariant.withValues(alpha:
                                          0.8),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
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
                                      SizedBox(height: Responsive.getSpacing(
                                          context)),
                                      Responsive.isMobile(context)
                                          ? Column(
                                        children: [
                                          _InputTile(
                                            controller: _yearController,
                                            label: 'Рік',
                                            keyboardType: TextInputType.number,
                                            icon: Icons.calendar_month_outlined,
                                          ),
                                          SizedBox(
                                              height: Responsive.getSpacing(
                                                  context)),
                                          Column(
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
                                                      fontWeight: FontWeight
                                                          .w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: colors
                                                          .surfaceContainerHighest
                                                          .withValues(alpha:
                                                        theme.brightness ==
                                                            Brightness.light
                                                            ? 1
                                                            : 0.18,
                                                      ),
                                                      borderRadius:
                                                      BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      _rating.toStringAsFixed(
                                                          1),
                                                      style: TextStyle(
                                                        color: colors.onSurface,
                                                        fontWeight: FontWeight
                                                            .w700,
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
                                                onChanged: (val) =>
                                                    setState(
                                                          () => _rating = val,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                          : Row(
                                        children: [
                                          Expanded(
                                            child: _InputTile(
                                              controller: _yearController,
                                              label: 'Рік',
                                              keyboardType: TextInputType
                                                  .number,
                                              icon: Icons
                                                  .calendar_month_outlined,
                                            ),
                                          ),
                                          SizedBox(width: Responsive.getSpacing(
                                              context)),
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Рейтинг',
                                                      style: TextStyle(
                                                        color: colors.onSurface,
                                                        fontWeight: FontWeight
                                                            .w600,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: colors
                                                            .surfaceContainerHighest
                                                            .withValues(alpha:
                                                          theme.brightness ==
                                                              Brightness.light
                                                              ? 1
                                                              : 0.18,
                                                        ),
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                      ),
                                                      child: Text(
                                                        _rating.toStringAsFixed(
                                                            1),
                                                        style: TextStyle(
                                                          color: colors
                                                              .onSurface,
                                                          fontWeight: FontWeight
                                                              .w700,
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
                                                  onChanged: (val) =>
                                                      setState(
                                                            () => _rating = val,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: Responsive.getSpacing(
                                          context)),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: colors.primary,
                                            foregroundColor: theme.brightness ==
                                                Brightness.light
                                                ? Colors.white
                                                : colors.onPrimary,
                                            padding: EdgeInsets.symmetric(
                                              vertical: Responsive.isMobile(
                                                  context) ? 14 : 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(14),
                                            ),
                                          ),
                                          onPressed: _searchByFilters,
                                          icon: const Icon(Icons.search),
                                          label: Text(
                                            'Пошук за фільтрами',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: Responsive.isMobile(
                                                  context) ? 14 : 16,
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
                                  color: colors.surfaceContainerHighest.withValues(alpha:
                                    theme.brightness == Brightness.light
                                        ? 0.4
                                        : 0.08,
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                  border: Border.all(
                                    color: colors.outlineVariant.withValues(alpha:
                                        0.8),
                                  ),
                                ),
                                child: _searchController.text
                                    .trim()
                                    .isNotEmpty ||
                                    _searchResults.isNotEmpty
                                    ? _buildSearchResults(
                                  collectionsState,
                                  canModify,
                                  collectionsBloc,
                                )
                                    : _buildRecentSearches(
                                  collectionsState,
                                  canModify,
                                  collectionsBloc,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchResults(MediaCollectionsState collectionsState,
      bool canModify,
      MediaCollectionsBloc collectionsBloc,) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final isMobile = Responsive.isMobile(context);
  final horizontalPadding = Responsive.getHorizontalPadding(context);

  if (_loading) {
    return const AnimatedLoadingWidget(message: 'Завантаження...');
  }

  if (_searchResults.isEmpty && !_searching) {
    return Center(
      child: Padding(
        padding: horizontalPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: Responsive.isMobile(context) ? 64 : 80,
              color: colors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            SizedBox(height: Responsive.getSpacing(context)),
            Text(
              'Нічого не знайдено',
              style: TextStyle(
                fontSize: Responsive.isMobile(context) ? 18 : 22,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  return isMobile
      ? _buildSearchResultsList(
      collectionsState, canModify, collectionsBloc, horizontalPadding)
      : _buildSearchResultsGrid(
      collectionsState, canModify, collectionsBloc, horizontalPadding);
}

  Widget _buildSearchResultsList(MediaCollectionsState collectionsState,
      bool canModify,
      MediaCollectionsBloc collectionsBloc,
      EdgeInsets horizontalPadding,) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;

  return ListView.builder(
    padding: EdgeInsets.fromLTRB(
      horizontalPadding.left,
      Responsive.getSpacing(context) / 2,
      horizontalPadding.right,
      20,
    ),
    itemCount: _searchResults.length,
    itemBuilder: (context, index) {
      final item = _searchResults[index];
      final isFavorite = canModify && collectionsState.isFavorite(item);

      return Container(
        margin: EdgeInsets.only(bottom: Responsive.getSpacing(context)),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:
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
            if (!mounted) return;
            Navigator.of(context).push(
              DetailPageRoute(child: MediaDetailPage(item: item)),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(Responsive.isMobile(context) ? 12 : 16),
            child: Row(
              children: [
                Hero(
                  tag: 'poster_${item.id}_${item.isMovie ? 'movie' : 'tv'}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: Responsive.isMobile(context) ? 120 : 140,
                      width: Responsive.isMobile(context) ? 90 : 105,
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
                          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Responsive.isMobile(context) ? 14 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: Responsive.isMobile(context) ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                      SizedBox(height: Responsive.isMobile(context) ? 6 : 8),
                      Text(
                        item.overview,
                        maxLines: Responsive.isMobile(context) ? 3 : 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                          fontSize: Responsive.isMobile(context) ? 14 : 15,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: Responsive.isMobile(context) ? 12 : 14),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest.withValues(alpha:
                                theme.brightness == Brightness.light
                                    ? 0.7
                                    : 0.25,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colors.outlineVariant.withValues(alpha: 0.8),
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
                              collectionsBloc.add(ToggleFavoriteEvent(item));
                            }
                                : () {
                              AuthDialog.show(
                                context,
                                title: 'Потрібна авторизація',
                                message: 'Увійдіть, щоб додати до вподобань.',
                                icon: Icons.favorite_border,
                              );
                            },
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border_rounded,
                              color: isFavorite
                                  ? const Color(0xFFFF6B6B)
                                  : colors.onSurfaceVariant.withValues(alpha: 0.7),
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

  Widget _buildSearchResultsGrid(MediaCollectionsState collectionsState,
      bool canModify,
      MediaCollectionsBloc collectionsBloc,
      EdgeInsets horizontalPadding,) {
  final columns = Responsive.getGridColumnCount(context);
  final spacing = Responsive.getSpacing(context);
  final aspectRatio = Responsive.getMediaCardAspectRatio(context);

  return GridView.builder(
    padding: EdgeInsets.symmetric(
      horizontal: horizontalPadding.left,
      vertical: Responsive.getSpacing(context) / 2,
    ),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: aspectRatio,
    ),
    itemCount: _searchResults.length,
    itemBuilder: (context, index) {
      final item = _searchResults[index];
      final isFavorite = canModify && collectionsState.isFavorite(item);

      return MediaPosterCard(
        item: item,
        isFavorite: isFavorite,
        onFavoriteToggle: canModify
            ? () => collectionsBloc.add(ToggleFavoriteEvent(item))
            : () {
          AuthDialog.show(
            context,
            title: 'Потрібна авторизація',
            message: 'Увійдіть, щоб додати до вподобань.',
            icon: Icons.favorite_border,
          );
        },
        onTap: () async {
          if (canModify) {
            await _addToHistory(item);
          }
          if (!mounted) return;
          Navigator.of(context).push(
            DetailPageRoute(child: MediaDetailPage(item: item)),
          );
        },
      );
    },
  );
}

  Widget _buildRecentSearches(MediaCollectionsState collectionsState,
      bool canModify,
      MediaCollectionsBloc collectionsBloc,) {
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

  final horizontalPadding = Responsive.getHorizontalPadding(context);
  final isMobile = Responsive.isMobile(context);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.all(horizontalPadding.left),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Історія пошуку',
              style: Theme
                  .of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontSize: Responsive.isMobile(context) ? 20 : 24,
              ),
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
          child: Padding(
            padding: horizontalPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_outlined,
                  size: Responsive.isMobile(context) ? 64 : 80,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                SizedBox(height: Responsive.getSpacing(context)),
                Text(
                  'Історія пошуку порожня',
                  style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 18 : 22,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        )
            : isMobile
            ? _buildRecentSearchesList(
            collectionsState, collectionsBloc, horizontalPadding)
            : _buildRecentSearchesGrid(
            collectionsState, collectionsBloc, horizontalPadding),
      ),
    ],
  );
}

  Widget _buildRecentSearchesList(MediaCollectionsState collectionsState,
      MediaCollectionsBloc collectionsBloc,
      EdgeInsets horizontalPadding,) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;

  return ListView.builder(
    padding: EdgeInsets.fromLTRB(
      horizontalPadding.left,
      0,
      horizontalPadding.right,
      20,
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
      final isFavorite = collectionsState.isFavorite(item);

      return Container(
        margin: EdgeInsets.only(bottom: Responsive.getSpacing(context)),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:
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
              DetailPageRoute(child: MediaDetailPage(item: item)),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(Responsive.isMobile(context) ? 12 : 16),
            child: Row(
              children: [
                Hero(
                  tag: 'poster_${item.id}_${item.isMovie ? 'movie' : 'tv'}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: Responsive.isMobile(context) ? 120 : 140,
                      width: Responsive.isMobile(context) ? 90 : 105,
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
                              .withValues(alpha: 0.7),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Responsive.isMobile(context) ? 14 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: Responsive.isMobile(context) ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                      SizedBox(height: Responsive.isMobile(context) ? 6 : 8),
                      Text(
                        item.overview,
                        maxLines: Responsive.isMobile(context) ? 3 : 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurfaceVariant
                              .withValues(alpha: 0.7),
                          fontSize: Responsive.isMobile(context) ? 14 : 15,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: Responsive.isMobile(context) ? 12 : 14),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest
                                  .withValues(alpha:
                                theme.brightness ==
                                    Brightness.light
                                    ? 0.7
                                    : 0.25,
                              ),
                              borderRadius:
                              BorderRadius.circular(12),
                              border: Border.all(
                                color: colors.outlineVariant
                                    .withValues(alpha: 0.8),
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
                              collectionsBloc.add(ToggleFavoriteEvent(item));
                            },
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border_rounded,
                              color: isFavorite
                                  ? const Color(0xFFFF6B6B)
                                  : colors.onSurfaceVariant
                                  .withValues(alpha: 0.7),
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

  Widget _buildRecentSearchesGrid(MediaCollectionsState collectionsState,
      MediaCollectionsBloc collectionsBloc,
      EdgeInsets horizontalPadding,) {
    final columns = Responsive.getGridColumnCount(context);
    final spacing = Responsive.getSpacing(context);
    final aspectRatio = Responsive.getMediaCardAspectRatio(context);

    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding.left,
        vertical: Responsive.getSpacing(context) / 2,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
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
        final isFavorite = collectionsState.isFavorite(item);

        return MediaPosterCard(
          item: item,
          isFavorite: isFavorite,
          onFavoriteToggle: () => collectionsBloc.add(ToggleFavoriteEvent(item)),
          onTap: () {
            Navigator.of(context).push(
              DetailPageRoute(child: MediaDetailPage(item: item)),
            );
          },
        );
      },
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
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha:
          theme.brightness == Brightness.light ? 1 : 0.18,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: colors.onSurfaceVariant,
            size: isMobile ? 20 : 24,
          ),
          SizedBox(width: isMobile ? 10 : 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: isMobile ? 16 : 18,
              ),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: isMobile ? 16 : 18,
                ),
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
    final isMobile = Responsive.isMobile(context);
    final horizontalPadding = Responsive.getHorizontalPadding(context);

    return Container(
      decoration: AppGradients.background(context),
      child: SafeArea(
        child: Padding(
          padding: horizontalPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 14 : 18),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.search_outlined,
                  color: colors.primary,
                  size: isMobile ? 28 : 36,
                ),
              ),
              SizedBox(height: Responsive.getSpacing(context)),
              Text(
                'Історія пошуку недоступна',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: Responsive.getSpacing(context) / 2),
              Text(
                'Увійдіть, щоб зберігати та переглядати історію пошуку.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurface.withValues(alpha: 0.65),
                  fontSize: isMobile ? 14 : 16,
                  height: 1.4,
                ),
              ),
              SizedBox(height: Responsive.getSpacing(context)),
              FilledButton(
                onPressed: onLogin,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 32,
                    vertical: isMobile ? 12 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Увійти',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
