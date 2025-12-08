import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/core/constants.dart';
import 'package:project/core/di.dart';
import 'package:project/core/responsive.dart';
import 'package:project/features/collections/media_collections_cubit.dart';
import 'package:project/features/home/media_detail_page.dart';
import 'package:project/features/home/home_page.dart';
import 'package:project/core/theme.dart';
import 'package:project/shared/widgets/loading_widget.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final collectionsCubit = getIt<MediaCollectionsCubit>();
    return BlocBuilder<MediaCollectionsCubit, MediaCollectionsState>(
      bloc: collectionsCubit,
      builder: (context, state) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        if (state.loading) {
          return const LoadingWidget(message: 'Завантаження...');
        }
        if (!state.authorized) {
          return _UnauthorizedMessage(
            onLogin: () {
              Navigator.of(
                context,
              ).pushReplacementNamed(AppConstants.loginRoute);
            },
          );
        }
        if (state.favorites.isEmpty) {
          return const _EmptyState(message: 'Список вподобань порожній');
        }
        return Container(
          decoration: AppGradients.background(context),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = Responsive.getHorizontalPadding(context);
                final isMobile = Responsive.isMobile(context);
                
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding.left,
                        Responsive.isMobile(context) ? 16 : 20,
                        horizontalPadding.right,
                        Responsive.getSpacing(context) / 2,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: colors.primary,
                            size: Responsive.isMobile(context) ? 24 : 28,
                          ),
                          SizedBox(width: Responsive.isMobile(context) ? 10 : 12),
                          Text(
                            'Вподобані',
                            style: TextStyle(
                              color: colors.onBackground,
                              fontSize: Responsive.isMobile(context) ? 20 : 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: isMobile
                          ? _buildList(context, state, collectionsCubit, theme, colors, horizontalPadding)
                          : _buildGrid(context, state, collectionsCubit, theme, colors, horizontalPadding),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    MediaCollectionsState state,
    MediaCollectionsCubit collectionsCubit,
    ThemeData theme,
    ColorScheme colors,
    EdgeInsets horizontalPadding,
  ) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding.left,
        Responsive.getSpacing(context) / 2,
        horizontalPadding.right,
        20,
      ),
      itemCount: state.favorites.length,
      itemBuilder: (context, index) {
                      final entry = state.favorites[index];
                      final item = entry.toHomeMediaItem();
                      final isFavorite = true;
                      
        return Container(
          margin: EdgeInsets.only(bottom: Responsive.getSpacing(context)),
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
              padding: EdgeInsets.all(Responsive.isMobile(context) ? 12 : 16),
              child: Row(
                children: [
                  ClipRRect(
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
                                                  .withOpacity(0.7),
                                              size: 32,
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
                            color: colors.onBackground,
                          ),
                        ),
                        SizedBox(height: Responsive.isMobile(context) ? 6 : 8),
                        Text(
                          item.overview,
                          maxLines: Responsive.isMobile(context) ? 3 : 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurfaceVariant
                                .withOpacity(0.7),
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
                                            onPressed: () =>
                                                collectionsCubit
                                                    .toggleFavorite(item),
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
    );
  }

  Widget _buildGrid(
    BuildContext context,
    MediaCollectionsState state,
    MediaCollectionsCubit collectionsCubit,
    ThemeData theme,
    ColorScheme colors,
    EdgeInsets horizontalPadding,
  ) {
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
      itemCount: state.favorites.length,
      itemBuilder: (context, index) {
        final entry = state.favorites[index];
        final item = entry.toHomeMediaItem();
        
        return MediaPosterCard(
          item: item,
          isFavorite: true,
          onFavoriteToggle: () => collectionsCubit.toggleFavorite(item),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MediaDetailPage(item: item),
              ),
            );
          },
        );
      },
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
                  color: colors.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.favorite_border,
                  color: colors.primary,
                  size: isMobile ? 28 : 36,
                ),
              ),
              SizedBox(height: Responsive.getSpacing(context)),
              Text(
                'Вподобані недоступні',
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: Responsive.getSpacing(context) / 2),
              Text(
                'Увійдіть, щоб переглядати та зберігати улюблені фільми й серіали.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onBackground.withOpacity(0.65),
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

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isMobile = Responsive.isMobile(context);
    final horizontalPadding = Responsive.getHorizontalPadding(context);
    
    return Container(
      decoration: AppGradients.background(context),
      child: Center(
        child: Padding(
          padding: horizontalPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border,
                size: Responsive.isMobile(context) ? 64 : 80,
                color: colors.onBackground.withOpacity(0.7),
              ),
              SizedBox(height: Responsive.getSpacing(context)),
              Text(
                message,
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: Responsive.isMobile(context) ? 18 : 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
