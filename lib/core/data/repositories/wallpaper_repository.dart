import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/wallpaper_model.dart';
import '../../utils/constants.dart';

/// Repository for wallpaper-related operations
///
/// Handles all Firestore interactions for wallpapers
/// Provides methods to fetch wallpapers by category with pagination support
class WallpaperRepository {
  final FirebaseFirestore _firestore;
  final Map<String, WallpaperModel> _wallpaperCache = {};

  WallpaperRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> _cacheWallpapersList(String listKey, List<WallpaperModel> wallpapers) async {
    try {
      final wpBox = await Hive.openBox<Map>('wallpapers_cache');
      final listBox = await Hive.openBox<List<dynamic>>('lists_cache');

      // Save individual wallpapers
      for (final wp in wallpapers) {
        await wpBox.put(wp.id, wp.toJson());
      }

      // Save the list of IDs
      final ids = wallpapers.map((w) => w.id).toList();
      await listBox.put(listKey, ids);
    } catch (e) {
      // Fail silently to not disrupt the app
    }
  }

  Future<List<WallpaperModel>> _getCachedWallpapersList(String listKey) async {
    try {
      final wpBox = await Hive.openBox<Map>('wallpapers_cache');
      final listBox = await Hive.openBox<List<dynamic>>('lists_cache');

      final ids = listBox.get(listKey);
      if (ids == null) return [];

      final List<WallpaperModel> wallpapers = [];
      for (final id in ids) {
        final wpMap = wpBox.get(id);
        if (wpMap != null) {
          wallpapers.add(WallpaperModel.fromJson(Map<String, dynamic>.from(wpMap)));
        }
      }
      return wallpapers;
    } catch (e) {
      return [];
    }
  }

  /// Get all wallpapers for a specific category
  ///
  /// Returns active wallpapers sorted by creation date (newest first)
  Future<List<WallpaperModel>> getWallpapersByCategory(
    String categoryId, {
    int? limit,
    DocumentSnapshot? startAfter,
    String orderBy = 'createdAt', // Added orderBy parameter
  }) async {
    try {
      // If fetching TrendingToday, explicitly sort by views regardless of standard argument
      final actualOrderBy = categoryId == 'TrendingToday' ? 'views' : orderBy;

      Query query = _firestore
          .collection(AppConstants.wallpapersCollection)
          .where('isActive', isEqualTo: true)
          .orderBy(actualOrderBy, descending: true); // Apply sorting

      // Only filter by category if it's not the special 'all' or 'TrendingToday' lists which just fetch latest
      if (categoryId != 'all' && categoryId != 'TrendingToday') {
        query = query.where('categoryIds', arrayContains: categoryId);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      final wallpapers = querySnapshot.docs
          .map((doc) => WallpaperModel.fromFirestore(doc))
          .toList();

      for (final w in wallpapers) {
        _wallpaperCache[w.id] = w;
      }

      if (startAfter == null) {
        final listKey = '${categoryId}_limit_${limit ?? 'all'}_order_$orderBy';
        await _cacheWallpapersList(listKey, wallpapers);
      }

      return wallpapers;
    } catch (e) {
      throw Exception('Failed to fetch wallpapers: $e');
    }
  }

  /// Get all wallpapers for a specific color
  ///
  /// Returns active wallpapers sorted by creation date (newest first)
  Future<List<WallpaperModel>> getWallpapersByColor(
    String color, {
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.wallpapersCollection)
          .where('color_palette', arrayContains: color)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      final wallpapers = querySnapshot.docs
          .map((doc) => WallpaperModel.fromFirestore(doc))
          .toList();

      for (final w in wallpapers) {
        _wallpaperCache[w.id] = w;
      }

      if (startAfter == null) {
        final listKey = 'color_${color}_limit_${limit ?? 'all'}';
        await _cacheWallpapersList(listKey, wallpapers);
      }

      return wallpapers;
    } catch (e) {
      throw Exception('Failed to fetch wallpapers by color: $e');
    }
  }

  /// Get wallpapers by category using a Cache-First strategy
  Stream<List<WallpaperModel>> getWallpapersByCategoryCacheFirst(
    String categoryId, {
    int? limit,
    String orderBy = 'createdAt',
  }) async* {
    final listKey = '${categoryId}_limit_${limit ?? 'all'}_order_$orderBy';

    // 1. Yield cached wallpapers first
    final cached = await _getCachedWallpapersList(listKey);
    if (cached.isNotEmpty) {
      yield cached;
    }

    // 2. Fetch fresh wallpapers from Firestore
    try {
      final fresh = await getWallpapersByCategory(
        categoryId,
        limit: limit,
        orderBy: orderBy,
      );
      yield fresh;
    } catch (e) {
      // If Firestore fetch fails, and we already yielded cached wallpapers, we don't throw
      if (cached.isEmpty) {
        rethrow;
      }
    }
  }

  /// Get all wallpapers using a Cache-First strategy
  Stream<List<WallpaperModel>> getAllWallpapersCacheFirst({int? limit}) async* {
    final listKey = 'all_limit_${limit ?? 'all'}';

    // 1. Yield cached wallpapers first
    final cached = await _getCachedWallpapersList(listKey);
    if (cached.isNotEmpty) {
      yield cached;
    }

    // 2. Fetch fresh wallpapers from Firestore
    try {
      final fresh = await getAllWallpapers(limit: limit);
      yield fresh;
    } catch (e) {
      if (cached.isEmpty) {
        rethrow;
      }
    }
  }

  /// Get wallpapers by color using a Cache-First strategy
  Stream<List<WallpaperModel>> getWallpapersByColorCacheFirst(
    String color, {
    int? limit,
  }) async* {
    final listKey = 'color_${color}_limit_${limit ?? 'all'}';

    // 1. Yield cached wallpapers first
    final cached = await _getCachedWallpapersList(listKey);
    if (cached.isNotEmpty) {
      yield cached;
    }

    // 2. Fetch fresh wallpapers from Firestore
    try {
      final fresh = await getWallpapersByColor(
        color,
        limit: limit,
      );
      yield fresh;
    } catch (e) {
      if (cached.isEmpty) {
        rethrow;
      }
    }
  }

  /// Get top wallpapers for a category (used on homepage)
  ///
  /// Returns a limited number of wallpapers for preview
  Future<List<WallpaperModel>> getTopWallpapers(
    String categoryId, {
    int limit = AppConstants.homeWallpapersLimit,
  }) async {
    return getWallpapersByCategory(categoryId, limit: limit);
  }


  /// Get a single wallpaper by ID
  Future<WallpaperModel?> getWallpaperById(String wallpaperId) async {
    try {
      if (_wallpaperCache.containsKey(wallpaperId)) {
        return _wallpaperCache[wallpaperId];
      }

      final doc = await _firestore
          .collection(AppConstants.wallpapersCollection)
          .doc(wallpaperId)
          .get();

      if (doc.exists) {
        final wallpaper = WallpaperModel.fromFirestore(doc);
        _wallpaperCache[wallpaperId] = wallpaper;
        return wallpaper;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch wallpaper: $e');
    }
  }

  /// Get all wallpapers (for admin purposes or full catalog)
  Future<List<WallpaperModel>> getAllWallpapers({int? limit}) async {
    try {
      Query query = _firestore
          .collection(AppConstants.wallpapersCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      final wallpapers = querySnapshot.docs
          .map((doc) => WallpaperModel.fromFirestore(doc))
          .toList();

      for (final w in wallpapers) {
        _wallpaperCache[w.id] = w;
      }

      final listKey = 'all_limit_${limit ?? 'all'}';
      await _cacheWallpapersList(listKey, wallpapers);

      return wallpapers;
    } catch (e) {
      throw Exception('Failed to fetch all wallpapers: $e');
    }
  }

  /// Increment view count for a wallpaper
  Future<void> incrementViews(String wallpaperId) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.wallpapersCollection)
          .doc(wallpaperId);

      await docRef.update({'views': FieldValue.increment(1)});
    } catch (e) {
      // Fail silently for metrics
      // print('Failed to increment views: $e');
    }
  }

  /// Increment download count for a wallpaper
  Future<void> incrementDownloads(String wallpaperId) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.wallpapersCollection)
          .doc(wallpaperId);

      await docRef.update({'downloads': FieldValue.increment(1)});
    } catch (e) {
      // print('Failed to increment downloads: $e');
    }
  }

  /// Increment like count for a wallpaper
  Future<void> incrementLikes(String wallpaperId) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.wallpapersCollection)
          .doc(wallpaperId);

      await docRef.update({'likes': FieldValue.increment(1)});
    } catch (e) {
      // print('Failed to increment likes: $e');
    }
  }

  /// Decrement like count for a wallpaper
  Future<void> decrementLikes(String wallpaperId) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.wallpapersCollection)
          .doc(wallpaperId);

      await docRef.update({'likes': FieldValue.increment(-1)});
    } catch (e) {
      // print('Failed to decrement likes: $e');
    }
  }

  /// Search wallpapers by title or tags
  Future<List<WallpaperModel>> searchWallpapers(String query) async {
    try {
      final lowerQuery = query.toLowerCase().trim();
      if (lowerQuery.isEmpty) return [];

      // For MVP: Fetch a limited number of recent wallpapers and filter client-side
      // Limiting to 400 prevents OOM crashes and massive Firestore read costs.
      // For a fully scalable solution, implement Firebase Search Extensions.
      final querySnapshot = await _firestore
          .collection(AppConstants.wallpapersCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(400)
          .get();

      final allWallpapers = querySnapshot.docs
          .map((doc) => WallpaperModel.fromFirestore(doc))
          .toList();

      for (final w in allWallpapers) {
        _wallpaperCache[w.id] = w;
      }

      return allWallpapers.where((wallpaper) {
        try {
          final titleMatch = wallpaper.title.toLowerCase().contains(lowerQuery);

          bool tagMatch = false;
          // Robust tag checking
          if (wallpaper.tags.isNotEmpty) {
            tagMatch = wallpaper.tags.any(
              (tag) => tag.toString().toLowerCase().contains(lowerQuery),
            );
          }

          bool colorMatch = false;
          if (wallpaper.colorPalette.isNotEmpty) {
            colorMatch = wallpaper.colorPalette.any(
              (color) => color.toString().toLowerCase().contains(lowerQuery),
            );
          }

          return titleMatch || tagMatch || colorMatch;
        } catch (e) {
          // Log error for specific item but don't crash search
          // print('Error filtering wallpaper ${wallpaper.id}: $e');
          return false;
        }
      }).toList();
    } catch (e) {
      throw Exception('Failed to search wallpapers: $e');
    }
  }
}
