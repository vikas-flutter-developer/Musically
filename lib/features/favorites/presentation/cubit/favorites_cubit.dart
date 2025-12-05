
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_explorer_app/features/home/data/models/song_model.dart';
import '../../data/repositories/favorites_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesCubit(this._repository) : super(const FavoritesState()) {
    _loadFavorites();
  }

  void _loadFavorites() {
    final ids = _repository.getFavoriteTrackIds();
    emit(state.copyWith(favoriteTrackIds: ids));
  }

  Future<void> toggleFavorite(SongModel song) async {
    await _repository.toggleFavorite(song);
    _loadFavorites(); 
  }

  bool isFavorite(int trackId) {
    return state.favoriteTrackIds.contains(trackId);
  }
}
