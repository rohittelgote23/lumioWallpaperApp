import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../../../core/services/background_task_service.dart';
import '../../../../core/data/repositories/favorites_repository.dart';
import '../../../../core/data/repositories/wallpaper_repository.dart';

part 'auto_wallpaper_state.dart';

class AutoWallpaperCubit extends Cubit<AutoWallpaperState> {
  static const String _isEnabledKey = 'auto_wallpaper_enabled';
  static const String _targetScreenKey = 'auto_wallpaper_target_screen';
  static const String _downloadedPathsKey = 'auto_wallpaper_downloaded_paths';

  AutoWallpaperCubit() : super(const AutoWallpaperState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_isEnabledKey) ?? false;
    // targetScreen mapping: 1 = Home, 2 = Lock, 3 = Both (WallpaperManagerPlus constants)
    final targetScreen = prefs.getInt(_targetScreenKey) ?? 3;

    emit(
      state.copyWith(
        isEnabled: isEnabled,
        targetScreen: targetScreen,
        isLoading: false,
      ),
    );

    // Ensure background task state matches
    if (isEnabled) {
      BackgroundTaskService.registerAutoWallpaperTask();
    } else {
      BackgroundTaskService.cancelAutoWallpaperTask();
    }
  }

  Future<void> toggleEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();

    if (isEnabled) {
      emit(state.copyWith(isLoading: true));
      try {
        // Fetch favorites
        final favoritesRepo = FavoritesRepository();
        await favoritesRepo.init();
        final favoriteIds = await favoritesRepo.getFavorites();

        if (favoriteIds.isEmpty) {
          emit(state.copyWith(isLoading: false));
          return; // The UI should handle empty favorites before calling this
        }

        // Fetch wallpapers
        final wallpaperRepo = WallpaperRepository();
        final wallpapers = await wallpaperRepo.getAllWallpapers();

        // Filter valid static favorites
        final staticFavorites = wallpapers.where((w) {
          return favoriteIds.contains(w.id) && !w.isVideo && w.hasValidUrl;
        }).toList();

        if (staticFavorites.isEmpty) {
          emit(state.copyWith(isLoading: false));
          return;
        }

        // Pick up to 10 random wallpapers
        staticFavorites.shuffle();
        final selectedWallpapers = staticFavorites.take(10).toList();

        // Download them sequentially (or parallel) and save paths
        List<String> downloadedPaths = [];
        for (var wallpaper in selectedWallpapers) {
          try {
            final fileInfo = await DefaultCacheManager().downloadFile(
              wallpaper.fullUrl,
            );
            downloadedPaths.add(fileInfo.file.path);
          } catch (e) {
            // Ignore individual failures
          }
        }

        if (downloadedPaths.isEmpty) {
          emit(state.copyWith(isLoading: false));
          return; // Download failed
        }

        await prefs.setStringList(_downloadedPathsKey, downloadedPaths);
        await prefs.setBool(_isEnabledKey, true);

        emit(state.copyWith(isEnabled: true, isLoading: false));
        BackgroundTaskService.registerAutoWallpaperTask();
      } catch (e) {
        emit(state.copyWith(isLoading: false));
      }
    } else {
      // Disable
      await prefs.setBool(_isEnabledKey, false);
      emit(state.copyWith(isEnabled: false));
      BackgroundTaskService.cancelAutoWallpaperTask();
    }
  }

  Future<void> updateTargetScreen(int targetScreen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_targetScreenKey, targetScreen);

    emit(state.copyWith(targetScreen: targetScreen));
  }
}
