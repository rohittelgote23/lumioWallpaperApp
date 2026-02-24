import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/repositories/wallpaper_repository.dart';
import '../bloc/color_wallpaper_bloc.dart';
import '../../home/widgets/wallpaper_thumbnail.dart';
import '../../../core/views/main_background.dart';

/// Color Screen
///
/// Displays all wallpapers for a specific color in a grid layout
/// Supports pull-to-refresh
class ColorScreen extends StatelessWidget {
  final String colorName;
  final Color baseColor;

  const ColorScreen({
    super.key,
    required this.colorName,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ColorWallpaperBloc(repository: context.read<WallpaperRepository>())
            ..add(LoadColorWallpapers(colorName)),
      child: _ColorScreenView(colorName: colorName, baseColor: baseColor),
    );
  }
}

class _ColorScreenView extends StatefulWidget {
  final String colorName;
  final Color baseColor;

  const _ColorScreenView({required this.colorName, required this.baseColor});

  @override
  State<_ColorScreenView> createState() => _ColorScreenViewState();
}

class _ColorScreenViewState extends State<_ColorScreenView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ColorWallpaperBloc>().add(const LoadMoreColorWallpapers());
    }
  }

  // Helper method to capitalize the first letter of the color
  String _capitalize(String s) =>
      s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';

  @override
  Widget build(BuildContext context) {
    return MainBackground(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<ColorWallpaperBloc, ColorWallpaperState>(
            builder: (context, state) {
              if (state is ColorWallpaperLoading &&
                  state is! ColorWallpaperLoaded) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ColorWallpaperLoaded) {
                // If empty and not loading, show empty state
                if (state.wallpapers.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ColorWallpaperBloc>().add(
                      RefreshColorWallpapers(widget.colorName),
                    );
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Custom Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: widget.baseColor,
                                      shape: BoxShape.circle,
                                      border:
                                          widget.colorName.toLowerCase() ==
                                              'white'
                                          ? Border.all(
                                              color: Colors.grey.shade300,
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    _capitalize(widget.colorName),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displayLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${state.wallpapers.length} Wallpapers available',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: const Color.fromARGB(
                                        255,
                                        95,
                                        95,
                                        95,
                                      ),
                                      fontWeight: FontWeight.w400,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Wallpaper Grid
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2 / 3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return WallpaperThumbnail(
                              wallpaper: state.wallpapers[index],
                              sectionId: 'color_${widget.colorName}',
                              index: index,
                            );
                          }, childCount: state.wallpapers.length),
                        ),
                      ),

                      // Loading indicator at bottom
                      if (!state.hasReachedMax)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        )
                      else
                        const SliverToBoxAdapter(child: SizedBox(height: 30)),
                    ],
                  ),
                );
              } else if (state is ColorWallpaperError) {
                return _buildErrorState(context, state.message);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
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
            Icons.wallpaper_outlined,
            size: 80,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No wallpapers found for this color',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  /// Build error state with retry button
  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
              'Failed to load wallpapers',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ColorWallpaperBloc>().add(
                  LoadColorWallpapers(widget.colorName),
                );
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
