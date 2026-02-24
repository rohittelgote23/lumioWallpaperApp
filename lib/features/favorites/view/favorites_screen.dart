import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/favorites_cubit.dart';
import '../../../core/data/models/wallpaper_model.dart';
import '../../../core/data/repositories/wallpaper_repository.dart';
import '../../home/widgets/wallpaper_thumbnail.dart';

/// Favorites Screen
///
/// Displays grid of favorited wallpapers from local storage
/// Shows empty state when no favorites exist
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Favorites')),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.favoriteIds.isEmpty) {
            return _buildEmptyState(context);
          }

          return FutureBuilder<List<WallpaperModel>>(
            future: _loadFavoriteWallpapers(state.favoriteIds),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildErrorState(context);
              }

              final wallpapers = snapshot.data ?? [];

              if (wallpapers.isEmpty) {
                return _buildEmptyState(context);
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2 / 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: wallpapers.length,
                itemBuilder: (context, index) {
                  return WallpaperThumbnail(
                    wallpaper: wallpapers[index],
                    sectionId: 'favorites',
                    index: index,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Load favorite wallpapers from Firestore
  Future<List<WallpaperModel>> _loadFavoriteWallpapers(
    List<String> favoriteIds,
  ) async {
    final repository = WallpaperRepository();
    final wallpapers = <WallpaperModel>[];

    for (final id in favoriteIds) {
      try {
        final wallpaper = await repository.getWallpaperById(id);
        if (wallpaper != null) {
          wallpapers.add(wallpaper);
        }
      } catch (e) {
        // Skip wallpapers that fail to load
        continue;
      }
    }

    return wallpapers;
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding wallpapers to your favorites',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load favorites',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
