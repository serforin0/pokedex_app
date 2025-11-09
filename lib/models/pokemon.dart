class Pokemon {
  final int id;
  final String name;
  final List<String> types;
  final String imageUrl;
  final double height;
  final double weight;
  final List<String> abilities;
  final Map<String, int> stats;
  final String species;
  final String description;
  final int generation;
  final List<String> weaknesses;
  final String habitat;
  final String growthRate;
  final int baseExperience;
  final List<PokemonEvolution> evolutions;
  final String evolutionChainUrl;

  Pokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.imageUrl,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.stats,
    required this.species,
    required this.description,
    required this.generation,
    required this.weaknesses,
    required this.habitat,
    required this.growthRate,
    required this.baseExperience,
    required this.evolutions,
    required this.evolutionChainUrl,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // Obtener tipos
    List<String> types = [];
    for (var type in json['types']) {
      types.add(type['type']['name']);
    }

    // Obtener habilidades
    List<String> abilities = [];
    for (var ability in json['abilities']) {
      abilities.add(ability['ability']['name']);
    }

    // Obtener estadísticas
    Map<String, int> stats = {};
    for (var stat in json['stats']) {
      String statName = stat['stat']['name'];
      int statValue = stat['base_stat'];
      stats[statName] = statValue;
    }

    // Calcular debilidades basadas en tipos
    List<String> weaknesses = _calculateWeaknesses(types);

    return Pokemon(
      id: json['id'],
      name: json['name'],
      types: types,
      imageUrl: json['sprites']['front_default'] ?? '',
      height: (json['height'] ?? 0) / 10.0,
      weight: (json['weight'] ?? 0) / 10.0,
      abilities: abilities,
      stats: stats,
      species: json['species']['name'] ?? 'Unknown',
      description: '',
      generation: _getGeneration(json['id']),
      weaknesses: weaknesses,
      habitat: 'Unknown',
      growthRate: 'Unknown',
      baseExperience: json['base_experience'] ?? 0,
      evolutions: [], // Inicialmente vacío
      evolutionChainUrl: json['species']['url'] ?? '',
    );
  }

  bool get hasEvolutions => evolutions.isNotEmpty;
  bool get isFinalEvolution =>
      evolutions.every((evolution) => evolution.method.isEmpty);

  static int _getGeneration(int id) {
    if (id <= 151) return 1;
    if (id <= 251) return 2;
    if (id <= 386) return 3;
    if (id <= 493) return 4;
    if (id <= 649) return 5;
    if (id <= 721) return 6;
    if (id <= 809) return 7;
    if (id <= 905) return 8;
    return 9;
  }

  static List<String> _calculateWeaknesses(List<String> types) {
    Map<String, List<String>> typeWeaknesses = {
      'normal': ['fighting'],
      'fire': ['water', 'ground', 'rock'],
      'water': ['electric', 'grass'],
      'electric': ['ground'],
      'grass': ['fire', 'ice', 'poison', 'flying', 'bug'],
      'ice': ['fire', 'fighting', 'rock', 'steel'],
      'fighting': ['flying', 'psychic', 'fairy'],
      'poison': ['ground', 'psychic'],
      'ground': ['water', 'grass', 'ice'],
      'flying': ['electric', 'ice', 'rock'],
      'psychic': ['bug', 'ghost', 'dark'],
      'bug': ['fire', 'flying', 'rock'],
      'rock': ['water', 'grass', 'fighting', 'ground', 'steel'],
      'ghost': ['ghost', 'dark'],
      'dragon': ['ice', 'dragon', 'fairy'],
      'dark': ['fighting', 'bug', 'fairy'],
      'steel': ['fire', 'fighting', 'ground'],
      'fairy': ['poison', 'steel'],
    };

    Set<String> weaknesses = {};
    for (String type in types) {
      if (typeWeaknesses.containsKey(type)) {
        weaknesses.addAll(typeWeaknesses[type]!);
      }
    }
    return weaknesses.toList();
  }

  int get hp => stats['hp'] ?? 0;
  int get attack => stats['attack'] ?? 0;
  int get defense => stats['defense'] ?? 0;
  int get specialAttack => stats['special-attack'] ?? 0;
  int get specialDefense => stats['special-defense'] ?? 0;
  int get speed => stats['speed'] ?? 0;
  int get totalStats =>
      hp + attack + defense + specialAttack + specialDefense + speed;
}

class PokemonEvolution {
  final String name;
  final int id;
  final String method;
  final int level;
  final String item;

  PokemonEvolution({
    required this.name,
    required this.id,
    required this.method,
    required this.level,
    required this.item,
  });
}
