import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/data/repositories/favorites_repository.dart';
import '../../../core/data/repositories/wallpaper_repository.dart';
import '../../../core/utils/constants.dart';

// State
class FavoritesState extends Equatable {
  final List<String> favoriteIds;
  final bool isLoading;
  final String? message;

  const FavoritesState({
    this.favoriteIds = const [],
    this.isLoading = false,
    this.message,
  });

  FavoritesState copyWith({
    List<String>? favoriteIds,
    bool? isLoading,
    String? message,
  }) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }

  @override
  List<Object?> get props => [favoriteIds, isLoading, message];
}

// Cubit
class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _repository;
  final WallpaperRepository? _wallpaperRepository;

  FavoritesCubit({
    required FavoritesRepository repository,
    WallpaperRepository? wallpaperRepository,
  }) : _repository = repository,
       _wallpaperRepository = wallpaperRepository,
       super(const FavoritesState());

  /// Initialize and load favorites from local storage (or cloud if logged in)
  Future<void> loadFavorites() async {
    emit(state.copyWith(isLoading: true));
    try {
      await _repository.init();
      final favorites = await _repository.getFavorites();
      emit(state.copyWith(favoriteIds: favorites, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, message: 'Failed to load favorites'),
      );
    }
  }

  /// Toggle favorite status for a wallpaper
  /// Returns true if added, false if removed
  Future<bool> toggleFavorite(String wallpaperId) async {
    try {
      final wasAdded = await _repository.toggleFavorite(wallpaperId);
      final updatedFavorites = await _repository.getFavorites();

      // Update global like count
      if (_wallpaperRepository != null) {
        if (wasAdded) {
          _wallpaperRepository.incrementLikes(wallpaperId);
        } else {
          _wallpaperRepository.decrementLikes(wallpaperId);
        }
      }

      emit(
        state.copyWith(
          favoriteIds: updatedFavorites,
          message: wasAdded
              ? AppConstants.favoriteAdded
              : AppConstants.favoriteRemoved,
        ),
      );

      return wasAdded;
    } catch (e) {
      emit(state.copyWith(message: 'Failed to update favorite'));
      return false;
    }
  }

  /// Add a wallpaper to favorites
  Future<void> addFavorite(String wallpaperId) async {
    try {
      await _repository.addFavorite(wallpaperId);
      final updatedFavorites = await _repository.getFavorites();
      emit(
        state.copyWith(
          favoriteIds: updatedFavorites,
          message: AppConstants.favoriteAdded,
        ),
      );
    } catch (e) {
      emit(state.copyWith(message: 'Failed to add favorite'));
    }
  }

  /// Remove a wallpaper from favorites
  Future<void> removeFavorite(String wallpaperId) async {
    try {
      await _repository.removeFavorite(wallpaperId);
      final updatedFavorites = await _repository.getFavorites();
      emit(
        state.copyWith(
          favoriteIds: updatedFavorites,
          message: AppConstants.favoriteRemoved,
        ),
      );
    } catch (e) {
      emit(state.copyWith(message: 'Failed to remove favorite'));
    }
  }

  /// Check if a wallpaper is favorited
  bool isFavorite(String wallpaperId) {
    return state.favoriteIds.contains(wallpaperId);
  }

  /// Clear all favorites (Caution: this deletes data)
  Future<void> clearFavorites() async {
    try {
      await _repository.clearFavorites();
      emit(state.copyWith(favoriteIds: [], message: 'All favorites cleared'));
    } catch (e) {
      emit(state.copyWith(message: 'Failed to clear favorites'));
    }
  }

  /// Sync local favorites to cloud and reload
  Future<void> syncAndReload() async {
    emit(state.copyWith(isLoading: true));
    try {
      await _repository.syncLocalFavoritesToCloud();
      final favorites = await _repository.getFavorites();
      emit(state.copyWith(favoriteIds: favorites, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, message: 'Failed to sync favorites'),
      );
    }
  }

  /// Get favorites count
  int getFavoritesCount() {
    return state.favoriteIds.length;
  }
}
