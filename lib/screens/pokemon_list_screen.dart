import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/skeleton_loader.dart';
import '../screens/pokemon_detail_screen.dart';

class PokemonListScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;

  const PokemonListScreen({Key? key, this.onToggleTheme}) : super(key: key);

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final PokemonService _pokemonService = PokemonService();
  final ScrollController _scrollController = ScrollController();

  List<Pokemon> _pokemons = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;

  int? _selectedGeneration;
  String? _selectedType;

  final List<String> _types = [
    'All',
    'grass',
    'fire',
    'water',
    'bug',
    'normal',
    'poison',
    'electric',
    'ground',
    'fairy',
    'fighting',
    'psychic',
    'rock',
    'ghost',
    'ice',
    'dragon',
    'dark',
    'steel',
    'flying',
  ];

  @override
  void initState() {
    super.initState();
    _loadPokemons();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadPokemons({bool reset = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      List<Pokemon> newPokemons = [];

      if (_selectedGeneration != null) {
        newPokemons =
            await _pokemonService.getPokemonsByGeneration(_selectedGeneration!);
      } else {
        newPokemons = await _pokemonService.getPokemons(
          limit: _limit,
          offset: reset ? 0 : _offset,
        );
      }

      if (_selectedType != null &&
          _selectedType!.isNotEmpty &&
          _selectedType != 'All') {
        newPokemons = newPokemons
            .where((p) => p.types.contains(_selectedType!.toLowerCase()))
            .toList();
      }

      setState(() {
        if (reset) {
          _pokemons = newPokemons;
          _offset = newPokemons.length;
        } else {
          _pokemons.addAll(newPokemons);
          _offset += newPokemons.length;
        }
        _hasMore = newPokemons.length == _limit;
      });
    } catch (e) {
      debugPrint('Error loading pokemons: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore &&
        _selectedGeneration == null) {
      _loadPokemons();
    }
  }

  void _onGenerationSelected(int? generation) {
    setState(() {
      _selectedGeneration = generation;
      _offset = 0;
    });
    _loadPokemons(reset: true);
  }

  void _onTypeSelected(String? type) {
    setState(() {
      _selectedType = type;
      _offset = 0;
    });
    _loadPokemons(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  ThemeMode get _systemTheme =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        title: const Text("Pokédex"),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.red[800] : Colors.red,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔽 FILTROS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                // Filtro de generación
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedGeneration,
                    hint: const Text("Generación"),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    items: _pokemonService
                        .getAvailableGenerations()
                        .map((gen) => DropdownMenuItem(
                              value: gen,
                              child: Text(
                                'Gen $gen - ${_pokemonService.getGenerationName(gen)}',
                              ),
                            ))
                        .toList(),
                    onChanged: _onGenerationSelected,
                  ),
                ),
                const SizedBox(width: 10),
                // Filtro de tipo
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType ?? 'All',
                    hint: const Text("Tipo"),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    items: _types
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: _onTypeSelected,
                  ),
                ),
              ],
            ),
          ),

          // 🔽 LISTA DE POKÉMON
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadPokemons(reset: true),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _isLoading && _pokemons.isEmpty
                    ? GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: 8,
                        itemBuilder: (context, index) =>
                            const PokemonCardSkeleton(),
                      )
                    : GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.2,
                        ),
                        itemCount:
                            _pokemons.length + (_isLoading && _hasMore ? 4 : 0),
                        itemBuilder: (context, index) {
                          if (index < _pokemons.length) {
                            final pokemon = _pokemons[index];
                            return PokemonCard(
                              pokemon: pokemon,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PokemonDetailScreen(pokemon: pokemon),
                                  ),
                                );
                              },
                            );
                          } else {
                            return const PokemonCardSkeleton();
                          }
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
