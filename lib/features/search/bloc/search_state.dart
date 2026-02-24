import 'package:equatable/equatable.dart';
import '../../../core/data/models/wallpaper_model.dart';

abstract class SearchState extends Equatable {
  final List<String> history;
  const SearchState({this.history = const []});

  @override
  List<Object> get props => [history];
}

class SearchInitial extends SearchState {
  const SearchInitial({super.history});
}

class SearchLoading extends SearchState {
  const SearchLoading({super.history});
}

class SearchSuccess extends SearchState {
  final List<WallpaperModel> wallpapers;

  const SearchSuccess(this.wallpapers, {super.history});

  @override
  List<Object> get props => [wallpapers, history];
}

class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty(this.query, {super.history});

  @override
  List<Object> get props => [query, history];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message, {super.history});

  @override
  List<Object> get props => [message, history];
}
