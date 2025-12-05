
import 'package:shared_preferences/shared_preferences.dart';

const String _kFavoritesKey = 'favoriteTrackIds';
String _favoriteSongKey(int trackId) => 'favoriteSong_\$trackId';
const String _kThemeKey = 'appThemeMode';

class LocalStorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<int> getFavoriteTrackIds() {
    final list = _prefs.getStringList(_kFavoritesKey) ?? [];
    return list.map((e) => int.tryParse(e) ?? -1).where((id) => id != -1).toList();
  }

  Future<void> toggleFavorite(int trackId) async {
    final currentList = getFavoriteTrackIds();

    if (currentList.contains(trackId)) {
      currentList.remove(trackId);
      await removeFavoriteSongData(trackId);
    } else {
      currentList.add(trackId);
    }

    await _prefs.setStringList(
      _kFavoritesKey,
      currentList.map((id) => id.toString()).toList(),
    );
  }

  Future<void> saveFavoriteSongData(int trackId, String songJson) async {
    await _prefs.setString(_favoriteSongKey(trackId), songJson);
  }

  String? getFavoriteSongData(int trackId) {
    return _prefs.getString(_favoriteSongKey(trackId));
  }

  Future<void> removeFavoriteSongData(int trackId) async {
    await _prefs.remove(_favoriteSongKey(trackId));
  }

  bool isDarkMode() {
    final stored = _prefs.getBool(_kThemeKey);
    
    // Default to dark theme for first-time users (or if no theme saved yet).
    if (stored == null) return true;

    return stored;
  }

  Future<void> saveThemeMode(bool isDark) async {
    await _prefs.setBool(_kThemeKey, isDark);
  }
}
