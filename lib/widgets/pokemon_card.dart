// lib/widgets/pokemon_card.dart
import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../constants/colors.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback onTap;

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Importante para evitar overflow
            children: [
              // Número del Pokémon
              Text(
                '#${pokemon.id.toString().padLeft(3, '0')}',
                style: const TextStyle(
                  fontSize: 10, // Reducido
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Imagen del Pokémon
              Center(
                child: Container(
                  height: 60, // Reducido
                  width: 60,
                  child: Image.network(
                    pokemon.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.catching_pokemon,
                        size: 40, // Reducido
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Nombre del Pokémon
              Text(
                _formatPokemonName(pokemon.name),
                style: const TextStyle(
                  fontSize: 12, // Reducido
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Tipos del Pokémon
              _buildTypesRow(pokemon.types),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPokemonName(String name) {
    // Capitalizar primera letra
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  Widget _buildTypesRow(List<String> types) {
    return Row(
      children: types.take(2).map((type) {
        // Limitar a 2 tipos máximo
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 2), // Reducido espacio
            padding: const EdgeInsets.symmetric(
              horizontal: 4, // Reducido
              vertical: 2, // Reducido
            ),
            decoration: BoxDecoration(
              color: getTypeColor(type),
              borderRadius: BorderRadius.circular(6), // Reducido
            ),
            child: Text(
              type.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8, // Reducido
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
    );
  }
}
