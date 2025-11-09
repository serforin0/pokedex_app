import 'package:equatable/equatable.dart';

class PokemonEvolution extends Equatable {
  final String name;
  final int id;
  final String method;
  final int level;
  final String item;

  const PokemonEvolution({
    required this.name,
    required this.id,
    required this.method,
    required this.level,
    required this.item,
  });

  @override
  List<Object> get props => [name, id, method, level, item];

  @override
  bool get stringify => true;
}
