part of 'pokemon_list_bloc.dart';

@immutable
abstract class PokemonListState extends Equatable {
  const PokemonListState();

  @override
  List<Object> get props => [];
}

class PokemonListInitial extends PokemonListState {
  const PokemonListInitial();
}

class PokemonListLoading extends PokemonListState {
  const PokemonListLoading();
}

class PokemonListSuccess extends PokemonListState {
  final List<Pokemon> pokemons;
  final bool hasReachedMax;
  final String? searchQuery;
  final String? selectedType;
  final int? selectedGeneration;
  final bool isLoadingMore;

  const PokemonListSuccess({
    required this.pokemons,
    this.hasReachedMax = false,
    this.searchQuery,
    this.selectedType,
    this.selectedGeneration,
    this.isLoadingMore = false,
  });

  PokemonListSuccess copyWith({
    List<Pokemon>? pokemons,
    bool? hasReachedMax,
    String? searchQuery,
    String? selectedType,
    int? selectedGeneration,
    bool? isLoadingMore,
  }) {
    return PokemonListSuccess(
      pokemons: pokemons ?? this.pokemons,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
      selectedGeneration: selectedGeneration ?? this.selectedGeneration,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [
        pokemons,
        hasReachedMax,
        isLoadingMore,
        searchQuery ?? '',
        selectedType ?? '',
        selectedGeneration ?? 0,
      ];
}

class PokemonListError extends PokemonListState {
  final String message;
  const PokemonListError(this.message);

  @override
  List<Object> get props => [message];
}
