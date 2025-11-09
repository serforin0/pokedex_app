import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pokedex_app/models/pokemon.dart';
import 'package:pokedex_app/services/pokemon_service.dart';

part 'pokemon_list_event.dart';
part 'pokemon_list_state.dart';

class PokemonListBloc extends Bloc<PokemonListEvent, PokemonListState> {
  final PokemonService pokemonService;

  static const int _pageSize = 50;
  List<Pokemon> _allPokemons = [];
  List<Pokemon> _currentGenerationPokemons = [];
  String? _currentSearchQuery;
  String? _currentTypeFilter;
  int? _currentGenerationFilter;
  bool _isLoadingMore = false;

  PokemonListBloc({required this.pokemonService})
      : super(const PokemonListInitial()) {
    on<PokemonListFetch>(_onFetch);
    on<PokemonListLoadMore>(_onLoadMore);
    on<PokemonListSearch>(_onSearch);
    on<PokemonListClearSearch>(_onClearSearch);
    on<PokemonListFilterByType>(_onFilterByType);
    on<PokemonListFilterByGeneration>(_onFilterByGeneration);
    on<PokemonListClearFilters>(_onClearFilters);
    on<PokemonListClearTypeFilter>(_onClearTypeFilter);
    on<PokemonListClearGenerationFilter>(_onClearGenerationFilter);
  }

  Future<void> _onFetch(
    PokemonListFetch event,
    Emitter<PokemonListState> emit,
  ) async {
    try {
      emit(const PokemonListLoading());

      _allPokemons =
          await pokemonService.getPokemons(limit: _pageSize, offset: 0);
      _currentGenerationPokemons = [];

      // Resetear filtros
      _currentSearchQuery = null;
      _currentTypeFilter = null;
      _currentGenerationFilter = null;
      _isLoadingMore = false;

      emit(PokemonListSuccess(
        pokemons: _allPokemons,
        hasReachedMax: _allPokemons.length < _pageSize,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(PokemonListError('Failed to load Pokémon: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMore(
    PokemonListLoadMore event,
    Emitter<PokemonListState> emit,
  ) async {
    if (state is! PokemonListSuccess) return;
    final currentState = state as PokemonListSuccess;

    // Evitar carga múltiple
    if (currentState.hasReachedMax || _isLoadingMore) return;

    try {
      _isLoadingMore = true;

      // Emitir estado de carga
      emit(currentState.copyWith(isLoadingMore: true));

      final newPokemons = await pokemonService.getPokemons(
        limit: _pageSize,
        offset: _allPokemons.length,
      );

      if (newPokemons.isEmpty) {
        emit(currentState.copyWith(hasReachedMax: true, isLoadingMore: false));
      } else {
        // Evitar duplicados
        final existingIds = _allPokemons.map((p) => p.id).toSet();
        final uniqueNewPokemons =
            newPokemons.where((p) => !existingIds.contains(p.id)).toList();

        _allPokemons.addAll(uniqueNewPokemons);

        // Re-aplicar filtros actuales
        final filteredPokemons = _applyCurrentFilters();

        emit(currentState.copyWith(
          pokemons: filteredPokemons,
          hasReachedMax: uniqueNewPokemons.length < _pageSize,
          isLoadingMore: false,
        ));
      }

      _isLoadingMore = false;
    } catch (e) {
      _isLoadingMore = false;
      if (state is PokemonListSuccess) {
        emit((state as PokemonListSuccess).copyWith(isLoadingMore: false));
      }
      print('Failed to load more Pokémon: ${e.toString()}');
    }
  }

  Future<void> _onSearch(
    PokemonListSearch event,
    Emitter<PokemonListState> emit,
  ) async {
    if (state is! PokemonListSuccess) return;

    _currentSearchQuery = event.query.isEmpty ? null : event.query;
    final filteredPokemons = _applyCurrentFilters();

    emit((state as PokemonListSuccess).copyWith(
      pokemons: filteredPokemons,
      hasReachedMax:
          _currentTypeFilter != null || _currentGenerationFilter != null,
      searchQuery: _currentSearchQuery,
      isLoadingMore: false, // Asegurar que no sea null
    ));
  }

  Future<void> _onClearSearch(
    PokemonListClearSearch event,
    Emitter<PokemonListState> emit,
  ) async {
    if (state is! PokemonListSuccess) return;

    _currentSearchQuery = null;
    final filteredPokemons = _applyCurrentFilters();

    emit((state as PokemonListSuccess).copyWith(
      pokemons: filteredPokemons,
      hasReachedMax:
          _currentTypeFilter != null || _currentGenerationFilter != null,
      searchQuery: null,
      isLoadingMore: false, // Asegurar que no sea null
    ));
  }

  Future<void> _onFilterByType(
    PokemonListFilterByType event,
    Emitter<PokemonListState> emit,
  ) async {
    try {
      emit(const PokemonListLoading());

      _currentTypeFilter = event.type;

      final filteredPokemons = _applyCurrentFilters();

      emit(PokemonListSuccess(
        pokemons: filteredPokemons,
        hasReachedMax: true,
        selectedType: _currentTypeFilter,
        selectedGeneration: _currentGenerationFilter,
        searchQuery: _currentSearchQuery,
        isLoadingMore: false, // Asegurar que no sea null
      ));
    } catch (e) {
      emit(PokemonListError('Failed to filter by type: ${e.toString()}'));
    }
  }

  Future<void> _onFilterByGeneration(
    PokemonListFilterByGeneration event,
    Emitter<PokemonListState> emit,
  ) async {
    try {
      emit(const PokemonListLoading());

      // Cargar todos los Pokémon de la generación seleccionada
      _currentGenerationPokemons =
          await pokemonService.getPokemonsByGeneration(event.generation);
      _currentGenerationFilter = event.generation;

      // Aplicar filtros existentes (tipo y búsqueda)
      final filteredPokemons = _applyCurrentFilters();

      emit(PokemonListSuccess(
        pokemons: filteredPokemons,
        hasReachedMax: true,
        selectedType: _currentTypeFilter,
        selectedGeneration: _currentGenerationFilter,
        searchQuery: _currentSearchQuery,
        isLoadingMore: false, // Asegurar que no sea null
      ));
    } catch (e) {
      emit(PokemonListError('Failed to load generation: ${e.toString()}'));
    }
  }

  Future<void> _onClearFilters(
    PokemonListClearFilters event,
    Emitter<PokemonListState> emit,
  ) async {
    _currentTypeFilter = null;
    _currentGenerationFilter = null;
    _currentSearchQuery = null;
    _currentGenerationPokemons = [];
    _isLoadingMore = false;

    emit(PokemonListSuccess(
      pokemons: _allPokemons,
      hasReachedMax: _allPokemons.length < _pageSize,
      isLoadingMore: false, // Asegurar que no sea null
    ));
  }

  Future<void> _onClearTypeFilter(
    PokemonListClearTypeFilter event,
    Emitter<PokemonListState> emit,
  ) async {
    _currentTypeFilter = null;
    final filteredPokemons = _applyCurrentFilters();

    if (state is PokemonListSuccess) {
      emit((state as PokemonListSuccess).copyWith(
        pokemons: filteredPokemons,
        selectedType: null,
        hasReachedMax: _currentGenerationFilter != null,
        isLoadingMore: false, // Asegurar que no sea null
      ));
    }
  }

  Future<void> _onClearGenerationFilter(
    PokemonListClearGenerationFilter event,
    Emitter<PokemonListState> emit,
  ) async {
    _currentGenerationFilter = null;
    _currentGenerationPokemons = [];
    final filteredPokemons = _applyCurrentFilters();

    if (state is PokemonListSuccess) {
      emit((state as PokemonListSuccess).copyWith(
        pokemons: filteredPokemons,
        selectedGeneration: null,
        hasReachedMax: _currentTypeFilter != null,
        isLoadingMore: false, // Asegurar que no sea null
      ));
    }
  }

  List<Pokemon> _applyCurrentFilters() {
    List<Pokemon> basePokemons;

    // Determinar la base de Pokémon a usar
    if (_currentGenerationFilter != null &&
        _currentGenerationPokemons.isNotEmpty) {
      basePokemons = List.from(_currentGenerationPokemons);
    } else {
      basePokemons = List.from(_allPokemons);
    }

    // Aplicar filtro por tipo si existe
    if (_currentTypeFilter != null && _currentTypeFilter!.isNotEmpty) {
      basePokemons = _applyTypeFilter(basePokemons, _currentTypeFilter!);
    }

    // Aplicar búsqueda si existe
    if (_currentSearchQuery != null && _currentSearchQuery!.isNotEmpty) {
      basePokemons = _applySearchFilter(basePokemons, _currentSearchQuery!);
    }

    return basePokemons;
  }

  List<Pokemon> _applyTypeFilter(List<Pokemon> pokemons, String type) {
    final lowerType = type.toLowerCase();
    return pokemons.where((pokemon) {
      return pokemon.types
          .any((pokemonType) => pokemonType.toLowerCase() == lowerType);
    }).toList();
  }

  List<Pokemon> _applySearchFilter(List<Pokemon> pokemons, String query) {
    final lowerQuery = query.toLowerCase();
    return pokemons.where((pokemon) {
      return pokemon.name.toLowerCase().contains(lowerQuery) ||
          pokemon.id.toString().contains(query);
    }).toList();
  }
}
