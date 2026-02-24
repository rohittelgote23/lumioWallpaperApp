import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Helper class for managing storage permissions
///
/// Handles permission requests for saving wallpapers to device gallery
/// Supports both Android (including Android 13+) and iOS
class PermissionHelper {
  /// Request storage permission based on platform and Android version
  ///
  /// For Android 13+ (API 33+), requests photos permission
  /// For older Android versions, requests storage permission
  /// For iOS, requests photos permission
  static Future<bool> requestStoragePermission() async {
    // For iOS
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }

    // For Android 13+ (API 33+), use photos permission
    if (await _isAndroid13OrHigher()) {
      final status = await Permission.photos.request();
      // Also request videos if needed, but for wallpapers photos is primary
      return status.isGranted;
    }

    // For older Android versions, use storage permission
    final status = await Permission.storage.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // Open app settings if permission is permanently denied
      await openAppSettings();
      return false;
    }

    return false;
  }

  /// Check if storage permission is already granted
  static Future<bool> isStoragePermissionGranted() async {
    if (Platform.isIOS) {
      return await Permission.photos.isGranted;
    }

    if (await _isAndroid13OrHigher()) {
      return await Permission.photos.isGranted;
    }
    return await Permission.storage.isGranted;
  }

  /// Check if running on Android 13 or higher
  static Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  /// Open app settings for manual permission grant
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
