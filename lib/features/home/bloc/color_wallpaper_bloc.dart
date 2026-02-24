import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/data/models/wallpaper_model.dart';
import '../../../core/data/repositories/wallpaper_repository.dart';

// Events
abstract class ColorWallpaperEvent extends Equatable {
  const ColorWallpaperEvent();

  @override
  List<Object> get props => [];
}

class LoadColorWallpapers extends ColorWallpaperEvent {
  final String colorName;
  final int? limit;

  const LoadColorWallpapers(this.colorName, {this.limit = 20});

  @override
  List<Object> get props => [colorName, limit ?? 20];
}

class LoadMoreColorWallpapers extends ColorWallpaperEvent {
  const LoadMoreColorWallpapers();
}

class RefreshColorWallpapers extends ColorWallpaperEvent {
  final String colorName;

  const RefreshColorWallpapers(this.colorName);

  @override
  List<Object> get props => [colorName];
}

// States
abstract class ColorWallpaperState extends Equatable {
  const ColorWallpaperState();

  @override
  List<Object> get props => [];
}

class ColorWallpaperInitial extends ColorWallpaperState {
  const ColorWallpaperInitial();
}

class ColorWallpaperLoading extends ColorWallpaperState {
  const ColorWallpaperLoading();
}

class ColorWallpaperLoaded extends ColorWallpaperState {
  final List<WallpaperModel> wallpapers;
  final String colorName;
  final bool hasReachedMax;

  const ColorWallpaperLoaded(
    this.wallpapers,
    this.colorName, {
    this.hasReachedMax = false,
  });

  ColorWallpaperLoaded copyWith({
    List<WallpaperModel>? wallpapers,
    String? colorName,
    bool? hasReachedMax,
  }) {
    return ColorWallpaperLoaded(
      wallpapers ?? this.wallpapers,
      colorName ?? this.colorName,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [wallpapers, colorName, hasReachedMax];
}

class ColorWallpaperError extends ColorWallpaperState {
  final String message;

  const ColorWallpaperError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class ColorWallpaperBloc
    extends Bloc<ColorWallpaperEvent, ColorWallpaperState> {
  final WallpaperRepository _repository;

  ColorWallpaperBloc({required WallpaperRepository repository})
    : _repository = repository,
      super(const ColorWallpaperInitial()) {
    on<LoadColorWallpapers>(_onLoadColorWallpapers);
    on<LoadMoreColorWallpapers>(_onLoadMoreColorWallpapers);
    on<RefreshColorWallpapers>(_onRefreshColorWallpapers);
  }

  Future<void> _onLoadColorWallpapers(
    LoadColorWallpapers event,
    Emitter<ColorWallpaperState> emit,
  ) async {
    emit(const ColorWallpaperLoading());
    try {
      final limit = event.limit ?? 20;
      final wallpapers = await _repository.getWallpapersByColor(
        event.colorName,
        limit: limit,
      );
      emit(
        ColorWallpaperLoaded(
          wallpapers,
          event.colorName,
          hasReachedMax: wallpapers.length < limit,
        ),
      );
    } catch (e) {
      emit(ColorWallpaperError(e.toString()));
    }
  }

  Future<void> _onLoadMoreColorWallpapers(
    LoadMoreColorWallpapers event,
    Emitter<ColorWallpaperState> emit,
  ) async {
    final currentState = state;
    if (currentState is ColorWallpaperLoaded && !currentState.hasReachedMax) {
      try {
        final lastWallpaper = currentState.wallpapers.isNotEmpty
            ? currentState.wallpapers.last
            : null;

        final limit = 20;
        final newWallpapers = await _repository.getWallpapersByColor(
          currentState.colorName,
          limit: limit,
          startAfter: lastWallpaper?.documentSnapshot,
        );

        emit(
          currentState.copyWith(
            wallpapers: List.of(currentState.wallpapers)..addAll(newWallpapers),
            hasReachedMax: newWallpapers.length < limit,
          ),
        );
      } catch (e) {
        emit(ColorWallpaperError(e.toString()));
      }
    }
  }

  Future<void> _onRefreshColorWallpapers(
    RefreshColorWallpapers event,
    Emitter<ColorWallpaperState> emit,
  ) async {
    try {
      final limit = 20;
      final wallpapers = await _repository.getWallpapersByColor(
        event.colorName,
        limit: limit,
      );
      emit(
        ColorWallpaperLoaded(
          wallpapers,
          event.colorName,
          hasReachedMax: wallpapers.length < limit,
        ),
      );
    } catch (e) {
      emit(ColorWallpaperError(e.toString()));
    }
  }
}
