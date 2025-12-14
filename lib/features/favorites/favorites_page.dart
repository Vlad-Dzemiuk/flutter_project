import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../l10n/app_localizations.dart';
import 'package:project/core/constants.dart';
import 'package:project/core/di.dart';
import 'package:project/core/responsive.dart';
import 'package:project/features/collections/media_collections_bloc.dart';
import 'package:project/features/collections/media_collections_event.dart';
import 'package:project/features/home/media_detail_page.dart';
import 'package:project/features/home/home_page.dart';
import 'package:project/core/theme.dart';
import 'package:project/core/page_transitions.dart';
import 'package:project/shared/widgets/animated_loading_widget.dart';
import 'package:project/shared/widgets/loading_wrapper.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final collectionsBloc = getIt<MediaCollectionsBloc>();
    return LoadingWrapper(
      child: BlocBuilder<MediaCollectionsBloc, MediaCollectionsState>(
        bloc: collectionsBloc,
        buildWhen: (previous, current) =>
            previous.favorites != current.favorites ||
            previous.loading != current.loading ||
            previous.authorized != current.authorized,
        builder: (context, state) {
          final theme = Theme.of(context);
          final colors = theme.colorScheme;

          final l10n = AppLocalizations.of(context)!;
          if (state.loading) {
            return AnimatedLoadingWidget(message: l10n.loading);
          }
          if (!state.authorized) {
            return _EmptyState(
              message: l10n.favoritesEmpty,
              showLoginPrompt: true,
              onLogin: () {
                Navigator.of(
                  context,
                ).pushReplacementNamed(AppConstants.loginRoute);
              },
            );
          }
          if (state.favorites.isEmpty) {
            return _EmptyState(message: l10n.favoritesEmpty);
          }
          return Container(
            decoration: AppGradients.background(context),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = Responsive.getHorizontalPadding(
                    context,
                  );
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
                            SizedBox(
                              width: Responsive.isMobile(context) ? 10 : 12,
                            ),
                            Text(
                              AppLocalizations.of(context)!.favorites,
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: Responsive.isMobile(context)
                                    ? 20
                                    : 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: isMobile
                            ? _buildList(
                                context,
                                state,
                                collectionsBloc,
                                theme,
                                colors,
                                horizontalPadding,
                              )
                            : _buildGrid(
                                context,
                                state,
                                collectionsBloc,
                                theme,
                                colors,
                                horizontalPadding,
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    MediaCollectionsState state,
    MediaCollectionsBloc collectionsBloc,
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

        return RepaintBoundary(
          child: Container(
            margin: EdgeInsets.only(bottom: Responsive.getSpacing(context)),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: theme.brightness == Brightness.light ? 0.08 : 0.25,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.of(
                  context,
                ).push(DetailPageRoute(child: MediaDetailPage(item: item)));
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
                          child:
                              item.posterPath != null &&
                                  item.posterPath!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl:
                                      'https://image.tmdb.org/t/p/w300${item.posterPath}',
                                  fit: BoxFit.cover,
                                  memCacheWidth: 300,
                                  memCacheHeight: 450,
                                  placeholder: (context, url) => Container(
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
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
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
                                    color: colors.onSurfaceVariant.withValues(
                                      alpha: 0.7,
                                    ),
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
                          SizedBox(
                            height: Responsive.isMobile(context) ? 6 : 8,
                          ),
                          Text(
                            item.overview,
                            maxLines: Responsive.isMobile(context) ? 3 : 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: Responsive.isMobile(context) ? 14 : 15,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(
                            height: Responsive.isMobile(context) ? 12 : 14,
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest
                                      .withValues(
                                        alpha:
                                            theme.brightness == Brightness.light
                                            ? 0.7
                                            : 0.25,
                                      ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colors.outlineVariant.withValues(
                                      alpha: 0.8,
                                    ),
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
                                onPressed: () => collectionsBloc.add(
                                  ToggleFavoriteEvent(item),
                                ),
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Color(0xFFFF6B6B),
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
          ),
        );
      },
    );
  }

  Widget _buildGrid(
    BuildContext context,
    MediaCollectionsState state,
    MediaCollectionsBloc collectionsBloc,
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

        return RepaintBoundary(
          child: MediaPosterCard(
            item: item,
            isFavorite: true,
            onFavoriteToggle: () =>
                collectionsBloc.add(ToggleFavoriteEvent(item)),
            onTap: () {
              Navigator.of(
                context,
              ).push(DetailPageRoute(child: MediaDetailPage(item: item)));
            },
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final bool showLoginPrompt;
  final VoidCallback? onLogin;

  const _EmptyState({
    required this.message,
    this.showLoginPrompt = false,
    this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final horizontalPadding = Responsive.getHorizontalPadding(context);
    final isMobile = Responsive.isMobile(context);

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
                size: isMobile ? 64 : 80,
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
              SizedBox(height: Responsive.getSpacing(context)),
              Text(
                message,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (showLoginPrompt && onLogin != null) ...[
                SizedBox(height: Responsive.getSpacing(context) / 2),
                Text(
                  AppLocalizations.of(context)!.favoritesLoginPrompt,
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
                    AppLocalizations.of(context)!.signIn,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
