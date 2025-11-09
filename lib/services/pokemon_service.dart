import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';
import '../models/pokemon_evolution.dart';

class PokemonService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<Pokemon>> getPokemons({int limit = 50, int offset = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pokemon?limit=$limit&offset=$offset'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        List<Pokemon> pokemons = [];
        for (var result in results) {
          try {
            final pokemon = await getPokemonDetail(result['url']);
            pokemons.add(pokemon);
          } catch (e) {
            print('Error loading Pokémon from ${result['url']}: $e');
            continue;
          }
        }

        return pokemons;
      } else {
        throw Exception('Failed to load pokemons: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Pokemon>> getPokemonsByGeneration(int generation) async {
    try {
      final startId = _getGenerationStartId(generation);
      final endId = _getGenerationEndId(generation);

      print('Loading generation $generation: Pokémon $startId to $endId');

      List<Pokemon> pokemons = [];
      for (int id = startId; id <= endId; id++) {
        try {
          final pokemon = await getPokemonById(id);
          pokemons.add(pokemon);
          print('Loaded Pokémon #$id: ${pokemon.name}');
        } catch (e) {
          print('Error loading Pokémon #$id: $e');
          continue;
        }
      }

      print(
          'Successfully loaded ${pokemons.length} Pokémon for generation $generation');
      return pokemons;
    } catch (e) {
      throw Exception('Error loading generation $generation: $e');
    }
  }

  Future<List<PokemonEvolution>> getPokemonEvolutions(int pokemonId) async {
    try {
      final speciesResponse = await http.get(
        Uri.parse('$baseUrl/pokemon-species/$pokemonId'),
      );
      if (speciesResponse.statusCode != 200) return [];

      final speciesData = json.decode(speciesResponse.body);
      final evolutionChainUrl = speciesData['evolution_chain']['url'];

      final evolutionResponse = await http.get(Uri.parse(evolutionChainUrl));
      if (evolutionResponse.statusCode != 200) return [];

      final evolutionData = json.decode(evolutionResponse.body);
      final chain = evolutionData['chain'];

      return _parseEvolutionChain(chain);
    } catch (e) {
      return [];
    }
  }

  List<PokemonEvolution> _parseEvolutionChain(Map<String, dynamic> chain) {
    final evolutions = <PokemonEvolution>[];

    var current = chain;
    while (current['evolves_to'] != null &&
        (current['evolves_to'] as List).isNotEmpty) {
      final nextEvolution = (current['evolves_to'] as List).first;
      final evolutionDetails = nextEvolution['evolution_details'] != null &&
              (nextEvolution['evolution_details'] as List).isNotEmpty
          ? (nextEvolution['evolution_details'] as List).first
          : null;

      final evolution = PokemonEvolution(
        name: (nextEvolution['species']['name'] as String?) ?? '',
        id: _extractIdFromUrl(
            (nextEvolution['species']['url'] as String?) ?? ''),
        method: (evolutionDetails?['trigger']['name'] as String?) ?? '',
        level: (evolutionDetails?['min_level'] as int?) ?? 0,
        item: (evolutionDetails?['item']?['name'] as String?) ?? '',
      );

      evolutions.add(evolution);
      current = nextEvolution;
    }

    return evolutions;
  }

  int _extractIdFromUrl(String url) {
    try {
      final segments = url.split('/');
      return int.parse(segments[segments.length - 2]);
    } catch (e) {
      return 0;
    }
  }

  Future<Pokemon> getPokemonDetail(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Pokemon.fromJson(data);
      } else {
        throw Exception(
            'Failed to load pokemon detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading Pokémon detail: $e');
    }
  }

  Future<Pokemon> getPokemonById(int id) async {
    return await getPokemonDetail('$baseUrl/pokemon/$id');
  }

  int _getGenerationStartId(int generation) {
    switch (generation) {
      case 1:
        return 1;
      case 2:
        return 152;
      case 3:
        return 252;
      case 4:
        return 387;
      case 5:
        return 494;
      case 6:
        return 650;
      case 7:
        return 722;
      case 8:
        return 810;
      case 9:
        return 906;
      default:
        return 1;
    }
  }

  int _getGenerationEndId(int generation) {
    switch (generation) {
      case 1:
        return 151;
      case 2:
        return 251;
      case 3:
        return 386;
      case 4:
        return 493;
      case 5:
        return 649;
      case 6:
        return 721;
      case 7:
        return 809;
      case 8:
        return 905;
      case 9:
        return 1025;
      default:
        return 151;
    }
  }

  List<int> getAvailableGenerations() {
    return [1, 2, 3, 4, 5, 6, 7, 8, 9];
  }

  String getGenerationName(int generation) {
    switch (generation) {
      case 1:
        return 'Kanto';
      case 2:
        return 'Johto';
      case 3:
        return 'Hoenn';
      case 4:
        return 'Sinnoh';
      case 5:
        return 'Unova';
      case 6:
        return 'Kalos';
      case 7:
        return 'Alola';
      case 8:
        return 'Galar';
      case 9:
        return 'Paldea';
      default:
        return 'Unknown';
    }
  }
}
