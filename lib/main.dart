import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/data/repositories/favorites_repository.dart';
import 'core/data/repositories/category_repository.dart';
import 'core/data/repositories/wallpaper_repository.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/bloc/auth_cubit.dart';
import 'features/home/view/home_screen.dart';
import 'features/favorites/bloc/favorites_cubit.dart';
import 'features/home/bloc/category_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/bloc/theme/theme_cubit.dart';
import 'core/bloc/theme/theme_state.dart';
import 'features/onboarding/view/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Repositories
  final authRepository = AuthRepository();
  final favoritesRepository = FavoritesRepository();
  await favoritesRepository.init();

  final categoryRepository = CategoryRepository();

  // Check if first time
  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool('isFirstTime') ?? true;

  runApp(
    MyApp(
      authRepository: authRepository,
      favoritesRepository: favoritesRepository,
      categoryRepository: categoryRepository,
      isFirstTime: isFirstTime,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final FavoritesRepository favoritesRepository;
  final CategoryRepository categoryRepository;
  final bool isFirstTime;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.favoritesRepository,
    required this.categoryRepository,
    required this.isFirstTime,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => WallpaperRepository(),
      child: MultiBlocProvider(
        providers: [
          // Theme Cubit
          BlocProvider(create: (context) => ThemeCubit()),

          // Auth Cubit
          BlocProvider(
            create: (context) => AuthCubit(authRepository: authRepository),
          ),

          // Favorites Cubit (app-wide)
          BlocProvider(
            create: (context) => FavoritesCubit(
              repository: favoritesRepository,
              wallpaperRepository: context.read<WallpaperRepository>(),
            )..loadFavorites(),
          ),

          // Category Bloc (app-wide)
          BlocProvider(
            create: (context) =>
                CategoryBloc(repository: categoryRepository)
                  ..add(LoadCategories()),
          ),
        ],
        child: Builder(
          builder: (context) {
            // Listen to Auth changes to reload favorites
            return BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is Authenticated) {
                  // When logged in, sync/reload favorites from cloud
                  context.read<FavoritesCubit>().syncAndReload();
                } else if (state is Unauthenticated) {
                  // When logged out, reload (will fetch local/guest favorites)
                  context.read<FavoritesCubit>().loadFavorites();
                }
              },
              child: BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, themeState) {
                  return MaterialApp(
                    title: 'LumioWalls',
                    debugShowCheckedModeBanner: false,

                    // Theme Configuration
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeState.themeMode,

                    // Initial Route
                    home: isFirstTime
                        ? const OnboardingScreen()
                        : const HomeScreen(),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
