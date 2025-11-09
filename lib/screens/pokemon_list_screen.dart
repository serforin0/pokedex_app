import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex_app/models/pokemon.dart';
import 'package:pokedex_app/widgets/skeleton_loader.dart';
import '../bloc/pokemon_list/pokemon_list_bloc.dart';
import '../widgets/pokemon_card.dart';
import './pokemon_detail_screen.dart';
import '../services/pokemon_service.dart';
import '../constants/colors.dart';
import '../widgets/skeleton_loader.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final PokemonService _pokemonService = PokemonService();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PokemonListBloc>().add(const PokemonListLoadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String query) {
    context.read<PokemonListBloc>().add(PokemonListSearch(query));
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<PokemonListBloc>().add(const PokemonListClearSearch());
  }

  void _onPokemonTap(Pokemon pokemon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonDetailScreen(pokemon: pokemon),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildFilterBottomSheet(context),
    );
  }

  Widget _buildFilterBottomSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeFilterSection(context),
                  const SizedBox(height: 24),
                  _buildGenerationFilterSection(context),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFilterActions(context),
        ],
      ),
    );
  }

  Widget _buildTypeFilterSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter by Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getAllTypes().map((type) {
            return FilterChip(
              label: Text(
                type.toUpperCase(),
                style: const TextStyle(fontSize: 12),
              ),
              selected: _isTypeSelected(context, type),
              onSelected: (selected) {
                if (selected) {
                  context
                      .read<PokemonListBloc>()
                      .add(PokemonListFilterByType(type));
                } else {
                  context
                      .read<PokemonListBloc>()
                      .add(const PokemonListClearTypeFilter());
                }
                Navigator.pop(context);
              },
              backgroundColor: Colors.grey[300],
              selectedColor: getTypeColor(type),
              labelStyle: TextStyle(
                color: _isTypeSelected(context, type)
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenerationFilterSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter by Generation',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _pokemonService.getAvailableGenerations().map((generation) {
            return FilterChip(
              label: Text(
                '${_pokemonService.getGenerationName(generation)} (Gen $generation)',
                style: const TextStyle(fontSize: 12),
              ),
              selected: _isGenerationSelected(context, generation),
              onSelected: (selected) {
                if (selected) {
                  context
                      .read<PokemonListBloc>()
                      .add(PokemonListFilterByGeneration(generation));
                } else {
                  context
                      .read<PokemonListBloc>()
                      .add(const PokemonListClearGenerationFilter());
                }
                Navigator.pop(context);
              },
              backgroundColor: Colors.grey[300],
              selectedColor: Colors.blue,
              labelStyle: TextStyle(
                color: _isGenerationSelected(context, generation)
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              context
                  .read<PokemonListBloc>()
                  .add(const PokemonListClearFilters());
              _searchController.clear();
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text('Clear All'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ),
      ],
    );
  }

  List<String> _getAllTypes() {
    return [
      'normal',
      'fire',
      'water',
      'electric',
      'grass',
      'ice',
      'fighting',
      'poison',
      'ground',
      'flying',
      'psychic',
      'bug',
      'rock',
      'ghost',
      'dragon',
      'dark',
      'steel',
      'fairy'
    ];
  }

  bool _isTypeSelected(BuildContext context, String type) {
    final state = context.read<PokemonListBloc>().state;
    return state is PokemonListSuccess && state.selectedType == type;
  }

  bool _isGenerationSelected(BuildContext context, int generation) {
    final state = context.read<PokemonListBloc>().state;
    return state is PokemonListSuccess &&
        state.selectedGeneration == generation;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filters',
          ),
        ],
      ),
      body: BlocConsumer<PokemonListBloc, PokemonListState>(
        listener: (context, state) {
          if (state is PokemonListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search Pokémon by name or number...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              // Indicadores de filtros activos
              _buildActiveFilters(context),
              // Lista de Pokémon
              Expanded(child: _buildContent(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveFilters(BuildContext context) {
    final state = context.read<PokemonListBloc>().state;
    if (state is! PokemonListSuccess) return const SizedBox();

    final hasActiveFilters =
        state.selectedType != null || state.selectedGeneration != null;
    if (!hasActiveFilters) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Active filters:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                if (state.selectedType != null)
                  Chip(
                    label: Text('Type: ${state.selectedType!.toUpperCase()}'),
                    backgroundColor: getTypeColor(state.selectedType!),
                    labelStyle: const TextStyle(color: Colors.white),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      context
                          .read<PokemonListBloc>()
                          .add(const PokemonListClearTypeFilter());
                    },
                  ),
                if (state.selectedGeneration != null)
                  Chip(
                    label: Text('Gen ${state.selectedGeneration}'),
                    backgroundColor: Colors.blue,
                    labelStyle: const TextStyle(color: Colors.white),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      context
                          .read<PokemonListBloc>()
                          .add(const PokemonListClearGenerationFilter());
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// En el método _buildContent, modifica esta parte específica:
  Widget _buildContent(PokemonListState state) {
    if (state is PokemonListInitial || state is PokemonListLoading) {
      return _buildSkeletonGrid();
    }

    if (state is PokemonListError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Failed to load Pokémon',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                context.read<PokemonListBloc>().add(const PokemonListFetch());
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (state is PokemonListSuccess) {
      if (state.pokemons.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No Pokémon found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Try changing your search or filters',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.1,
        ),
        itemCount: state.hasReachedMax
            ? state.pokemons.length
            : state.pokemons.length + (state.isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= state.pokemons.length) {
            return const PokemonCardSkeleton();
          }

          final pokemon = state.pokemons[index];
          return PokemonCard(
            pokemon: pokemon,
            onTap: () => _onPokemonTap(pokemon),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.1,
      ),
      itemCount: 10, // Mostrar 10 skeletons
      itemBuilder: (context, index) {
        return const PokemonCardSkeleton();
      },
    );
  }
}
