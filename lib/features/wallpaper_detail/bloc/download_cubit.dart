import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:lumiowalls/core/data/repositories/downloads_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'dart:io';
import '../../../core/utils/permission_helper.dart';
import '../../../core/utils/constants.dart';
import '../../../core/data/repositories/wallpaper_repository.dart';

// States
abstract class DownloadState extends Equatable {
  const DownloadState();

  @override
  List<Object?> get props => [];
}

class DownloadInitial extends DownloadState {
  const DownloadInitial();
}

class DownloadInProgress extends DownloadState {
  final double progress;

  const DownloadInProgress(this.progress);

  @override
  List<Object?> get props => [progress];
}

class DownloadChecked extends DownloadState {
  final bool isDownloaded;

  const DownloadChecked(this.isDownloaded);

  @override
  List<Object?> get props => [isDownloaded];
}

class DownloadSuccess extends DownloadState {
  final String message;
  final bool isDownloaded;

  const DownloadSuccess(this.message) : isDownloaded = true;

  @override
  List<Object?> get props => [message, isDownloaded];
}

class DownloadError extends DownloadState {
  final String message;

  const DownloadError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class DownloadCubit extends Cubit<DownloadState> {
  final Dio _dio;
  final WallpaperRepository? _wallpaperRepository;

  DownloadCubit({Dio? dio, WallpaperRepository? wallpaperRepository})
    : _dio = dio ?? Dio(),
      _wallpaperRepository = wallpaperRepository,
      super(const DownloadInitial());

  /// Download wallpaper to device gallery
  ///
  /// Requests storage permission, downloads the image, and saves to gallery
  Future<void> downloadWallpaper(String url, String filename) async {
    try {
      // Check and request storage permission
      final hasPermission = await PermissionHelper.requestStoragePermission();

      if (!hasPermission) {
        emit(const DownloadError(AppConstants.permissionError));
        return;
      }

      // Start download
      emit(const DownloadInProgress(0.0));

      // Determine file processing based on type
      final isVideo =
          filename.toLowerCase().endsWith('.mp4') ||
          filename.toLowerCase().endsWith('.mov');

      if (isVideo) {
        // VIDEO: Save to Gallery via Gal
        // Get temporary directory for download
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/$filename';

        try {
          await _downloadFile(url, filePath);
          await Gal.putVideo(filePath, album: 'Lumiowalls');
        } finally {
          // Clean up temporary file
          _deleteFile(filePath);
        }
      } else {
        // IMAGE: Save to Internal Cache
        final cacheDir = await getApplicationCacheDirectory();
        final filePath = '${cacheDir.path}/$filename';

        await _downloadFile(url, filePath);
        // No need to delete, it stays in cache as requested
      }

      // Track this download in local storage
      // Extract wallpaper ID from filename (e.g., lumio_abc123.jpg -> abc123)
      final wallpaperId = filename.replaceAll('lumio_', '').split('.').first;
      try {
        final downloadsRepo = DownloadsRepository();
        await downloadsRepo.addDownload(wallpaperId);

        // Increment global download count
        if (_wallpaperRepository != null) {
          _wallpaperRepository.incrementDownloads(wallpaperId);
        }
      } catch (e) {
        debugPrint('Error tracking download: $e');
      }

      final successMessage = isVideo
          ? 'Saved to Gallery'
          : 'Saved to internal cache';

      emit(DownloadSuccess(successMessage));
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          emit(const DownloadError('Download timeout. Please try again.'));
        } else if (e.type == DioExceptionType.connectionError) {
          emit(const DownloadError(AppConstants.networkError));
        } else {
          emit(const DownloadError(AppConstants.downloadError));
        }
      } else {
        emit(DownloadError('Download failed: ${e.toString()}'));
      }
    }
  }

  /// Check if wallpaper is already downloaded
  Future<void> checkDownloadStatus(String wallpaperId) async {
    try {
      final downloadsRepo = DownloadsRepository();
      final isDownloaded = await downloadsRepo.isWallpaperDownloaded(
        wallpaperId,
      );
      emit(DownloadChecked(isDownloaded));
    } catch (e) {
      debugPrint('Error checking download status: $e');
      emit(const DownloadChecked(false));
    }
  }

  Future<void> _downloadFile(String url, String filePath) async {
    await _dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          final progress = received / total;
          emit(DownloadInProgress(progress));
        }
      },
      options: Options(
        receiveTimeout: const Duration(
          milliseconds: AppConstants.downloadTimeout,
        ),
      ),
    );
  }

  Future<void> _deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (e) {
        debugPrint('Error deleting temp file: $e');
      }
    }
  }

  /// Reset download state
  void reset() {
    emit(const DownloadInitial());
  }
}
