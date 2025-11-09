part of 'pokemon_list_bloc.dart';

@immutable
abstract class PokemonListEvent extends Equatable {
  const PokemonListEvent();

  @override
  List<Object> get props => [];
}

class PokemonListFetch extends PokemonListEvent {
  const PokemonListFetch();
}

class PokemonListLoadMore extends PokemonListEvent {
  const PokemonListLoadMore();
}

class PokemonListSearch extends PokemonListEvent {
  final String query;
  const PokemonListSearch(this.query);

  @override
  List<Object> get props => [query];
}

class PokemonListClearSearch extends PokemonListEvent {
  const PokemonListClearSearch();
}

class PokemonListFilterByType extends PokemonListEvent {
  final String type;
  const PokemonListFilterByType(this.type);

  @override
  List<Object> get props => [type];
}

class PokemonListFilterByGeneration extends PokemonListEvent {
  final int generation;
  const PokemonListFilterByGeneration(this.generation);

  @override
  List<Object> get props => [generation];
}

class PokemonListClearFilters extends PokemonListEvent {
  const PokemonListClearFilters();
}

class PokemonListClearTypeFilter extends PokemonListEvent {
  const PokemonListClearTypeFilter();
}

class PokemonListClearGenerationFilter extends PokemonListEvent {
  const PokemonListClearGenerationFilter();
}
