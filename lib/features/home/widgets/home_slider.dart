import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../core/data/models/category_model.dart';
import '../../category/view/category_screen.dart';
import '../bloc/category_bloc.dart';

class HomeSlider extends StatefulWidget {
  const HomeSlider({super.key});

  @override
  State<HomeSlider> createState() => _HomeSliderState();
}

class _HomeSliderState extends State<HomeSlider> {
  List<CategoryModel> _filteredItems = [];

  static const _targetIds = ['MostDownloaded', 'EditorChoice', 'BestMonth'];

  @override
  void initState() {
    super.initState();
    final state = context.read<CategoryBloc>().state;
    if (state is CategoryLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processCategories(state.categories);
      });
    }
  }

  void _processCategories(List<CategoryModel> categories) {
    if (!mounted) return;

    final newItems = categories.where((c) => _targetIds.contains(c.id)).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    final sameIds =
        newItems.length == _filteredItems.length &&
        newItems.every((n) => _filteredItems.any((f) => f.id == n.id));

    if (sameIds) return;

    setState(() => _filteredItems = newItems);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryLoaded) {
          _processCategories(state.categories);
        }
      },
      builder: (context, state) {
        if (_filteredItems.isEmpty) {
          return _buildShimmer();
        }

        return CarouselSlider.builder(
          itemCount: _filteredItems.length,
          options: CarouselOptions(
            height: 160,
            viewportFraction: 0.8,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 400),
            autoPlayCurve: Curves.easeInOut,
            enlargeCenterPage: true,
            enlargeFactor: 0.1,
            enableInfiniteScroll: true, // true infinite loop both directions
            padEnds: true,
          ),
          itemBuilder: (context, index, realIndex) {
            return _buildSliderItem(context, index);
          },
        );
      },
    );
  }

  Widget _buildShimmer() {
    return SizedBox(
      height: 160,
      child: CarouselSlider.builder(
        itemCount: 3,
        options: CarouselOptions(
          height: 160,
          viewportFraction: 0.8,
          enableInfiniteScroll: false,
          autoPlay: false,
          padEnds: true,
        ),
        itemBuilder: (context, index, realIndex) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Shimmer.fromColors(
                baseColor: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.1),
                highlightColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainer.withValues(alpha: 0.2),
                child: Container(color: Theme.of(context).colorScheme.surface),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliderItem(BuildContext context, int index) {
    final item = _filteredItems[index];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CategoryScreen(category: item)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: item.thumbnail,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: Colors.grey.shade300),
                errorWidget: (_, _, _) =>
                    const Icon(Icons.error, color: Colors.white),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                      child: Text(
                        item.name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
