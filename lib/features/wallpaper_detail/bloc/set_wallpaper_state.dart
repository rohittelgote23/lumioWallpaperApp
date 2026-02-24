import 'package:equatable/equatable.dart';

abstract class SetWallpaperState extends Equatable {
  const SetWallpaperState();

  @override
  List<Object> get props => [];
}

class SetWallpaperInitial extends SetWallpaperState {}

class SetWallpaperLoading extends SetWallpaperState {}

class SetWallpaperSuccess extends SetWallpaperState {
  final String message;

  const SetWallpaperSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class SetWallpaperError extends SetWallpaperState {
  final String message;

  const SetWallpaperError(this.message);

  @override
  List<Object> get props => [message];
}
