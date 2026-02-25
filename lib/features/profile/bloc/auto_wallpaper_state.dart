part of 'auto_wallpaper_cubit.dart';

class AutoWallpaperState extends Equatable {
  final bool isEnabled;
  final int targetScreen; // 1 = Home, 2 = Lock, 3 = Both
  final bool isLoading;

  const AutoWallpaperState({
    this.isEnabled = false,
    this.targetScreen = 3,
    this.isLoading = true,
  });

  AutoWallpaperState copyWith({
    bool? isEnabled,
    int? targetScreen,
    bool? isLoading,
  }) {
    return AutoWallpaperState(
      isEnabled: isEnabled ?? this.isEnabled,
      targetScreen: targetScreen ?? this.targetScreen,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [isEnabled, targetScreen, isLoading];
}
