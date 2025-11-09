import 'package:flutter/material.dart';
import 'package:pokedex_app/services/pokemon_service.dart';
import '../models/pokemon.dart';
import '../constants/colors.dart';

class PokemonDetailScreen extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonDetailScreen({Key? key, required this.pokemon})
    : super(key: key);

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  List<PokemonEvolution> _evolutions = [];
  bool _isLoadingEvolutions = true;

  @override
  void initState() {
    super.initState();
    _loadEvolutions();
  }

  Future<void> _loadEvolutions() async {
    try {
      final evolutions = await PokemonService().getPokemonEvolutions(
        widget.pokemon.id,
      );
      setState(() {
        _evolutions = evolutions;
        _isLoadingEvolutions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingEvolutions = false;
      });
    }
  }

  Widget _buildEvolutionTab() {
    if (_isLoadingEvolutions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_evolutions.isEmpty) {
      return _buildNoEvolutions();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildEvolutionChain(),
          const SizedBox(height: 20),
          _buildEvolutionMethods(),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.pokemon.name} is in its final form',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionChain() {
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

          // Pokémon actual
          _buildEvolutionStep(
            widget.pokemon.name,
            widget.pokemon.imageUrl,
            widget.pokemon.id,
            isCurrent: true,
          ),

          // Evoluciones
          ..._evolutions.asMap().entries.map((entry) {
            final index = entry.key;
            final evolution = entry.value;
            return Column(
              children: [
                _buildEvolutionArrow(evolution),
                _buildEvolutionStep(
                  evolution.name,
                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${evolution.id}.png',
                  evolution.id,
                  evolution: evolution,
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEvolutionStep(
    String name,
    String imageUrl,
    int id, {
    bool isCurrent = false,
    PokemonEvolution? evolution,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Imagen del Pokémon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isCurrent
                    ? getTypeColor(widget.pokemon.types.first)
                    : Colors.grey[300]!,
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
                        getTypeColor(widget.pokemon.types.first),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.catching_pokemon, color: Colors.grey[400]);
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCurrent
                        ? getTypeColor(widget.pokemon.types.first)
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
          ),
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
    String methodText = '';

    if (evolution.level > 0) {
      methodText = 'Level $evolution.level';
    } else if (evolution.item.isNotEmpty) {
      methodText = 'Use ${evolution.item.replaceAll('-', ' ').toUpperCase()}';
    } else if (evolution.method == 'trade') {
      methodText = 'Trade';
    } else {
      methodText = 'Special Condition';
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: getTypeColor(widget.pokemon.types.first).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        methodText,
        style: TextStyle(
          fontSize: 10,
          color: getTypeColor(widget.pokemon.types.first),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEvolutionMethods() {
    final methods = _evolutions.where((e) => e.method.isNotEmpty).toList();

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
          ...methods.map((evolution) => _buildMethodDetail(evolution)).toList(),
        ],
      ),
    );
  }

  Widget _buildMethodDetail(PokemonEvolution evolution) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: getTypeColor(widget.pokemon.types.first),
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
  }

  String _getMethodDescription(PokemonEvolution evolution) {
    if (evolution.level > 0) {
      return 'Reach Level ${evolution.level}';
    } else if (evolution.item.isNotEmpty) {
      return 'Use ${evolution.item.replaceAll('-', ' ').toUpperCase()}';
    } else if (evolution.method == 'trade') {
      return 'Trade with another player';
    } else {
      return 'Special condition';
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 10),
      child: Row(
        children: [
          // Botón de regreso
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          const Spacer(),

          // Número del Pokémon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '#${widget.pokemon.id.toString().padLeft(3, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Fondo con gradiente
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  getTypeColor(widget.pokemon.types.first).withOpacity(0.9),
                  getTypeColor(widget.pokemon.types.first).withOpacity(0.7),
                  getTypeColor(widget.pokemon.types.first).withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),

        // Imagen del Pokémon centrada
        Center(
          child: Container(
            width: 220, // Tamaño fijo generoso
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
                tag: 'pokemon-image-${widget.pokemon.id}',
                child: Image.network(
                  widget.pokemon.imageUrl,
                  height:
                      200, // Imagen ligeramente más pequeña que el contenedor
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
                    return Icon(
                      Icons.catching_pokemon,
                      size: 80,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard() {
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
            // Espacio antes del nombre
            const SizedBox(height: 30),

            // Nombre y tipos
            _buildNameAndTypes(),

            const SizedBox(height: 24),

            // Pestañas
            _buildTabBar(),

            // Contenido de pestañas
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildNameAndTypes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.pokemon.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: widget.pokemon.types.map((type) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
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
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
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
              color: getTypeColor(widget.pokemon.types.first),
            ),
            insets: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: getTypeColor(widget.pokemon.types.first),
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

  Widget _buildTabContent() {
    return TabBarView(
      children: [_buildAboutTab(), _buildStatsTab(), _buildEvolutionTab()],
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Pokédex Data', [
            _buildInfoRow('Species', widget.pokemon.species),
            _buildInfoRow('Height', '${widget.pokemon.height} m'),
            _buildInfoRow('Weight', '${widget.pokemon.weight} kg'),
            _buildInfoRow('Abilities', widget.pokemon.abilities.join(', ')),
          ]),

          const SizedBox(height: 16),

          _buildInfoCard('Training', [
            _buildInfoRow('Base EXP', widget.pokemon.baseExperience.toString()),
            _buildInfoRow('Growth Rate', widget.pokemon.growthRate),
          ]),

          const SizedBox(height: 16),

          _buildWeaknessesCard(),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildStatCard('HP', widget.pokemon.hp, 255, Colors.green),
          _buildStatCard('Attack', widget.pokemon.attack, 255, Colors.red),
          _buildStatCard('Defense', widget.pokemon.defense, 255, Colors.blue),
          _buildStatCard(
            'Sp. Atk',
            widget.pokemon.specialAttack,
            255,
            Colors.purple,
          ),
          _buildStatCard(
            'Sp. Def',
            widget.pokemon.specialDefense,
            255,
            Colors.orange,
          ),
          _buildStatCard('Speed', widget.pokemon.speed, 255, Colors.pink),

          const SizedBox(height: 16),

          Container(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: getTypeColor(widget.pokemon.types.first),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.pokemon.totalStats.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildWeaknessesCard() {
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
            children: widget.pokemon.weaknesses.map((weakness) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
            }).toList(),
          ),
        ],
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
    double percentage = value / maxValue;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getTypeColor(widget.pokemon.types.first),
      body: Column(
        children: [
          // Header
          _buildHeader(context),

          // Imagen del Pokémon con más espacio
          Expanded(
            flex: 2, // Más espacio para la imagen
            child: _buildImageSection(),
          ),

          // Tarjeta de contenido con bordes redondeados
          Expanded(
            flex: 3, // Menos espacio para el contenido
            child: _buildContentCard(),
          ),
        ],
      ),
    );
  }
}
