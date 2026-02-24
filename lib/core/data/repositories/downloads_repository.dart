import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing downloaded wallpapers
///
/// Uses SharedPreferences to track which wallpapers have been downloaded
class DownloadsRepository {
  static const String _downloadedIdsKey = 'downloaded_wallpaper_ids';

  /// Add a wallpaper ID to the downloaded list
  Future<void> addDownload(String wallpaperId) async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedIds = prefs.getStringList(_downloadedIdsKey) ?? [];

    if (!downloadedIds.contains(wallpaperId)) {
      downloadedIds.add(wallpaperId);
      await prefs.setStringList(_downloadedIdsKey, downloadedIds);
    }
  }

  /// Remove a wallpaper ID from the downloaded list
  Future<void> removeDownload(String wallpaperId) async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedIds = prefs.getStringList(_downloadedIdsKey) ?? [];

    downloadedIds.remove(wallpaperId);
    await prefs.setStringList(_downloadedIdsKey, downloadedIds);
  }

  /// Get list of downloaded wallpaper IDs
  Future<List<String>> getDownloadedWallpaperIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_downloadedIdsKey) ?? [];
    } catch (e) {
      // print('Error getting downloaded wallpapers: $e');
      return [];
    }
  }

  /// Check if a wallpaper is downloaded
  Future<bool> isWallpaperDownloaded(String wallpaperId) async {
    final downloadedIds = await getDownloadedWallpaperIds();
    return downloadedIds.contains(wallpaperId);
  }

  /// Get count of downloaded wallpapers
  Future<int> getDownloadsCount() async {
    final ids = await getDownloadedWallpaperIds();
    return ids.length;
  }

  /// Clear all download records
  Future<void> clearAllDownloads() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_downloadedIdsKey);
  }
}
