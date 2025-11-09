import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/search_bar.dart';
import '../widgets/type_filter_chip.dart';
import '../widgets/generation_filter.dart';
import 'pokemon_detail_screen.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({Key? key}) : super(key: key);

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final PokemonService _pokemonService = PokemonService();
  List<Pokemon> _pokemons = [];
  List<Pokemon> _filteredPokemons = [];
  bool _isLoading = true;
  String _searchQuery = '';
  List<String> _selectedTypes = [];
  int _selectedGeneration = 1; // Generación por defecto: Kanto

  @override
  void initState() {
    super.initState();
    _loadPokemons();
  }

  Future<void> _loadPokemons() async {
    try {
      final pokemons = await _pokemonService.getPokemonsByGeneration(
        _selectedGeneration,
      );
      setState(() {
        _pokemons = pokemons;
        _filteredPokemons = pokemons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading pokemons: $e');
    }
  }

  void _filterPokemons() {
    List<Pokemon> filtered = _pokemons;

    // Aplicar filtro de búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (pokemon) =>
                pokemon.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                pokemon.id.toString().contains(_searchQuery),
          )
          .toList();
    }

    // Aplicar filtro de tipos
    if (_selectedTypes.isNotEmpty) {
      filtered = filtered
          .where(
            (pokemon) =>
                _selectedTypes.any((type) => pokemon.types.contains(type)),
          )
          .toList();
    }

    setState(() {
      _filteredPokemons = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterPokemons();
  }

  void _onSearchClear() {
    setState(() {
      _searchQuery = '';
    });
    _filterPokemons();
  }

  void _onTypesChanged(List<String> types) {
    setState(() {
      _selectedTypes = types;
    });
    _filterPokemons();
  }

  void _onGenerationChanged(int generation) {
    setState(() {
      _selectedGeneration = generation;
      _isLoading = true;
      _selectedTypes = []; // Limpiar filtros de tipos al cambiar generación
      _searchQuery = ''; // Limpiar búsqueda al cambiar generación
    });
    _loadPokemons();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _navigateToDetail(Pokemon pokemon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonDetailScreen(pokemon: pokemon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pokédex',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Text(
              _getGenerationSubtitle(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtro de generación - NUEVO
          GenerationFilter(
            selectedGeneration: _selectedGeneration,
            onGenerationChanged: _onGenerationChanged,
          ),

          // Barra de búsqueda
          PokemonSearchBar(
            onSearchChanged: _onSearchChanged,
            onClear: _onSearchClear,
          ),

          // Filtros por tipo
          TypeFilterChip(
            selectedTypes: _selectedTypes,
            onTypesChanged: _onTypesChanged,
          ),

          // Contador de resultados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filteredPokemons.length} Pokémon${_filteredPokemons.length != 1 ? 's' : ''} encontrado${_filteredPokemons.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Gen $_selectedGeneration',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Lista de Pokémon
          Expanded(
            child: _isLoading
                ? _buildSkeletonGrid()
                : _filteredPokemons.isEmpty
                ? _buildEmptyState()
                : _buildPokemonGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredPokemons.length,
      itemBuilder: (context, index) {
        final pokemon = _filteredPokemons[index];
        return PokemonCard(
          pokemon: pokemon,
          onTap: () => _navigateToDetail(pokemon),
        );
      },
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return const PokemonCardSkeleton();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No se encontraron Pokémon',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otros términos de búsqueda\n o filtros diferentes',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPokemons,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Recargar Pokémon'),
          ),
        ],
      ),
    );
  }

  String _getGenerationSubtitle() {
    switch (_selectedGeneration) {
      case 1:
        return 'Kanto • 151 Pokémon';
      case 2:
        return 'Johto • 100 Pokémon';
      case 3:
        return 'Hoenn • 135 Pokémon';
      case 4:
        return 'Sinnoh • 107 Pokémon';
      case 5:
        return 'Unova • 156 Pokémon';
      case 6:
        return 'Kalos • 72 Pokémon';
      case 7:
        return 'Alola • 88 Pokémon';
      case 8:
        return 'Galar • 96 Pokémon';
      case 9:
        return 'Paldea • 120 Pokémon';
      default:
        return 'Generación $_selectedGeneration';
    }
  }
}
