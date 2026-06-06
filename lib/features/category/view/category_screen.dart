import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/models/category_model.dart';
import '../../../core/data/repositories/wallpaper_repository.dart';
import '../bloc/wallpaper_bloc.dart';
import '../../home/widgets/wallpaper_thumbnail.dart';
import '../../../core/views/main_background.dart';

/// Category Screen
///
/// Displays all wallpapers for a specific category in a grid layout
/// Supports pull-to-refresh
class CategoryScreen extends StatelessWidget {
  final CategoryModel category;
  final int? itemLimit;

  const CategoryScreen({super.key, required this.category, this.itemLimit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          WallpaperBloc(repository: context.read<WallpaperRepository>())
            ..add(LoadWallpapers(category.id, limit: itemLimit ?? 20)),
      child: _CategoryScreenView(category: category, itemLimit: itemLimit),
    );
  }
}

class _CategoryScreenView extends StatefulWidget {
  final CategoryModel category;
  final int? itemLimit;

  const _CategoryScreenView({required this.category, this.itemLimit});

  @override
  State<_CategoryScreenView> createState() => _CategoryScreenViewState();
}

class _CategoryScreenViewState extends State<_CategoryScreenView> {
  final ScrollController _scrollController = ScrollController();
  String _currentOrder = 'createdAt';

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
    if (widget.itemLimit != null) {
      return; // Disable infinite scroll if we are in a limited view
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<WallpaperBloc>().add(
        LoadMoreWallpapers(orderBy: _currentOrder),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainBackground(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<WallpaperBloc, WallpaperState>(
            builder: (context, state) {
              bool isLoading =
                  state is WallpaperLoading || state is WallpaperInitial;
              bool isError = state is WallpaperError;
              bool isEmpty =
                  state is WallpaperLoaded && state.wallpapers.isEmpty;

              int wallpaperCount = 0;
              if (state is WallpaperLoaded) {
                wallpaperCount = state.wallpapers.length;
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<WallpaperBloc>().add(
                    RefreshWallpapers(
                      widget.category.id,
                      orderBy: _currentOrder,
                      limit: widget.itemLimit,
                    ),
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
                            Text(
                              widget.category.name,
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$wallpaperCount Wallpapers available',
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
                            const SizedBox(height: 16),
                            // Sort Chips
                            if (widget.itemLimit == null &&
                                widget.category.id != 'all' &&
                                widget.category.id != 'TrendingToday' &&
                                widget.category.id != 'BestWeeks')
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildSortChip(
                                      context,
                                      label: 'Recent',
                                      value: 'createdAt',
                                    ),
                                    const SizedBox(width: 8),
                                    _buildSortChip(
                                      context,
                                      label: 'Likes',
                                      value: 'likes',
                                    ),
                                    const SizedBox(width: 8),
                                    _buildSortChip(
                                      context,
                                      label: 'Downloads',
                                      value: 'downloads',
                                    ),
                                    const SizedBox(width: 8),
                                    _buildSortChip(
                                      context,
                                      label: 'Views',
                                      value: 'views',
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    if (isLoading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (isError)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildErrorState(context, (state).message),
                      )
                    else if (isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(context),
                      )
                    else if (state is WallpaperLoaded)
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
                              sectionId: 'category_screen_${widget.category.id}',
                              index: index,
                            );
                          }, childCount: state.wallpapers.length),
                        ),
                      ),

                    // Loading indicator at bottom
                    if (state is WallpaperLoaded && !state.hasReachedMax)
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
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final isSelected = _currentOrder == value;
    final theme = Theme.of(context);

    return ActionChip(
      label: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.textTheme.bodyMedium?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: isSelected ? theme.colorScheme.primary : theme.cardColor,
      side: BorderSide(
        color: isSelected
            ? Colors.transparent
            : theme.dividerColor.withValues(alpha: 0.2),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        if (!isSelected) {
          setState(() {
            _currentOrder = value;
          });
          context.read<WallpaperBloc>().add(
            LoadWallpapers(
              widget.category.id,
              orderBy: value,
              limit: widget.itemLimit ?? 20,
            ),
          );
        }
      },
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
            'No wallpapers available in this category',
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
                context.read<WallpaperBloc>().add(
                  LoadWallpapers(
                    widget.category.id,
                    limit: widget.itemLimit ?? 20,
                  ),
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
