import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumiowalls/core/views/main_background.dart';
import '../bloc/category_bloc.dart';
import '../../category/view/categories_tab.dart';
import '../../category/view/category_screen.dart';
import '../../favorites/view/favorites_screen.dart';
import '../../profile/view/profile_page.dart';
import '../widgets/category_grid_item.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/wallpaper_horizontal_section.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_slider.dart';
import '../widgets/color_tone_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _refreshKey = 0;

  @override
  Widget build(BuildContext context) {
    // Pages for each tab
    final pages = [
      _buildHomeContent(),
      const CategoriesTab(),
      const FavoritesScreen(),
      const ProfilePage(),
    ];

    return MainBackground(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBody: true,
        body: SafeArea(
          bottom: false,
          top: false,
          child: IndexedStack(index: _currentIndex, children: pages),
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        // AppBar stays fixed
        const HomeAppBar(),

        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<CategoryBloc>().add(const RefreshCategories());
              if (mounted) {
                setState(() {
                  _refreshKey++;
                });
              }
            },
            child: CustomScrollView(
              // physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Featured Slider
                SliverToBoxAdapter(
                  child: HomeSlider(key: ValueKey('HomeSlider_$_refreshKey')),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 30)),

                const SliverToBoxAdapter(child: ColorToneSection()),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
                // Trending Today
                SliverToBoxAdapter(
                  child: WallpaperHorizontalSection(
                    key: ValueKey('TrendingToday_$_refreshKey'),
                    categoryId: 'TrendingToday',
                    title: 'Trending today',
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),

                // Best of the Week
                SliverToBoxAdapter(
                  child: WallpaperHorizontalSection(
                    key: ValueKey('BestWeeks_$_refreshKey'),
                    categoryId: 'BestWeeks',
                    title: 'Best of the week',
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 30)),

                // Categories Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categories',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentIndex = 1; // Switch to Categories tab
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // keeps row compact
                            children: [
                              Text(
                                'View All',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10, // nice small arrow
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Categories Builder
                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoading) {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (state is CategoryLoaded) {
                      if (state.categories.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        );
                      }

                      final activeCategories = state.categories
                          .where(
                            (c) =>
                                c.isActive &&
                                !c.isVirtual &&
                                c.id != 'BestMonth',
                          )
                          .toList();

                      final top4 = activeCategories.take(4).toList();
                      final next7 = activeCategories.take(7).toList();

                      return SliverMainAxisGroup(
                        slivers: [
                          // Top 4 Grid
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.6,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final c = top4[index];
                                return CategoryGridItem(
                                  category: c,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CategoryScreen(category: c),
                                      ),
                                    );
                                  },
                                );
                              }, childCount: top4.length),
                            ),
                          ),

                          const SliverToBoxAdapter(child: SizedBox(height: 30)),

                          // Recently Added Wallpapers
                          SliverToBoxAdapter(
                            child: WallpaperHorizontalSection(
                              key: ValueKey('RecentlyAdded_$_refreshKey'),
                              categoryId: 'all',
                              title: 'Recently Added',
                              itemLimit: 7,
                              viewAllLimit: 25,
                            ),
                          ),

                          const SliverToBoxAdapter(child: SizedBox(height: 30)),

                          // Horizontal Category Lists
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final c = next7[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 30),
                                child: WallpaperHorizontalSection(
                                  categoryId: c.id,
                                  title: c.name,
                                ),
                              );
                            }, childCount: next7.length),
                          ),
                        ],
                      );
                    }

                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
