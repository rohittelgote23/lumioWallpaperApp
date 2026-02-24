import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../core/data/models/wallpaper_model.dart';
import '../../../core/data/repositories/downloads_repository.dart';
import '../../../core/data/repositories/wallpaper_repository.dart';

// States
abstract class DownloadsListState extends Equatable {
  const DownloadsListState();

  @override
  List<Object?> get props => [];
}

class DownloadsListLoading extends DownloadsListState {}

class DownloadsListLoaded extends DownloadsListState {
  final List<WallpaperModel> wallpapers;

  const DownloadsListLoaded(this.wallpapers);

  @override
  List<Object?> get props => [wallpapers];
}

class DownloadsListEmpty extends DownloadsListState {}

class DownloadsListError extends DownloadsListState {
  final String message;

  const DownloadsListError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class DownloadsListCubit extends Cubit<DownloadsListState> {
  final DownloadsRepository _downloadsRepo;
  final WallpaperRepository _wallpaperRepo;

  DownloadsListCubit()
    : _downloadsRepo = DownloadsRepository(),
      _wallpaperRepo = WallpaperRepository(),
      super(DownloadsListLoading());

  Future<void> loadDownloads() async {
    try {
      emit(DownloadsListLoading());
      final ids = await _downloadsRepo.getDownloadedWallpaperIds();

      if (ids.isEmpty) {
        emit(DownloadsListEmpty());
        return;
      }

      final wallpapers = <WallpaperModel>[];
      for (final id in ids) {
        // Optimization: In a real app, you might want to cache these models or fetch in batch
        // For now, fetching one by one is acceptable given the likely small number of downloads
        final wallpaper = await _wallpaperRepo.getWallpaperById(id);
        if (wallpaper != null) {
          wallpapers.add(wallpaper);
        }
      }

      if (wallpapers.isEmpty) {
        emit(DownloadsListEmpty());
      } else {
        emit(DownloadsListLoaded(wallpapers));
      }
    } catch (e) {
      emit(DownloadsListError('Failed to load downloads'));
    }
  }

  Future<void> deleteDownload(WallpaperModel wallpaper) async {
    try {
      // 1. Remove from Repository (SharedPrefs)
      await _downloadsRepo.removeDownload(wallpaper.id);

      // 2. Delete File (if it's an image in internal cache)
      if (!wallpaper.isVideo) {
        final cacheDir = await getApplicationCacheDirectory();
        final filename = 'lumio_${wallpaper.id}.jpg';
        final file = File('${cacheDir.path}/$filename');
        if (await file.exists()) {
          await file.delete();
        }
      } else {
        // For videos saved to Gallery, we can only remove the record in the app.
        // We cannot delete from Gallery without broad permissions and specific URI handling,
        // which Gal doesn't expose for deletion easily.
        // So we just untrack it.
      }

      // 3. Reload list
      loadDownloads();
    } catch (e) {
      // Even if deletion fails, try to reload
      loadDownloads();
    }
  }
}
