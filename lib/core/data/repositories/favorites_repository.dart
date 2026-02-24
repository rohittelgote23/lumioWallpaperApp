import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants.dart';

/// Repository for managing favorite wallpapers using Hive (local) and Firestore (cloud)
class FavoritesRepository {
  late Box<String> _localFavoritesBox;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FavoritesRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  /// Initialize Hive and open the favorites box
  Future<void> init() async {
    // Ensure Hive is initialized only once in main.dart or check here
    if (!Hive.isAdapterRegistered(0)) {
      // Simple check, or rely on main.dart
      // Hive.initFlutter() should be called in main
    }
    _localFavoritesBox = await Hive.openBox<String>(AppConstants.favoritesBox);
  }

  /// Get current user ID or null
  String? get _userId => _firebaseAuth.currentUser?.uid;

  /// Get all favorite wallpaper IDs
  Future<List<String>> getFavorites() async {
    if (_userId != null) {
      try {
        final doc = await _firestore.collection('users').doc(_userId).get();
        if (doc.exists && doc.data()!.containsKey('favorites')) {
          return List<String>.from(doc.data()!['favorites']);
        }
        return [];
      } catch (e) {
        // Fallback to local or empty if offline/error
        // print('Error fetching cloud favorites: $e');
        return _localFavoritesBox.values.toList();
      }
    } else {
      return _localFavoritesBox.values.toList();
    }
  }

  /// Add a wallpaper to favorites
  Future<bool> addFavorite(String wallpaperId) async {
    try {
      if (_userId != null) {
        await _firestore.collection('users').doc(_userId).set({
          'favorites': FieldValue.arrayUnion([wallpaperId]),
        }, SetOptions(merge: true));
        return true;
      } else {
        if (!isFavoriteLocally(wallpaperId)) {
          await _localFavoritesBox.add(wallpaperId);
          return true;
        }
        return false;
      }
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  /// Remove a wallpaper from favorites
  Future<bool> removeFavorite(String wallpaperId) async {
    try {
      if (_userId != null) {
        await _firestore.collection('users').doc(_userId).update({
          'favorites': FieldValue.arrayRemove([wallpaperId]),
        });
        return true;
      } else {
        final key = _localFavoritesBox.keys.firstWhere(
          (key) => _localFavoritesBox.get(key) == wallpaperId,
          orElse: () => null,
        );

        if (key != null) {
          await _localFavoritesBox.delete(key);
          return true;
        }
        return false;
      }
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  /// Check if a wallpaper is in favorites (mostly for UI checks, might need async for cloud)
  /// For accurate cloud status, better to rely on the list loaded in Cubit.
  bool isFavoriteLocally(String wallpaperId) {
    return _localFavoritesBox.values.contains(wallpaperId);
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String wallpaperId) async {
    // This logic is slightly complex because we need to know if it's currently favorited.
    // We rely on the UI/Cubit passing the current state or checking here.
    // For simplicity, we'll check the list.

    final currentFavorites = await getFavorites();
    if (currentFavorites.contains(wallpaperId)) {
      await removeFavorite(wallpaperId);
      return false;
    } else {
      await addFavorite(wallpaperId);
      return true;
    }
  }

  /// Sync local favorites to cloud (Call this after login)
  Future<void> syncLocalFavoritesToCloud() async {
    if (_userId == null) return;

    final localFavorites = _localFavoritesBox.values.toList();
    if (localFavorites.isEmpty) return;

    try {
      await _firestore.collection('users').doc(_userId).set({
        'favorites': FieldValue.arrayUnion(localFavorites),
      }, SetOptions(merge: true));

      // Optional: Clear local favorites after sync, or keep them as cache?
      // For now, let's keep them or clear them. Clearning avoids duplicates implementation confusion.
      // But keeping them is good for offline. Let's keep them but primary source is cloud when logged in.
      // Actually, if we switch to guest, we might want to see them again?
      // Design decision: Valid valid concern. Let's NOT clear them, but maybe user wants a fresh start?
      // Standard app behavior: Merge and keep.

      // If we want to truly "move" them, we should clear local.
      // Let's clear local to avoid confusion when logging out (user expects their personal favorites to be gone from guest mode).
      await _localFavoritesBox.clear();
    } catch (e) {
      // print('Sync failed: $e');
    }
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    if (_userId != null) {
      await _firestore.collection('users').doc(_userId).update({
        'favorites': [],
      });
    } else {
      await _localFavoritesBox.clear();
    }
  }

  int getFavoritesCount() {
    return _localFavoritesBox.length; // This is only accurate for local
  }
}
