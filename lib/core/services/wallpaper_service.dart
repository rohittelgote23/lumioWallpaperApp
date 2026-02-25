import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class WallpaperService {
  Future<String> setStaticWallpaper({
    required String filePath,
    required int
    location, // WallpaperManagerPlus.homeScreen, lockScreen, bothScreens
    BuildContext? context,
  }) async {
    try {
      File file = File(filePath);

      // If we have context, try to perfectly center-crop the image to the device's screen aspect ratio
      if (context != null) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        if (screenWidth > 0 && screenHeight > 0) {
          final targetRatio = screenWidth / screenHeight;

          // Decode image
          final bytes = await file.readAsBytes();
          final image = img.decodeImage(bytes);

          if (image != null) {
            final imgRatio = image.width / image.height;
            int targetWidth = image.width;
            int targetHeight = image.height;

            // Calculate new dimensions to match phone aspect ratio while maximizing resolution
            if (imgRatio > targetRatio) {
              // Image is wider than the screen => crop width
              targetWidth = (image.height * targetRatio).round();
            } else {
              // Image is taller than the screen => crop height
              targetHeight = (image.width / targetRatio).round();
            }

            // Calculate center offsets
            final offsetX = (image.width - targetWidth) ~/ 2;
            final offsetY = (image.height - targetHeight) ~/ 2;

            // Crop
            final croppedImage = img.copyCrop(
              image,
              x: offsetX,
              y: offsetY,
              width: targetWidth,
              height: targetHeight,
            );

            // Save to temp file
            final tempDir = await getTemporaryDirectory();
            final tempPath =
                '${tempDir.path}/cropped_wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
            final croppedFile = File(tempPath);
            await croppedFile.writeAsBytes(
              img.encodeJpg(croppedImage, quality: 100),
            );

            // Use the perfectly cropped file instead
            file = croppedFile;
          }
        }
      }

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
