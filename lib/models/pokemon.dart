// lib/models/pokemon.dart (volver a la versión original)
import 'package:equatable/equatable.dart';

class Pokemon extends Equatable {
  final int id;
  final String name;
  final List<String> types;
  final String imageUrl;
  final double height;
  final double weight;
  final List<String> abilities;
  final String species;
  final int baseExperience;
  final String growthRate;
  final int hp;
  final int attack;
  final int defense;
  final int specialAttack;
  final int specialDefense;
  final int speed;
  final List<String> weaknesses;

  const Pokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.imageUrl,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.species,
    required this.baseExperience,
    required this.growthRate,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.specialAttack,
    required this.specialDefense,
    required this.speed,
    required this.weaknesses,
  });

  int get totalStats =>
      hp + attack + defense + specialAttack + specialDefense + speed;

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final types = (json['types'] as List).map((type) {
      return (type['type']['name'] as String).toLowerCase();
    }).toList();

    return Pokemon(
      id: json['id'],
      name: json['name'],
      types: types,
      imageUrl: json['sprites']['front_default'] ?? '',
      height: (json['height'] ?? 0) / 10.0,
      weight: (json['weight'] ?? 0) / 10.0,
      abilities: (json['abilities'] as List)
          .map((ability) => ability['ability']['name'] as String)
          .toList(),
      species: json['species']['name'] ?? '',
      baseExperience: json['base_experience'] ?? 0,
      growthRate: 'medium',
      hp: json['stats'][0]['base_stat'],
      attack: json['stats'][1]['base_stat'],
      defense: json['stats'][2]['base_stat'],
      specialAttack: json['stats'][3]['base_stat'],
      specialDefense: json['stats'][4]['base_stat'],
      speed: json['stats'][5]['base_stat'],
      weaknesses: _calculateWeaknesses(json['types']),
    );
  }

  static List<String> calculateWeaknesses(List<dynamic> types) {
    return _calculateWeaknesses(types);
  }

  static List<String> _calculateWeaknesses(List<dynamic> types) {
    // ... (mantener el mismo código)
    final weaknesses = <String>[];

    for (var type in types) {
      final typeName = (type['type']['name'] as String).toLowerCase();

      switch (typeName) {
        case 'fire':
          weaknesses.addAll(['water', 'ground', 'rock']);
          break;
        case 'water':
          weaknesses.addAll(['electric', 'grass']);
          break;
        case 'grass':
          weaknesses.addAll(['fire', 'ice', 'poison', 'flying', 'bug']);
          break;
        case 'electric':
          weaknesses.addAll(['ground']);
          break;
        case 'ice':
          weaknesses.addAll(['fire', 'fighting', 'rock', 'steel']);
          break;
        case 'fighting':
          weaknesses.addAll(['flying', 'psychic', 'fairy']);
          break;
        case 'poison':
          weaknesses.addAll(['ground', 'psychic']);
          break;
        case 'ground':
          weaknesses.addAll(['water', 'grass', 'ice']);
          break;
        case 'flying':
          weaknesses.addAll(['electric', 'ice', 'rock']);
          break;
        case 'psychic':
          weaknesses.addAll(['bug', 'ghost', 'dark']);
          break;
        case 'bug':
          weaknesses.addAll(['fire', 'flying', 'rock']);
          break;
        case 'rock':
          weaknesses.addAll(['water', 'grass', 'fighting', 'ground', 'steel']);
          break;
        case 'ghost':
          weaknesses.addAll(['ghost', 'dark']);
          break;
        case 'dragon':
          weaknesses.addAll(['ice', 'dragon', 'fairy']);
          break;
        case 'dark':
          weaknesses.addAll(['fighting', 'bug', 'fairy']);
          break;
        case 'steel':
          weaknesses.addAll(['fire', 'fighting', 'ground']);
          break;
        case 'fairy':
          weaknesses.addAll(['poison', 'steel']);
          break;
      }
    }

    return weaknesses.toSet().toList();
  }

  // ✅ Conversión a JSON (para guardar en Hive)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'types': types,
      'imageUrl': imageUrl,
      'height': height,
      'weight': weight,
    };
  }

  @override
  List<Object> get props => [
        id,
        name,
        types,
        imageUrl,
        height,
        weight,
        abilities,
        species,
        baseExperience,
        growthRate,
        hp,
        attack,
        defense,
        specialAttack,
        specialDefense,
        speed,
        weaknesses,
      ];

  @override
  bool get stringify => true;
}
