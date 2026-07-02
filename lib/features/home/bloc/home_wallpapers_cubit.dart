import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/data/models/wallpaper_model.dart';
import '../../../core/data/repositories/wallpaper_repository.dart';

abstract class HomeWallpapersState extends Equatable {
  const HomeWallpapersState();

  @override
  List<Object?> get props => [];
}

class HomeWallpapersInitial extends HomeWallpapersState {
  const HomeWallpapersInitial();
}

class HomeWallpapersLoading extends HomeWallpapersState {
  const HomeWallpapersLoading();
}

class HomeWallpapersLoaded extends HomeWallpapersState {
  final List<WallpaperModel> wallpapers;

  const HomeWallpapersLoaded(this.wallpapers);

  @override
  List<Object?> get props => [wallpapers];
}

class HomeWallpapersError extends HomeWallpapersState {
  final String message;

  const HomeWallpapersError(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeWallpapersCubit extends Cubit<HomeWallpapersState> {
  final WallpaperRepository _repository;

  HomeWallpapersCubit({required WallpaperRepository repository})
      : _repository = repository,
        super(const HomeWallpapersInitial());

  Future<void> loadHomeWallpapers() async {
    emit(const HomeWallpapersLoading());
    try {
      await for (final wallpapers in _repository.getAllWallpapersCacheFirst(limit: 50)) {
        emit(HomeWallpapersLoaded(wallpapers));
      }
    } catch (e) {
      emit(HomeWallpapersError(e.toString()));
    }
  }

  Future<void> refreshHomeWallpapers() async {
    try {
      final wallpapers = await _repository.getAllWallpapers(limit: 50);
      emit(HomeWallpapersLoaded(wallpapers));
    } catch (e) {
      emit(HomeWallpapersError(e.toString()));
    }
  }
}
