import 'package:equatable/equatable.dart';

class PokemonEvolution extends Equatable {
  final String name;
  final int id;
  final String method;
  final int level;
  final String item;
  final String imageUrl; // ✅ Nuevo campo

  const PokemonEvolution({
    required this.name,
    required this.id,
    required this.method,
    required this.level,
    required this.item,
    required this.imageUrl,
  });

  factory PokemonEvolution.fromJson(Map<String, dynamic> json) {
    return PokemonEvolution(
      name: json['name'] ?? '',
      id: json['id'] ?? 0,
      method: json['method'] ?? '',
      level: json['level'] ?? 0,
      item: json['item'] ?? '',
      imageUrl: json['imageUrl'] ??
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${json['id']}.png', // ✅ fallback por ID
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'method': method,
      'level': level,
      'item': item,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object> get props => [name, id, method, level, item, imageUrl];

  @override
  bool get stringify => true;
}
