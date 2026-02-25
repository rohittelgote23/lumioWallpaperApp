import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/bloc/category_bloc.dart';
import '../../home/widgets/category_grid_item.dart';
import 'category_screen.dart';

class CategoriesTab extends StatelessWidget {
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Categories')),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CategoryLoaded) {
            // Filter only active categories for the main list
            final activeCategories = state.categories
                .where((c) => c.isActive && !c.isVirtual)
                .toList();

            if (activeCategories.isEmpty) {
              return const Center(child: Text('No categories found'));
            }

            return GridView.builder(
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 120,
              ),

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: activeCategories.length,
              itemBuilder: (context, index) {
                final category = activeCategories[index];
                return CategoryGridItem(
                  category: category,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CategoryScreen(category: category),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
