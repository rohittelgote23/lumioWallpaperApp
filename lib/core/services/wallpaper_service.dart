import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

import 'dart:io';

class WallpaperService {
  Future<String> setStaticWallpaper({
    required String filePath,
    required int
    location, // WallpaperManagerPlus.homeScreen, lockScreen, bothScreens
  }) async {
    try {
      final file = File(filePath);
      final result = await WallpaperManagerPlus().setWallpaper(file, location);
      return result != null
          ? 'Wallpaper set successfully'
          : 'Failed to set wallpaper';
    } catch (e) {
      return 'Failed to set wallpaper: $e';
    }
  }

  // Live wallpaper handling removed as per request
}
