import 'package:hive_flutter/hive_flutter.dart';
import '../models/pokemon.dart';

class LocalStorageService {
  static const String _pokemonCacheBox = 'pokemonCache';
  static const String _favoritesBox = 'favorites';

  Future<Box> _openBox(String name) async {
    if (!Hive.isBoxOpen(name)) {
      return await Hive.openBox(name);
    }
    return Hive.box(name);
  }

  Future<void> cachePokemons(List<Pokemon> pokemons) async {
    final box = await _openBox(_pokemonCacheBox);
    await box.put('cachedPokemons', pokemons.map((p) => p.toJson()).toList());
  }

  Future<List<Pokemon>> getCachedPokemons() async {
    final box = await _openBox(_pokemonCacheBox);
    final cachedData = box.get('cachedPokemons', defaultValue: []);
    return (cachedData as List)
        .map((data) => Pokemon.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }

  Future<Pokemon?> getCachedPokemon(int id) async {
    final box = await _openBox(_pokemonCacheBox);
    final cachedData = box.get('cachedPokemons', defaultValue: []);
    for (var data in cachedData) {
      final pokemon = Pokemon.fromJson(Map<String, dynamic>.from(data));
      if (pokemon.id == id) return pokemon;
    }
    return null;
  }

  Future<void> saveFavorite(Pokemon pokemon) async {
    final box = await _openBox(_favoritesBox);
    await box.put(pokemon.id, pokemon.toJson());
  }

  Future<void> removeFavorite(int id) async {
    final box = await _openBox(_favoritesBox);
    await box.delete(id);
  }

  Future<List<Pokemon>> getFavorites() async {
    final box = await _openBox(_favoritesBox);
    return box.values
        .map((data) => Pokemon.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }
}
