import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/core/constants.dart';
import 'package:project/core/di.dart';
import 'package:project/features/collections/media_collections_cubit.dart';
import 'package:project/features/home/home_page.dart';
import 'package:project/features/home/media_detail_page.dart';
import 'package:project/shared/widgets/loading_widget.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final collectionsCubit = getIt<MediaCollectionsCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Переглянуто')),
      body: BlocBuilder<MediaCollectionsCubit, MediaCollectionsState>(
        bloc: collectionsCubit,
        builder: (context, state) {
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
            return const Center(child: Text('Ще нічого не переглянуто'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            itemCount: state.watchlist.length,
            itemBuilder: (context, index) {
              final entry = state.watchlist[index];
              final item = entry.toHomeMediaItem();
              return MediaPosterCard(
                width: double.infinity,
                item: item,
                isFavorite: state.isFavorite(item),
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
        },
      ),
    );
  }
}

class _UnauthorizedMessage extends StatelessWidget {
  const _UnauthorizedMessage({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Ви не авторизовані'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onLogin, child: const Text('Увійти')),
        ],
      ),
    );
  }
}
