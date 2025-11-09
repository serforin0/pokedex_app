import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex_app/bloc/pokemon_detail/pokemon_detail_bloc.dart';
import 'package:pokedex_app/models/pokemon.dart';
import 'package:pokedex_app/models/pokemon_evolution.dart';
import 'package:pokedex_app/services/pokemon_service.dart';
import '../constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PokemonDetailScreen extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonDetailScreen({super.key, required this.pokemon});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  late Box favoritesBox;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    favoritesBox = Hive.box('favorites');
    _checkFavorite();
  }

  void _checkFavorite() {
    setState(() {
      isFavorite = favoritesBox.containsKey(widget.pokemon.id);
    });
  }

  void _toggleFavorite(Pokemon pokemon) {
    setState(() {
      if (isFavorite) {
        favoritesBox.delete(pokemon.id);
      } else {
        favoritesBox.put(pokemon.id, pokemon.toJson());
      }
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PokemonDetailBloc(pokemonService: PokemonService())
        ..add(PokemonDetailFetch(widget.pokemon.id)),
      child: _PokemonDetailView(
        initialPokemon: widget.pokemon,
        isFavorite: isFavorite,
        onToggleFavorite: _toggleFavorite,
      ),
    );
  }
}

class _PokemonDetailView extends StatelessWidget {
  final Pokemon initialPokemon;
  final bool isFavorite;
  final Function(Pokemon) onToggleFavorite;

  const _PokemonDetailView({
    required this.initialPokemon,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

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
              _buildHeader(context, pokemon),
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

  Pokemon _getCurrentPokemon(PokemonDetailState state) =>
      state is PokemonDetailSuccess ? state.pokemon : initialPokemon;

  List<PokemonEvolution> _getEvolutions(PokemonDetailState state) =>
      state is PokemonDetailSuccess
          ? (state.evolutions as List<PokemonEvolution>)
          : <PokemonEvolution>[];

  bool _isLoadingEvolutions(PokemonDetailState state) =>
      state is PokemonDetailSuccess ? state.isLoadingEvolutions : true;

  // HEADER ----------------------------------------------------
  Widget _buildHeader(BuildContext context, Pokemon pokemon) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 10),
      child: Row(
        children: [
          _buildBackButton(context),
          const Spacer(),
          _buildFavoriteButton(pokemon),
          const SizedBox(width: 10),
          _buildPokemonNumber(pokemon),
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

  Widget _buildFavoriteButton(Pokemon pokemon) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('favorites').listenable(),
      builder: (context, box, _) {
        final isFav = box.containsKey(pokemon.id);
        return GestureDetector(
          onTap: () => onToggleFavorite(pokemon),
          child: Icon(
            isFav ? Icons.star : Icons.star_border,
            color: Colors.white,
            size: 28,
          ),
        );
      },
    );
  }

  Widget _buildPokemonNumber(Pokemon pokemon) {
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
  }

  // IMAGE SECTION ----------------------------------------------
  Widget _buildImageSection(Pokemon pokemon) {
    return Stack(
      children: [
        Positioned.fill(
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
        ),
        Center(
          child: Hero(
            tag: 'pokemon-image-${pokemon.id}',
            child: CachedNetworkImage(
              imageUrl: pokemon.imageUrl,
              height: 200,
              width: 200,
              fit: BoxFit.contain,
              placeholder: (context, url) =>
                  const CircularProgressIndicator(color: Colors.white),
              errorWidget: (context, url, error) => const Icon(
                Icons.catching_pokemon,
                color: Colors.white,
                size: 80,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // CONTENT CARD -----------------------------------------------
  Widget _buildContentCard(
    Pokemon pokemon,
    List<PokemonEvolution> evolutions,
    bool isLoadingEvolutions,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              pokemon.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
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

  Widget _buildTabBar(Pokemon pokemon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TabBar(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 3.0,
            color: getTypeColor(pokemon.types.first),
          ),
          insets: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        labelColor: getTypeColor(pokemon.types.first),
        unselectedLabelColor: Colors.grey[600],
        tabs: const [
          Tab(text: 'About'),
          Tab(text: 'Stats'),
          Tab(text: 'Evolution'),
        ],
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
        _buildAboutSection(pokemon),
        _buildStatsSection(pokemon),
        _buildEvolutionSection(evolutions, isLoadingEvolutions),
      ],
    );
  }

  // ABOUT ------------------------------------------------------
  Widget _buildAboutSection(Pokemon pokemon) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildAboutRow('Type', pokemon.types.join(', ')),
          _buildAboutRow('Height', '${pokemon.height} m'),
          _buildAboutRow('Weight', '${pokemon.weight} kg'),
          _buildAboutRow('Abilities', pokemon.abilities.join(', ')),
          _buildAboutRow('Base Exp.', '${pokemon.baseExperience}'),
          _buildAboutRow('Species', pokemon.species),
          _buildAboutRow('Growth Rate', pokemon.growthRate),
        ],
      ),
    );
  }

  // STATS ------------------------------------------------------
  Widget _buildStatsSection(Pokemon pokemon) {
    final stats = {
      'HP': pokemon.hp,
      'Attack': pokemon.attack,
      'Defense': pokemon.defense,
      'Sp. Atk': pokemon.specialAttack,
      'Sp. Def': pokemon.specialDefense,
      'Speed': pokemon.speed,
    };

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: stats.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                SizedBox(width: 100, child: Text(entry.key)),
                Expanded(
                  child: LinearProgressIndicator(
                    value: entry.value / 200,
                    color: getTypeColor(pokemon.types.first),
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(width: 10),
                Text(entry.value.toString()),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // EVOLUTION --------------------------------------------------
  Widget _buildEvolutionSection(
    List<PokemonEvolution> evolutions,
    bool isLoadingEvolutions,
  ) {
    if (isLoadingEvolutions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (evolutions.isEmpty) {
      return const Center(child: Text('No evolutions available'));
    }

    return ListView.builder(
      itemCount: evolutions.length,
      itemBuilder: (context, index) {
        final evo = evolutions[index];
        return ListTile(
          leading: CachedNetworkImage(
            imageUrl:
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${evo.id}.png',
            width: 56,
            height: 56,
            placeholder: (context, _) =>
                const CircularProgressIndicator(strokeWidth: 2),
            errorWidget: (context, _, __) =>
                const Icon(Icons.catching_pokemon, color: Colors.grey),
          ),
          title: Text(evo.name ?? 'Unknown Evolution'),
          subtitle: Text('Stage ${index + 1}'),
        );
      },
    );
  }

  // Helper para filas de información
  Widget _buildAboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}
