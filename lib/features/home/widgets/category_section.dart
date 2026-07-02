import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/models/category_model.dart';
import '../../../core/data/models/wallpaper_model.dart';
import '../../../core/data/repositories/wallpaper_repository.dart';
import '../../category/bloc/wallpaper_bloc.dart';
import '../../category/view/category_screen.dart';
import '../widgets/wallpaper_thumbnail.dart';

/// Category Section Widget
///
/// Displays a category title with "View All" button and horizontal list of wallpapers
/// Used on the home screen to show top wallpapers for each category
class CategorySection extends StatelessWidget {
  final CategoryModel category;

  const CategorySection({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          WallpaperBloc(repository: RepositoryProvider.of<WallpaperRepository>(context))
            ..add(LoadTopWallpapers(category.id, limit: 10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CategoryScreen(category: category),
                      ),
                    );
                  },
                  child: Text(
                    'View All',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal Wallpaper List
          SizedBox(
            height: 200,
            child: BlocBuilder<WallpaperBloc, WallpaperState>(
              builder: (context, state) {
                if (state is WallpaperLoading) {
                  return _buildLoadingList(context);
                } else if (state is WallpaperLoaded) {
                  if (state.wallpapers.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return _buildWallpaperList(context, state.wallpapers);
                } else if (state is WallpaperError) {
                  return _buildErrorState(context, state.message);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build horizontal list of wallpapers
  Widget _buildWallpaperList(
    BuildContext context,
    List<WallpaperModel> wallpapers,
  ) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: wallpapers.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            right: index < wallpapers.length - 1 ? 12.0 : 0,
          ),
          child: WallpaperThumbnail(
            wallpaper: wallpapers[index],
            wallpapers: wallpapers,
            width: 120,
            sectionId: 'category_section_${category.id}',
            index: index,
          ),
        );
      },
    );
  }

  /// Build loading skeleton
  Widget _buildLoadingList(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(right: index < 4 ? 12.0 : 0),
          child: Container(
            width: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'No wallpapers available',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 40,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load wallpapers',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
