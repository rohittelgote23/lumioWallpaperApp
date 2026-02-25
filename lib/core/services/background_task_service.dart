import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == BackgroundTaskService.autoWallpaperTaskName) {
        // 1. Initialize Flutter
        WidgetsFlutterBinding.ensureInitialized();

        // 2. Read locally downloaded paths
        final prefs = await SharedPreferences.getInstance();
        final downloadedPaths =
            prefs.getStringList('auto_wallpaper_downloaded_paths') ?? [];

        if (downloadedPaths.isEmpty) {
          return Future.value(true);
        }

        // 3. Filter valid existing files
        final validPaths = downloadedPaths
            .where((path) => File(path).existsSync())
            .toList();

        if (validPaths.isEmpty) {
          return Future.value(true);
        }

        // 4. Pick random wallpaper
        final random = Random();
        final selectedPath = validPaths[random.nextInt(validPaths.length)];
        final file = File(selectedPath);

        // 5. Get target screen
        final targetScreen =
            prefs.getInt('auto_wallpaper_target_screen') ??
            WallpaperManagerPlus.bothScreens;

        // 6. Set wallpaper
        await WallpaperManagerPlus().setWallpaper(file, targetScreen);

        return Future.value(true);
      }
    } catch (e) {
      // Catch exceptions silently for background tasks
      return Future.value(false);
    }
    return Future.value(true);
  });
}

class BackgroundTaskService {
  static const String autoWallpaperTaskName = 'auto_wallpaper_task';

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Set to true for debugging during development
    );
  }

  static void registerAutoWallpaperTask() {
    // 1. Set up the daily repeating task
    // NOTE: Android OS strictly enforces a minimum of 15 minutes for periodic tasks.
    // Setting it to 15 seconds gets ignored and clamped to 15 minutes by the OS!
    Workmanager().registerPeriodicTask(
      'auto_wallpaper_periodic_1', // unique name
      autoWallpaperTaskName,
      frequency: const Duration(days: 1), // Change wallpaper every day
      // Network constraint removed as we rely on locally downloaded files
    );

    // 2. Trigger an immediate one-off task for testing purposes
    // This will run ~10 seconds after the wallpapers finish downloading
    Workmanager().registerOneOffTask(
      'auto_wallpaper_test_1',
      autoWallpaperTaskName,
      initialDelay: const Duration(seconds: 10),
    );
  }

  static void cancelAutoWallpaperTask() {
    Workmanager().cancelByUniqueName('auto_wallpaper_periodic_1');
  }
}
