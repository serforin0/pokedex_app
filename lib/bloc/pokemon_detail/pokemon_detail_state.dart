part of 'pokemon_detail_bloc.dart';

@immutable
abstract class PokemonDetailState extends Equatable {
  const PokemonDetailState();

  @override
  List<Object> get props => [];
}

class PokemonDetailInitial extends PokemonDetailState {
  const PokemonDetailInitial();
}

class PokemonDetailLoading extends PokemonDetailState {
  const PokemonDetailLoading();
}

class PokemonDetailSuccess extends PokemonDetailState {
  final Pokemon pokemon;
  final List<PokemonEvolution>
      evolutions; // ← AQUÍ DEBE SER List<PokemonEvolution>
  final bool isLoadingEvolutions;

  const PokemonDetailSuccess({
    required this.pokemon,
    this.evolutions = const [],
    this.isLoadingEvolutions = false,
  });

  PokemonDetailSuccess copyWith({
    Pokemon? pokemon,
    List<PokemonEvolution>? evolutions, // ← Y AQUÍ TAMBIÉN
    bool? isLoadingEvolutions,
  }) {
    return PokemonDetailSuccess(
      pokemon: pokemon ?? this.pokemon,
      evolutions: evolutions ?? this.evolutions,
      isLoadingEvolutions: isLoadingEvolutions ?? this.isLoadingEvolutions,
    );
  }

  @override
  List<Object> get props => [pokemon, evolutions, isLoadingEvolutions];
}

class PokemonDetailError extends PokemonDetailState {
  final String message;
  const PokemonDetailError(this.message);

  @override
  List<Object> get props => [message];
}
