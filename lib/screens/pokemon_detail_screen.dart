import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex_app/bloc/pokemon_detail/pokemon_detail_bloc.dart';
import 'package:pokedex_app/models/pokemon.dart';
import 'package:pokedex_app/models/pokemon_evolution.dart';
import 'package:pokedex_app/services/pokemon_service.dart';
import '../constants/colors.dart';

class PokemonDetailScreen extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonDetailScreen({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PokemonDetailBloc(pokemonService: PokemonService())
        ..add(PokemonDetailFetch(pokemon.id)),
      child: _PokemonDetailView(initialPokemon: pokemon),
    );
  }
}

class _PokemonDetailView extends StatelessWidget {
  final Pokemon initialPokemon;

  const _PokemonDetailView({required this.initialPokemon});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PokemonDetailBloc, PokemonDetailState>(
      builder: (context, state) {
        final pokemon = _getCurrentPokemon(state);
        final evolutions = _getEvolutions(state);
        final isLoadingEvolutions = _isLoadingEvolutions(state);

        return Scaffold(
          backgroundColor: getTypeColor(pokemon.types.first),
          body: Column(
            children: [
              _buildHeader(context),
              Expanded(flex: 2, child: _buildImageSection(pokemon)),
              Expanded(
                flex: 3,
                child:
                    _buildContentCard(pokemon, evolutions, isLoadingEvolutions),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Helper Methods ---
  Pokemon _getCurrentPokemon(PokemonDetailState state) =>
      state is PokemonDetailSuccess ? state.pokemon : initialPokemon;

  List<PokemonEvolution> _getEvolutions(PokemonDetailState state) =>
      state is PokemonDetailSuccess
          ? (state.evolutions as List<PokemonEvolution>)
          : <PokemonEvolution>[];

  bool _isLoadingEvolutions(PokemonDetailState state) =>
      state is PokemonDetailSuccess ? state.isLoadingEvolutions : true;

  // --- UI Components ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 10),
      child: Row(
        children: [
          _buildBackButton(context),
          const Spacer(),
          _buildPokemonNumber(),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildPokemonNumber() {
    return BlocBuilder<PokemonDetailBloc, PokemonDetailState>(
      builder: (context, state) {
        final pokemon = _getCurrentPokemon(state);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '#${pokemon.id.toString().padLeft(3, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(Pokemon pokemon) {
    return Stack(
      children: [
        _buildBackgroundGradient(pokemon),
        _buildPokemonImage(pokemon),
      ],
    );
  }

  Widget _buildBackgroundGradient(Pokemon pokemon) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              getTypeColor(pokemon.types.first).withOpacity(0.9),
              getTypeColor(pokemon.types.first).withOpacity(0.7),
              getTypeColor(pokemon.types.first).withOpacity(0.5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPokemonImage(Pokemon pokemon) {
    return Center(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Hero(
            tag: 'pokemon-image-${pokemon.id}',
            child: Image.network(
              pokemon.imageUrl,
              height: 200,
              width: 200,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.catching_pokemon,
                  size: 80,
                  color: Colors.white,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard(
    Pokemon pokemon,
    List<PokemonEvolution> evolutions,
    bool isLoadingEvolutions,
  ) {
    return Container(
      width: double.infinity,
      decoration: _contentCardDecoration,
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const SizedBox(height: 30),
            _buildNameAndTypes(pokemon),
            const SizedBox(height: 24),
            _buildTabBar(pokemon),
            Expanded(
              child: _buildTabContent(pokemon, evolutions, isLoadingEvolutions),
            ),
          ],
        ),
      ),
    );
  }

  final BoxDecoration _contentCardDecoration = const BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(40),
      topRight: Radius.circular(40),
    ),
    boxShadow: [
      BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5),
    ],
  );

  Widget _buildNameAndTypes(Pokemon pokemon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pokemon.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: pokemon.types.map(_buildTypeChip).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: getTypeColor(type),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTabBar(Pokemon pokemon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
        ),
        child: TabBar(
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 3.0,
              color: getTypeColor(pokemon.types.first),
            ),
            insets: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: getTypeColor(pokemon.types.first),
          unselectedLabelColor: Colors.grey[600],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'About'),
            Tab(text: 'Stats'),
            Tab(text: 'Evolution'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(
    Pokemon pokemon,
    List<PokemonEvolution> evolutions,
    bool isLoadingEvolutions,
  ) {
    return TabBarView(
      children: [
        _buildAboutTab(pokemon),
        _buildStatsTab(pokemon),
        _buildEvolutionTab(evolutions, isLoadingEvolutions),
      ],
    );
  }

  Widget _buildAboutTab(Pokemon pokemon) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Pokédex Data', [
            _buildInfoRow('Species', pokemon.species),
            _buildInfoRow('Height', '${pokemon.height} m'),
            _buildInfoRow('Weight', '${pokemon.weight} kg'),
            _buildInfoRow('Abilities', pokemon.abilities.join(', ')),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Training', [
            _buildInfoRow('Base EXP', pokemon.baseExperience.toString()),
            _buildInfoRow('Growth Rate', pokemon.growthRate),
          ]),
          const SizedBox(height: 16),
          _buildWeaknessesCard(pokemon),
        ],
      ),
    );
  }

  Widget _buildStatsTab(Pokemon pokemon) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildStatCard('HP', pokemon.hp, 255, Colors.green),
          _buildStatCard('Attack', pokemon.attack, 255, Colors.red),
          _buildStatCard('Defense', pokemon.defense, 255, Colors.blue),
          _buildStatCard('Sp. Atk', pokemon.specialAttack, 255, Colors.purple),
          _buildStatCard('Sp. Def', pokemon.specialDefense, 255, Colors.orange),
          _buildStatCard('Speed', pokemon.speed, 255, Colors.pink),
          const SizedBox(height: 16),
          _buildTotalStatsCard(pokemon),
        ],
      ),
    );
  }

  Widget _buildEvolutionTab(List<PokemonEvolution> evolutions, bool isLoading) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (evolutions.isEmpty) return _buildNoEvolutions();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildEvolutionChain(evolutions),
          const SizedBox(height: 20),
          _buildEvolutionMethods(evolutions),
        ],
      ),
    );
  }

  Widget _buildNoEvolutions() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No Evolutions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This Pokémon does not evolve',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          BlocBuilder<PokemonDetailBloc, PokemonDetailState>(
            builder: (context, state) {
              final pokemon = _getCurrentPokemon(state);
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${pokemon.name} is in its final form',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionChain(List<PokemonEvolution> evolutions) {
    return BlocBuilder<PokemonDetailBloc, PokemonDetailState>(
      builder: (context, state) {
        final pokemon = _getCurrentPokemon(state);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Evolution Chain',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildEvolutionStep(
                pokemon.name,
                pokemon.imageUrl,
                pokemon.id,
                isCurrent: true,
              ),
              ...evolutions
                  .map((evolution) => Column(
                        children: [
                          _buildEvolutionArrow(evolution),
                          _buildEvolutionStep(
                            evolution.name,
                            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${evolution.id}.png',
                            evolution.id,
                            evolution: evolution,
                          ),
                        ],
                      ))
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEvolutionStep(
    String name,
    String imageUrl,
    int id, {
    bool isCurrent = false,
    PokemonEvolution? evolution,
  }) {
    return BlocBuilder<PokemonDetailBloc, PokemonDetailState>(
      builder: (context, state) {
        final pokemon = _getCurrentPokemon(state);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              _buildEvolutionImage(pokemon, imageUrl, isCurrent),
              const SizedBox(width: 12),
              _buildEvolutionInfo(name, id, evolution, pokemon, isCurrent),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEvolutionImage(
      Pokemon pokemon, String imageUrl, bool isCurrent) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color:
              isCurrent ? getTypeColor(pokemon.types.first) : Colors.grey[300]!,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  getTypeColor(pokemon.types.first),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.catching_pokemon,
              color: Colors.grey[400],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEvolutionInfo(
    String name,
    int id,
    PokemonEvolution? evolution,
    Pokemon pokemon,
    bool isCurrent,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isCurrent
                  ? getTypeColor(pokemon.types.first)
                  : Colors.black87,
            ),
          ),
          Text(
            '#${id.toString().padLeft(3, '0')}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          if (evolution != null && evolution.method.isNotEmpty)
            _buildEvolutionMethod(evolution),
        ],
      ),
    );
  }

  Widget _buildEvolutionArrow(PokemonEvolution evolution) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 30),
          Icon(Icons.arrow_downward, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 1, color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget _buildEvolutionMethod(PokemonEvolution evolution) {
    return BlocBuilder<PokemonDetailBloc, PokemonDetailState>(
      builder: (context, state) {
        final pokemon = _getCurrentPokemon(state);
        final methodText = _getEvolutionMethodText(evolution);

        return Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: getTypeColor(pokemon.types.first).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            methodText,
            style: TextStyle(
              fontSize: 10,
              color: getTypeColor(pokemon.types.first),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  String _getEvolutionMethodText(PokemonEvolution evolution) {
    if (evolution.level > 0) return 'Level ${evolution.level}';
    if (evolution.item.isNotEmpty) {
      return 'Use ${evolution.item.replaceAll('-', ' ').toUpperCase()}';
    }
    if (evolution.method == 'trade') return 'Trade';
    return 'Special Condition';
  }

  Widget _buildEvolutionMethods(List<PokemonEvolution> evolutions) {
    final methods = evolutions.where((e) => e.method.isNotEmpty).toList();
    if (methods.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evolution Methods',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...methods.map(_buildMethodDetail).toList(),
        ],
      ),
    );
  }

  Widget _buildMethodDetail(PokemonEvolution evolution) {
    return BlocBuilder<PokemonDetailBloc, PokemonDetailState>(
      builder: (context, state) {
        final pokemon = _getCurrentPokemon(state);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: getTypeColor(pokemon.types.first),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${evolution.name.toUpperCase()} → ${_getMethodDescription(evolution)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMethodDescription(PokemonEvolution evolution) {
    if (evolution.level > 0) return 'Reach Level ${evolution.level}';
    if (evolution.item.isNotEmpty) {
      return 'Use ${evolution.item.replaceAll('-', ' ').toUpperCase()}';
    }
    if (evolution.method == 'trade') return 'Trade with another player';
    return 'Special condition';
  }

  Widget _buildTotalStatsCard(Pokemon pokemon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: getTypeColor(pokemon.types.first),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              pokemon.totalStats.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Common UI Components ---
  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildWeaknessesCard(Pokemon pokemon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weaknesses',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pokemon.weaknesses.map(_buildWeaknessChip).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeaknessChip(String weakness) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: getTypeColor(weakness),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        weakness.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String statName, int value, int maxValue, Color color) {
    final percentage = value / maxValue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 8,
                    width: constraints.maxWidth * percentage,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
