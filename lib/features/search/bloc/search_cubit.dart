import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/repositories/wallpaper_repository.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final WallpaperRepository _repository;
  static const String _historyKey = 'search_history';

  SearchCubit({required WallpaperRepository repository})
    : _repository = repository,
      super(const SearchInitial()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    emit(SearchInitial(history: history));
  }

  Future<List<String>> _addToHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = List.from(state.history);

    // Remove if exists to move to top
    history.remove(query);
    // Add to top
    history.insert(0, query);
    // Limit to 6
    if (history.length > 6) {
      history = history.sublist(0, 6);
    }

    await prefs.setStringList(_historyKey, history);
    return history;
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    emit(SearchInitial(history: const []));
  }

  Future<void> removeFromHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = List.from(state.history);
    history.remove(query);
    await prefs.setStringList(_historyKey, history);

    // Maintain current state type but update history
    if (state is SearchSuccess) {
      emit(
        SearchSuccess((state as SearchSuccess).wallpapers, history: history),
      );
    } else if (state is SearchEmpty) {
      emit(SearchEmpty((state as SearchEmpty).query, history: history));
    } else if (state is SearchError) {
      emit(SearchError((state as SearchError).message, history: history));
    } else {
      emit(SearchInitial(history: history));
    }
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchInitial(history: state.history));
      return;
    }

    // Add to history and get updated list directly
    final history = await _addToHistory(query);

    emit(SearchLoading(history: history));

    try {
      final results = await _repository.searchWallpapers(query);

      if (results.isEmpty) {
        emit(SearchEmpty(query, history: history));
      } else {
        emit(SearchSuccess(results, history: history));
      }
    } catch (e) {
      emit(SearchError('Failed to search: $e', history: history));
    }
  }

  void clearSearch() {
    emit(SearchInitial(history: state.history));
  }
}
