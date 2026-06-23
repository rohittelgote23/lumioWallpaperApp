import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/data/models/wallpaper_model.dart';
import '../../../core/data/repositories/wallpaper_repository.dart';

// Events
abstract class WallpaperEvent extends Equatable {
  const WallpaperEvent();

  @override
  List<Object> get props => [];
}

class LoadWallpapers extends WallpaperEvent {
  final String categoryId;
  final int? limit;
  final String? orderBy;

  const LoadWallpapers(this.categoryId, {this.limit = 20, this.orderBy});

  @override
  List<Object> get props => [categoryId, limit ?? 20, orderBy ?? ''];
}

class LoadMoreWallpapers extends WallpaperEvent {
  final String? orderBy;
  const LoadMoreWallpapers({this.orderBy});

  @override
  List<Object> get props => [orderBy ?? ''];
}

class LoadTopWallpapers extends WallpaperEvent {
  final String categoryId;
  final int limit;

  const LoadTopWallpapers(this.categoryId, {this.limit = 10});

  @override
  List<Object> get props => [categoryId, limit];
}

class RefreshWallpapers extends WallpaperEvent {
  final String categoryId;
  final String? orderBy;
  final int? limit;

  const RefreshWallpapers(this.categoryId, {this.orderBy, this.limit});

  @override
  List<Object> get props => [categoryId, orderBy ?? '', limit ?? 20];
}

class LoadAllWallpapers extends WallpaperEvent {
  final int limit;

  const LoadAllWallpapers({this.limit = 10});

  @override
  List<Object> get props => [limit];
}

// States
abstract class WallpaperState extends Equatable {
  const WallpaperState();

  @override
  List<Object?> get props => [];
}

class WallpaperInitial extends WallpaperState {
  const WallpaperInitial();
}

class WallpaperLoading extends WallpaperState {
  const WallpaperLoading();
}

class WallpaperLoaded extends WallpaperState {
  final List<WallpaperModel> wallpapers;
  final String categoryId;
  final bool hasReachedMax;
  final String orderBy;
  final String? errorMessage;

  const WallpaperLoaded(
    this.wallpapers,
    this.categoryId, {
    this.hasReachedMax = false,
    this.orderBy = 'createdAt',
    this.errorMessage,
  });

  WallpaperLoaded copyWith({
    List<WallpaperModel>? wallpapers,
    String? categoryId,
    bool? hasReachedMax,
    String? orderBy,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WallpaperLoaded(
      wallpapers ?? this.wallpapers,
      categoryId ?? this.categoryId,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      orderBy: orderBy ?? this.orderBy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        wallpapers,
        categoryId,
        hasReachedMax,
        orderBy,
        errorMessage,
      ];
}

class WallpaperError extends WallpaperState {
  final String message;

  const WallpaperError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class WallpaperBloc extends Bloc<WallpaperEvent, WallpaperState> {
  final WallpaperRepository _repository;

  WallpaperBloc({required WallpaperRepository repository})
    : _repository = repository,
      super(const WallpaperInitial()) {
    on<LoadWallpapers>(_onLoadWallpapers);
    on<LoadMoreWallpapers>(_onLoadMoreWallpapers);
    on<LoadTopWallpapers>(_onLoadTopWallpapers);
    on<RefreshWallpapers>(_onRefreshWallpapers);
    on<LoadAllWallpapers>(_onLoadAllWallpapers);
  }

  Future<void> _onLoadWallpapers(
    LoadWallpapers event,
    Emitter<WallpaperState> emit,
  ) async {
    emit(const WallpaperLoading());
    try {
      final limit = event.limit ?? 20;
      final orderBy = event.orderBy ?? 'createdAt';

      final wallpapers = await _repository.getWallpapersByCategory(
        event.categoryId,
        limit: limit,
        orderBy: orderBy,
      );
      emit(
        WallpaperLoaded(
          wallpapers,
          event.categoryId,
          hasReachedMax: wallpapers.length < limit,
          orderBy: orderBy,
        ),
      );
    } catch (e) {
      emit(WallpaperError(e.toString()));
    }
  }

  Future<void> _onLoadMoreWallpapers(
    LoadMoreWallpapers event,
    Emitter<WallpaperState> emit,
  ) async {
    final currentState = state;
    if (currentState is WallpaperLoaded && !currentState.hasReachedMax) {
      try {
        final lastWallpaper = currentState.wallpapers.isNotEmpty
            ? currentState.wallpapers.last
            : null;

        final limit = 20;
        final orderBy = event.orderBy ?? currentState.orderBy;

        final newWallpapers = await _repository.getWallpapersByCategory(
          currentState.categoryId,
          limit: limit,
          startAfter: lastWallpaper?.documentSnapshot,
          orderBy: orderBy,
        );

        emit(
          currentState.copyWith(
            wallpapers: List.of(currentState.wallpapers)..addAll(newWallpapers),
            hasReachedMax: newWallpapers.length < limit,
            orderBy: orderBy,
            clearError: true,
          ),
        );
      } catch (e) {
        emit(currentState.copyWith(errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onLoadTopWallpapers(
    LoadTopWallpapers event,
    Emitter<WallpaperState> emit,
  ) async {
    emit(const WallpaperLoading());
    try {
      final wallpapers = await _repository.getTopWallpapers(
        event.categoryId,
        limit: event.limit,
      );
      emit(WallpaperLoaded(wallpapers, event.categoryId));
    } catch (e) {
      emit(WallpaperError(e.toString()));
    }
  }

  Future<void> _onRefreshWallpapers(
    RefreshWallpapers event,
    Emitter<WallpaperState> emit,
  ) async {
    try {
      final currentState = state;
      final currentOrderBy = currentState is WallpaperLoaded
          ? currentState.orderBy
          : 'createdAt';
      final orderBy = event.orderBy ?? currentOrderBy;

      final limit = event.limit ?? 20;
      final wallpapers = await _repository.getWallpapersByCategory(
        event.categoryId,
        limit: limit,
        orderBy: orderBy,
      );
      emit(
        WallpaperLoaded(
          wallpapers,
          event.categoryId,
          hasReachedMax: wallpapers.length < limit,
          orderBy: orderBy,
        ),
      );
    } catch (e) {
      emit(WallpaperError(e.toString()));
    }
  }

  Future<void> _onLoadAllWallpapers(
    LoadAllWallpapers event,
    Emitter<WallpaperState> emit,
  ) async {
    emit(const WallpaperLoading());
    try {
      final wallpapers = await _repository.getAllWallpapers(limit: event.limit);
      emit(WallpaperLoaded(wallpapers, 'all'));
    } catch (e) {
      emit(WallpaperError(e.toString()));
    }
  }
}
