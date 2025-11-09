import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokemonService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<Pokemon>> getPokemonsByGeneration(int generation) async {
    try {
      int startId = _getGenerationStartId(generation);
      int endId = _getGenerationEndId(generation);
      int limit = endId - startId + 1;

      final response = await http.get(
        Uri.parse('$baseUrl/pokemon?offset=${startId - 1}&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        List<Pokemon> pokemons = [];
        for (var result in results) {
          final pokemon = await getPokemonDetail(result['url']);
          pokemons.add(pokemon);
        }

        return pokemons;
      } else {
        throw Exception('Failed to load pokemons');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<PokemonEvolution>> getPokemonEvolutions(int pokemonId) async {
    try {
      // Primero obtener la cadena de evolución
      final speciesResponse = await http.get(
        Uri.parse('$baseUrl/pokemon-species/$pokemonId'),
      );
      if (speciesResponse.statusCode != 200) return [];

      final speciesData = json.decode(speciesResponse.body);
      final evolutionChainUrl = speciesData['evolution_chain']['url'];

      // Obtener la cadena de evolución
      final evolutionResponse = await http.get(Uri.parse(evolutionChainUrl));
      if (evolutionResponse.statusCode != 200) return [];

      final evolutionData = json.decode(evolutionResponse.body);
      return _parseEvolutionChain(evolutionData['chain']);
    } catch (e) {
      return [];
    }
  }

  List<PokemonEvolution> _parseEvolutionChain(Map<String, dynamic> chain) {
    List<PokemonEvolution> evolutions = [];

    void traverseChain(Map<String, dynamic> currentChain, String previousName) {
      final currentPokemon = currentChain['species'];
      final currentName = currentPokemon['name'];
      final currentId = int.parse(
        currentPokemon['url'].split('/').where((s) => s.isNotEmpty).last,
      );

      // Si no es el Pokémon inicial, añadir como evolución
      if (previousName.isNotEmpty) {
        String method = '';
        int level = 0;
        String item = '';

        if (currentChain['evolution_details'] != null &&
            currentChain['evolution_details'].isNotEmpty) {
          final details = currentChain['evolution_details'][0];
          method = details['trigger']['name'] ?? '';
          level = details['min_level'] ?? 0;
          item = details['item'] != null ? details['item']['name'] : '';
        }

        evolutions.add(
          PokemonEvolution(
            name: currentName,
            id: currentId,
            method: method,
            level: level,
            item: item,
          ),
        );
      }

      // Recorrer evoluciones siguientes
      if (currentChain['evolves_to'] != null) {
        for (var evolution in currentChain['evolves_to']) {
          traverseChain(evolution, currentName);
        }
      }
    }

    traverseChain(chain, '');
    return evolutions;
  }

  Future<List<Pokemon>> getPokemons({int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pokemon?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        List<Pokemon> pokemons = [];
        for (var result in results) {
          final pokemon = await getPokemonDetail(result['url']);
          pokemons.add(pokemon);
        }

        return pokemons;
      } else {
        throw Exception('Failed to load pokemons');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Pokemon> getPokemonDetail(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Pokemon.fromJson(data);
      } else {
        throw Exception('Failed to load pokemon detail');
      }
    } catch (e) {
      throw Exception('Error: $e');
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

  // Obtener todas las generaciones disponibles
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
