class AppConstants {
  // Firestore Collection Names
  static const String categoriesCollection = 'Categories';
  static const String wallpapersCollection = 'Wallpapers';

  // Hive Box Names
  static const String favoritesBox = 'favorites';

  // Pagination & Limits
  static const int homeWallpapersLimit =
      10; // Number of wallpapers shown per category on home
  static const int categoryPageSize =
      20; // Number of wallpapers per page in category view

  // Download Configuration
  static const int downloadTimeout = 60000; // 60 seconds
  static const String downloadFolderName = 'LumioWalls';

  // App Information
  static const String appName = 'LumioWalls';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Beautiful wallpapers for your device';

  // Error Messages
  static const String networkError = 'Please check your internet connection';
  static const String downloadError = 'Failed to download wallpaper';
  static const String permissionError = 'Storage permission is required';
  static const String genericError = 'Something went wrong';

  // Success Messages
  static const String downloadSuccess = 'Wallpaper Downloaded';
  static const String favoriteAdded = 'Added to favorites';
  static const String favoriteRemoved = 'Removed from favorites';
}
