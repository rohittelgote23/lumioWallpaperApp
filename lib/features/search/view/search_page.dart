import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/data/repositories/wallpaper_repository.dart';
import '../../home/widgets/wallpaper_thumbnail.dart';
import '../bloc/search_cubit.dart';
import '../bloc/search_state.dart';

class SearchPage extends StatelessWidget {
  final String? initialQuery;
  const SearchPage({super.key, this.initialQuery});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(
        repository: RepositoryProvider.of<WallpaperRepository>(context),
      ),
      child: SearchView(initialQuery: initialQuery),
    );
  }
}

class SearchView extends StatefulWidget {
  final String? initialQuery;
  const SearchView({super.key, this.initialQuery});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      context.read<SearchCubit>().search(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Back Button + "Discover" Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50),
                    child: Icon(
                      Icons.arrow_back,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Discover',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                autofocus: false,
                textInputAction: TextInputAction.search,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search for wallpapers...',
                  hintStyle: GoogleFonts.outfit(color: theme.hintColor),

                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.primary,
                  ),

                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, color: theme.iconTheme.color),
                          onPressed: () {
                            _searchController.clear();
                            context.read<SearchCubit>().clearSearch();
                            setState(() {});
                          },
                        )
                      : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.2, // Slightly thicker on focus (looks premium)
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),

                onSubmitted: (query) {
                  context.read<SearchCubit>().search(query);
                },
                onChanged: (query) {
                  setState(() {});
                  if (query.isEmpty) {
                    context.read<SearchCubit>().clearSearch();
                  }
                },
              ),
            ),

            const SizedBox(height: 10),

            // Recent Section (Always visible if history exists)
            BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state.history.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<SearchCubit>().clearHistory();
                            },
                            child: Text(
                              'Clear All',
                              style: GoogleFonts.outfit(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 0),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: state.history.map((tag) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              onTap: () {
                                _searchController.text = tag;
                                context.read<SearchCubit>().search(tag);
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Chip(
                                label: Text(
                                  tag,
                                  style: GoogleFonts.outfit(
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                                backgroundColor: theme.cardColor,
                                deleteIcon: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: theme.iconTheme.color?.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                onDeleted: () {
                                  context.read<SearchCubit>().removeFromHistory(
                                    tag,
                                  );
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: theme.dividerColor.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),

            // Search Results
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SearchError) {
                    return Center(child: Text(state.message));
                  } else if (state is SearchEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: theme.disabledColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No results found for "${state.query}"',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (state is SearchSuccess) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.6,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: state.wallpapers.length,
                      itemBuilder: (context, index) {
                        return WallpaperThumbnail(
                          wallpaper: state.wallpapers[index],
                          sectionId: 'search',
                          index: index,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
