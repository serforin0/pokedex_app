part of 'pokemon_detail_bloc.dart';

@immutable
abstract class PokemonDetailEvent extends Equatable {
  const PokemonDetailEvent();

  @override
  List<Object> get props => [];
}

class PokemonDetailFetch extends PokemonDetailEvent {
  final int pokemonId;
  const PokemonDetailFetch(this.pokemonId);

  @override
  List<Object> get props => [pokemonId];
}

class PokemonDetailLoadEvolutions extends PokemonDetailEvent {
  final int pokemonId;
  const PokemonDetailLoadEvolutions(this.pokemonId);

  @override
  List<Object> get props => [pokemonId];
}
