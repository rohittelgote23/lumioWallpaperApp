// import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class WallpaperService {
  Future<String> setStaticWallpaper({
    required String filePath,
    required int
    location, // WallpaperManagerPlus.homeScreen, lockScreen, bothScreens
    double? targetRatio,
  }) async {
    try {
      File file = File(filePath);

      // If we have targetRatio, perfectly center-crop the image to match the device aspect ratio
      if (targetRatio != null && targetRatio > 0) {
        // Read bytes to pass to background isolate
        final bytes = await file.readAsBytes();

        // Offload decode, crop, and encode to background isolate
        final croppedBytes = await compute(_cropImageTask, {
          'bytes': bytes,
          'targetRatio': targetRatio,
        });

        if (croppedBytes != null) {
          // Save to temp file
          final tempDir = await getTemporaryDirectory();
          final tempPath =
              '${tempDir.path}/cropped_wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final croppedFile = File(tempPath);
          await croppedFile.writeAsBytes(croppedBytes);

          // Use the perfectly cropped file instead
          file = croppedFile;
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

/// Helper function to perform CPU-intensive cropping in a background isolate
List<int>? _cropImageTask(Map<String, dynamic> params) {
  final Uint8List bytes = params['bytes'];
  final double targetRatio = params['targetRatio'];

  // Decode image
  final image = img.decodeImage(bytes);
  if (image == null) return null;

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

  // Encode
  return img.encodeJpg(croppedImage, quality: 100);
}
