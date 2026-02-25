import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/data/models/wallpaper_model.dart';
import '../../favorites/bloc/favorites_cubit.dart';
import '../../wallpaper_detail/view/wallpaper_detail_screen.dart';

/// Wallpaper Thumbnail Widget
///
/// Displays a cached thumbnail image with shimmer loading effect
/// Navigates to wallpaper detail on tap
class WallpaperThumbnail extends StatelessWidget {
  final WallpaperModel wallpaper;
  final double? width;
  final double? height;
  final double aspectRatio;
  final String? sectionId;
  final int? index;

  const WallpaperThumbnail({
    super.key,
    required this.wallpaper,
    this.width,
    this.height,
    this.aspectRatio = 9 / 16,
    this.sectionId,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final heroTag = sectionId != null
        ? '${sectionId}_wallpaper.${wallpaper.id}_${index ?? 0}'
        : 'wallpaper_${wallpaper.id}_${index ?? 0}';
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                WallpaperDetailScreen(wallpaper: wallpaper, heroTag: heroTag),
          ),
        );
      },
      child: Hero(
        tag: heroTag,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: wallpaper.thumbnailUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: wallpaper.thumbnailUrl,
                          fit: BoxFit.cover,
                          memCacheHeight:
                              ((height ?? 300) *
                                      MediaQuery.of(context).devicePixelRatio)
                                  .toInt(),
                          placeholder: (context, url) => _buildShimmer(context),
                          errorWidget: (context, url, error) =>
                              _buildError(context),
                        )
                      : _buildError(context),
                ),
              ),
              if (wallpaper.isPremium)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF7C4DFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "PRO",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              // Favorite Icon
              Positioned(
                bottom: 8,
                right: 8,
                child: BlocBuilder<FavoritesCubit, FavoritesState>(
                  builder: (context, state) {
                    final isFavorite = context
                        .read<FavoritesCubit>()
                        .isFavorite(wallpaper.id);
                    return GestureDetector(
                      onTap: () {
                        context.read<FavoritesCubit>().toggleFavorite(
                          wallpaper.id,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black,
                          size: 18,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
      highlightColor: Theme.of(
        context,
      ).colorScheme.surfaceContainer.withValues(alpha: 0.2),
      child: Container(color: Theme.of(context).colorScheme.surface),
    );
  }

  /// Build error placeholder
  Widget _buildError(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Icon(
          Icons.broken_image_rounded,
          size: 40,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
