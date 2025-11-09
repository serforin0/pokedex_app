import 'package:hive/hive.dart';

class FavoriteService {
  static const String _favoritesBox = 'favorites';

  Future<Box<int>> _openBox() async {
    return await Hive.openBox<int>(_favoritesBox);
  }

  Future<void> toggleFavorite(int pokemonId) async {
    final box = await _openBox();
    if (box.containsKey(pokemonId)) {
      await box.delete(pokemonId);
    } else {
      await box.put(pokemonId, pokemonId);
    }
  }

  Future<bool> isFavorite(int pokemonId) async {
    final box = await _openBox();
    return box.containsKey(pokemonId);
  }

  Future<List<int>> getFavorites() async {
    final box = await _openBox();
    return box.keys.cast<int>().toList();
  }
}
