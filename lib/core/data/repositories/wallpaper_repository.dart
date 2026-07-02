import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/wallpaper_model.dart';
import '../../utils/constants.dart';

/// Repository for wallpaper-related operations
///
/// Handles all Firestore interactions for wallpapers
/// Provides methods to fetch wallpapers by category with pagination support
class WallpaperRepository with WidgetsBindingObserver {
  final FirebaseFirestore _firestore;
  final Map<String, WallpaperModel> _wallpaperCache = {};
  Timer? _syncTimer;

  WallpaperRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    WidgetsBinding.instance.addObserver(this);
    _syncTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      syncBufferedUpdates();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      syncBufferedUpdates();
    }
  }

  void dispose() {
    _syncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> syncBufferedUpdates() async {
    try {
      final box = await Hive.openBox<int>('buffered_updates');
      if (box.isEmpty) return;

      final keys = List<String>.from(box.keys);
      final Map<String, Map<String, int>> updatesByWallpaper = {};

      for (final key in keys) {
        final parts = key.split('_');
        if (parts.length < 2) continue;
        final type = parts[0]; // 'views', 'downloads', 'likes'
        final id = parts.sublist(1).join('_');
        final val = box.get(key) ?? 0;

        if (val == 0) continue;

        updatesByWallpaper.putIfAbsent(id, () => {});
        updatesByWallpaper[id]![type] = val;
      }

      if (updatesByWallpaper.isEmpty) return;

      final batch = _firestore.batch();
      int count = 0;

      for (final entry in updatesByWallpaper.entries) {
        final id = entry.key;
        final fields = entry.value;

        final docRef = _firestore.collection(AppConstants.wallpapersCollection).doc(id);
        final Map<String, dynamic> updateData = {};
        fields.forEach((type, val) {
          updateData[type] = FieldValue.increment(val);
        });

        batch.update(docRef, updateData);
        count++;

        if (count >= 500) {
          await batch.commit();
          // Reset count since we committed the batch, but in practice session changes won't exceed 500 documents.
          count = 0;
        }
      }

      if (count > 0) {
        await batch.commit();
      }

      // Clear the box for successfully synced updates
      await box.clear();
    } catch (e) {
      // Fail silently to not disrupt the user
    }
  }

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
      // 1. Update in-memory cache immediately so UI reflects it
      if (_wallpaperCache.containsKey(wallpaperId)) {
        final current = _wallpaperCache[wallpaperId]!;
        _wallpaperCache[wallpaperId] = current.copyWith(views: current.views + 1);
      }

      // 2. Increment in local buffer
      final box = await Hive.openBox<int>('buffered_updates');
      final currentVal = box.get('views_$wallpaperId') ?? 0;
      await box.put('views_$wallpaperId', currentVal + 1);
    } catch (e) {
      // Fail silently for metrics
    }
  }

  /// Increment download count for a wallpaper
  Future<void> incrementDownloads(String wallpaperId) async {
    try {
      // 1. Update in-memory cache immediately so UI reflects it
      if (_wallpaperCache.containsKey(wallpaperId)) {
        final current = _wallpaperCache[wallpaperId]!;
        _wallpaperCache[wallpaperId] = current.copyWith(downloads: current.downloads + 1);
      }

      // 2. Increment in local buffer
      final box = await Hive.openBox<int>('buffered_updates');
      final currentVal = box.get('downloads_$wallpaperId') ?? 0;
      await box.put('downloads_$wallpaperId', currentVal + 1);
    } catch (e) {
      // Fail silently
    }
  }

  /// Increment like count for a wallpaper
  Future<void> incrementLikes(String wallpaperId) async {
    try {
      // 1. Update in-memory cache immediately so UI reflects it
      if (_wallpaperCache.containsKey(wallpaperId)) {
        final current = _wallpaperCache[wallpaperId]!;
        _wallpaperCache[wallpaperId] = current.copyWith(likes: current.likes + 1);
      }

      // 2. Increment in local buffer
      final box = await Hive.openBox<int>('buffered_updates');
      final currentVal = box.get('likes_$wallpaperId') ?? 0;
      await box.put('likes_$wallpaperId', currentVal + 1);
    } catch (e) {
      // Fail silently
    }
  }

  /// Decrement like count for a wallpaper
  Future<void> decrementLikes(String wallpaperId) async {
    try {
      // 1. Update in-memory cache immediately so UI reflects it
      if (_wallpaperCache.containsKey(wallpaperId)) {
        final current = _wallpaperCache[wallpaperId]!;
        _wallpaperCache[wallpaperId] = current.copyWith(likes: current.likes - 1);
      }

      // 2. Decrement in local buffer
      final box = await Hive.openBox<int>('buffered_updates');
      final currentVal = box.get('likes_$wallpaperId') ?? 0;
      await box.put('likes_$wallpaperId', currentVal - 1);
    } catch (e) {
      // Fail silently
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
