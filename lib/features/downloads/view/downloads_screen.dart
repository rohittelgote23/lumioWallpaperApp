import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/models/wallpaper_model.dart';
import '../../../core/data/repositories/downloads_repository.dart';
import '../../../core/data/repositories/wallpaper_repository.dart';
import '../../home/widgets/wallpaper_thumbnail.dart';
import '../bloc/downloads_list_cubit.dart';

/// Downloads Screen
///
/// Displays grid of downloaded wallpapers from local storage
/// Shows empty state when no downloads exist
class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DownloadsListCubit(
        downloadsRepo: DownloadsRepository(),
        wallpaperRepo: RepositoryProvider.of<WallpaperRepository>(context),
      )..loadDownloads(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Downloads',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: BlocBuilder<DownloadsListCubit, DownloadsListState>(
          builder: (context, state) {
            if (state is DownloadsListLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DownloadsListError) {
              return _buildErrorState(context);
            }

            if (state is DownloadsListEmpty) {
              return _buildEmptyState(context);
            }

            if (state is DownloadsListLoaded) {
              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2 / 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: state.wallpapers.length,
                itemBuilder: (context, index) {
                  final wallpaper = state.wallpapers[index];
                  return Stack(
                    children: [
                      WallpaperThumbnail(
                        wallpaper: wallpaper,
                        wallpapers: state.wallpapers,
                        sectionId: 'downloads',
                        index: index,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            _showDeleteConfirmation(context, wallpaper);
                          },
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WallpaperModel wallpaper) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Delete Download',
          style: GoogleFonts.funnelSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          wallpaper.isVideo
              ? 'Remove this video from downloads list? (It will remain in your Gallery)'
              : 'Delete this wallpaper from your device?',
          style: GoogleFonts.funnelSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel', style: GoogleFonts.funnelSans()),
          ),
          TextButton(
            onPressed: () {
              context.read<DownloadsListCubit>().deleteDownload(wallpaper);
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              'Delete',
              style: GoogleFonts.funnelSans(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_outlined,
            size: 80,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No downloads yet',
            style: GoogleFonts.funnelSans(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Downloaded wallpapers will appear here',
            style: GoogleFonts.funnelSans(
              fontSize: 14,
              color: Colors.grey[600],
            ),
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
            'Failed to load downloads',
            style: GoogleFonts.funnelSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
