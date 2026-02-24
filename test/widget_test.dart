import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiowalls/main.dart';
import 'package:lumiowalls/core/data/repositories/favorites_repository.dart';
import 'package:lumiowalls/features/auth/data/auth_repository.dart';
import 'package:lumiowalls/core/data/repositories/category_repository.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Create a mock favorites repository for testing
    final authRepository = AuthRepository();
    final favoritesRepository = FavoritesRepository();
    final categoryRepository = CategoryRepository();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MyApp(
        authRepository: authRepository,
        favoritesRepository: favoritesRepository,
        categoryRepository: categoryRepository,
        isFirstTime: true, // Provide a dummy value for the test
      ),
    );

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
