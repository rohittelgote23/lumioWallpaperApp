import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/models/wallpaper_model.dart';
import '../../../core/data/models/category_model.dart';
import '../bloc/home_wallpapers_cubit.dart';
import '../../category/view/category_screen.dart';
import '../widgets/wallpaper_thumbnail.dart';

class WallpaperHorizontalSection extends StatelessWidget {
  final String categoryId;
  final String title;
  final int itemLimit;
  final int? viewAllLimit;

  const WallpaperHorizontalSection({
    super.key,
    required this.categoryId,
    required this.title,
    this.itemLimit = 5,
    this.viewAllLimit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeWallpapersCubit, HomeWallpapersState>(
      builder: (context, state) {
        if (state is HomeWallpapersLoading || state is HomeWallpapersInitial) {
          return _buildContent(context, null, isLoading: true);
        } else if (state is HomeWallpapersLoaded) {
          List<WallpaperModel> filtered = List.from(state.wallpapers);
          if (categoryId == 'TrendingToday') {
            filtered.sort((a, b) => b.views.compareTo(a.views));
          } else if (categoryId != 'all') {
            filtered = filtered
                .where((w) => w.categoryIds.contains(categoryId))
                .toList();
          }

          final wallpapersToShow = filtered.take(itemLimit).toList();
          if (wallpapersToShow.isEmpty) {
            return const SizedBox.shrink();
          }
          return _buildContent(context, wallpapersToShow, isLoading: false);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<WallpaperModel>? wallpapers, {
    required bool isLoading,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryScreen(
                        category: CategoryModel(
                          id: categoryId,
                          name: title,
                          order: 0,
                          thumbnail: '',
                          createdAt: DateTime.now(),
                          isVirtual: false,
                        ),
                        itemLimit: viewAllLimit,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min, // keeps row compact
                  children: [
                    Text(
                      'View All',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white // Dark mode color
                          : Colors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 210,
          child: isLoading
              ? _buildLoadingList(context)
              : _buildWallpaperList(context, wallpapers!),
        ),
      ],
    );
  }

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
            right: index < wallpapers.length - 1 ? 16.0 : 0,
          ),
          child: WallpaperThumbnail(
            wallpaper: wallpapers[index],
            wallpapers: wallpapers,
            width: 140,
            height: 210,
            sectionId: categoryId,
            index: index,
          ),
        );
      },
    );
  }

  Widget _buildLoadingList(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(right: index < 2 ? 16.0 : 0),
          child: Container(
            width: 140,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }
}
