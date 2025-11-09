import 'package:flutter/material.dart';

class TypeFilterChip extends StatelessWidget {
  final List<String> selectedTypes;
  final ValueChanged<List<String>> onTypesChanged;

  const TypeFilterChip({
    super.key,
    required this.selectedTypes,
    required this.onTypesChanged,
  });

  // Lista de tipos principales de Pokémon
  List<String> get types => const [
        'Normal',
        'Fire',
        'Water',
        'Grass',
        'Electric',
        'Ice',
        'Fighting',
        'Poison',
        'Ground',
        'Flying',
        'Psychic',
        'Bug',
        'Rock',
        'Ghost',
        'Dark',
        'Dragon',
        'Steel',
        'Fairy',
      ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: types.map((type) {
          final isSelected = selectedTypes.contains(type);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(
                type,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              selectedColor: _getTypeColor(type),
              backgroundColor: Colors.grey[200],
              onSelected: (selected) {
                final newSelection = [...selectedTypes];
                if (selected) {
                  newSelection
                      .clear(); // solo un tipo a la vez (si prefieres múltiples, quita esto)
                  newSelection.add(type);
                } else {
                  newSelection.remove(type);
                }
                onTypesChanged(newSelection);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Fire':
        return Colors.redAccent;
      case 'Water':
        return Colors.blueAccent;
      case 'Grass':
        return Colors.green;
      case 'Electric':
        return Colors.amber;
      case 'Ice':
        return Colors.cyan;
      case 'Fighting':
        return Colors.orange;
      case 'Poison':
        return Colors.purpleAccent;
      case 'Ground':
        return Colors.brown;
      case 'Flying':
        return Colors.indigoAccent;
      case 'Psychic':
        return Colors.pinkAccent;
      case 'Bug':
        return Colors.lightGreen;
      case 'Rock':
        return Colors.grey;
      case 'Ghost':
        return Colors.deepPurple;
      case 'Dark':
        return Colors.black54;
      case 'Dragon':
        return Colors.indigo;
      case 'Steel':
        return Colors.blueGrey;
      case 'Fairy':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}
