import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/models/wallpaper_model.dart';
import '../../../core/data/repositories/wallpaper_repository.dart';
import '../../category/bloc/wallpaper_bloc.dart';
import '../widgets/wallpaper_thumbnail.dart';

class BestOfMonthSection extends StatelessWidget {
  const BestOfMonthSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          WallpaperBloc(repository: RepositoryProvider.of<WallpaperRepository>(context))
            ..add(const LoadAllWallpapers(limit: 5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Best of the month',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150, // Taller cards as per image
            child: BlocBuilder<WallpaperBloc, WallpaperState>(
              builder: (context, state) {
                if (state is WallpaperLoading) {
                  return _buildLoadingList(context);
                } else if (state is WallpaperLoaded) {
                  if (state.wallpapers.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _buildWallpaperList(context, state.wallpapers);
                } else if (state is WallpaperError) {
                  return const SizedBox.shrink();
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
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
            width: 180, // Wider cards
            height: 200,
            sectionId: 'best_of_month',
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
            width: 180,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }
}
