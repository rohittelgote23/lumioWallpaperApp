import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumiowalls/core/services/wallpaper_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'set_wallpaper_state.dart';

class SetWallpaperCubit extends Cubit<SetWallpaperState> {
  final WallpaperService _wallpaperService;

  SetWallpaperCubit({WallpaperService? wallpaperService})
    : _wallpaperService = wallpaperService ?? WallpaperService(),
      super(SetWallpaperInitial());

  /// Sets the wallpaper from a URL.
  Future<void> setWallpaper(
    String url,
    int location, {
    BuildContext? context,
  }) async {
    try {
      emit(SetWallpaperLoading());

      final file = await _getOrDownloadFile(url, isVideo: false);
      if (file == null) {
        emit(const SetWallpaperError('Failed to prepare wallpaper file'));
        return;
      }

      final result = await _wallpaperService.setStaticWallpaper(
        filePath: file.path,
        location: location,
        context: context,
      );

      emit(SetWallpaperSuccess(result));
    } catch (e) {
      emit(SetWallpaperError('Error: $e'));
    }
  }

  /// Gets the file from URL without setting it (for cropping)
  Future<File?> getWallpaperFile(String url) async {
    try {
      return await _getOrDownloadFile(url, isVideo: false);
    } catch (e) {
      return null;
    }
  }

  /// Sets wallpaper from a local file path (after cropping)
  Future<void> setWallpaperFromFile(
    String filePath,
    int location, {
    BuildContext? context,
  }) async {
    try {
      emit(SetWallpaperLoading());
      final result = await _wallpaperService.setStaticWallpaper(
        filePath: filePath,
        location: location,
        context: context,
      );
      emit(SetWallpaperSuccess(result));
    } catch (e) {
      emit(SetWallpaperError('Error: $e'));
    }
  }

  Future<void> setLiveWallpaper(String url) async {
    emit(
      const SetWallpaperError(
        'Couldn\'t set live wallpaper on your system. Try downloading and using system settings.',
      ),
    );
  }

  Future<void> openLiveWallpaperChooser() async {
    // Optional: Show message or handle if needed
  }

  Future<File?> _getOrDownloadFile(String url, {required bool isVideo}) async {
    try {
      final dir = await getApplicationSupportDirectory();
      // Simple logic for filename
      final uri = Uri.parse(url);
      String filename = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : 'wallpaperyyy';

      // Ensure extension
      final ext = isVideo ? '.mp4' : '.jpg';
      if (!filename.endsWith(ext) && !filename.contains('.')) {
        filename = '$filename$ext';
      }

      final savePath = '${dir.path}/$filename';
      final file = File(savePath);

      if (await file.exists()) {
        return file;
      }

      await Dio().download(url, savePath);

      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      // print('Download error: $e');
      return null;
    }
  }
}
