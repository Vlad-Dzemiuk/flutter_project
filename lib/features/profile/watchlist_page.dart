import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/core/constants.dart';
import 'package:project/core/di.dart';
import 'package:project/features/collections/media_collections_cubit.dart';
import 'package:project/features/home/home_page.dart';
import 'package:project/core/theme.dart';
import 'package:project/features/home/media_detail_page.dart';
import 'package:project/shared/widgets/loading_widget.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

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
        if (state.watchlist.isEmpty) {
          return const _EmptyState(message: 'Ще нічого не переглянуто');
        }
        return Container(
          decoration: AppGradients.background(context),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.visibility, color: colors.primary),
                      const SizedBox(width: 10),
                      Text(
                        'Переглянуті',
                        style: TextStyle(
                          color: colors.onBackground,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: state.watchlist.length,
                    itemBuilder: (context, index) {
                      final entry = state.watchlist[index];
                      final item = entry.toHomeMediaItem();
                      final isFavorite = state.isFavorite(item);
                      
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
                  ),
                ),
              ],
            ),
          ),
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
                child: Icon(Icons.visibility_outlined,
                    color: colors.primary, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'Переглянуті недоступні',
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Увійдіть, щоб бачити ваші переглянуті фільми та серіали.',
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

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: AppGradients.background(context),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.visibility_outlined,
                size: 64, color: colors.onBackground.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: colors.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
