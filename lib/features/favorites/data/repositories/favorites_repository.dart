
import 'dart:convert';

import 'package:music_explorer_app/core/utils/local_storage_service.dart';
import 'package:music_explorer_app/features/home/data/models/song_model.dart';

class FavoritesRepository {
  final LocalStorageService _localStorageService;

  FavoritesRepository(this._localStorageService);

  List<int> getFavoriteTrackIds() {
    return _localStorageService.getFavoriteTrackIds();
  }

  Future<void> toggleFavorite(SongModel song) async {
    final ids = _localStorageService.getFavoriteTrackIds();
    final isAlreadyFavorite = ids.contains(song.trackId);

    await _localStorageService.toggleFavorite(song.trackId);

    if (isAlreadyFavorite) {
      return;
    }

    final jsonString = jsonEncode(song.toJson());
    await _localStorageService.saveFavoriteSongData(song.trackId, jsonString);
  }

  SongModel? loadCachedFavoriteSong(int trackId) {
    final jsonString = _localStorageService.getFavoriteSongData(trackId);
    if (jsonString == null) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(jsonString) as Map<String, dynamic>;
      return SongModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
