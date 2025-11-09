import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pokedex_app/models/pokemon.dart';
import 'package:pokedex_app/models/pokemon_evolution.dart';
import 'package:pokedex_app/services/pokemon_service.dart';

part 'pokemon_detail_event.dart';
part 'pokemon_detail_state.dart';

class PokemonDetailBloc extends Bloc<PokemonDetailEvent, PokemonDetailState> {
  final PokemonService pokemonService;

  PokemonDetailBloc({required this.pokemonService})
      : super(const PokemonDetailInitial()) {
    on<PokemonDetailFetch>(_onFetch);
    on<PokemonDetailLoadEvolutions>(_onLoadEvolutions);
  }

  Future<void> _onFetch(
    PokemonDetailFetch event,
    Emitter<PokemonDetailState> emit,
  ) async {
    try {
      emit(const PokemonDetailLoading());

      final pokemon = await pokemonService.getPokemonById(event.pokemonId);

      emit(PokemonDetailSuccess(pokemon: pokemon));

      // Cargar evoluciones automáticamente
      add(PokemonDetailLoadEvolutions(event.pokemonId));
    } catch (e) {
      emit(PokemonDetailError(
          'Failed to load Pokémon details: ${e.toString()}'));
    }
  }

  Future<void> _onLoadEvolutions(
    PokemonDetailLoadEvolutions event,
    Emitter<PokemonDetailState> emit,
  ) async {
    if (state is PokemonDetailSuccess) {
      final currentState = state as PokemonDetailSuccess;

      try {
        emit(currentState.copyWith(isLoadingEvolutions: true));

        final dynamic evolutionsData =
            await pokemonService.getPokemonEvolutions(event.pokemonId);

        // Conversión explícita
        final List<PokemonEvolution> evolutions =
            (evolutionsData as List).cast<PokemonEvolution>();

        emit(currentState.copyWith(
          evolutions: evolutions,
          isLoadingEvolutions: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingEvolutions: false));
      }
    }
  }
}
