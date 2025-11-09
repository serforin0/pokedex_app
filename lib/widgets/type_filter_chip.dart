import 'package:flutter/material.dart';
import '../constants/colors.dart';

class TypeFilterChip extends StatefulWidget {
  final List<String> selectedTypes;
  final Function(List<String>) onTypesChanged;

  const TypeFilterChip({
    Key? key,
    required this.selectedTypes,
    required this.onTypesChanged,
  }) : super(key: key);

  @override
  State<TypeFilterChip> createState() => _TypeFilterChipState();
}

class _TypeFilterChipState extends State<TypeFilterChip> {
  final List<String> _allTypes = [
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
    'fairy',
  ];

  void _toggleType(String type) {
    setState(() {
      if (widget.selectedTypes.contains(type)) {
        widget.selectedTypes.remove(type);
      } else {
        widget.selectedTypes.add(type);
      }
      widget.onTypesChanged(List.from(widget.selectedTypes));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                'Tipos:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 8),
              if (widget.selectedTypes.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.selectedTypes.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),

        SizedBox(
          height: 40, // Altura fija para una sola fila
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _allTypes.map((type) {
                final isSelected = widget.selectedTypes.contains(type);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(
                      _getTypeDisplayName(type),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 11, // Texto más pequeño
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.grey[200],
                    selectedColor: getTypeColor(type),
                    selected: isSelected,
                    checkmarkColor: Colors.white,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 0,
                    ),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    onSelected: (selected) => _toggleType(type),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _getTypeDisplayName(String type) {
    final Map<String, String> typeNames = {
      'normal': 'Normal',
      'fire': 'Fuego',
      'water': 'Agua',
      'electric': 'Eléctrico',
      'grass': 'Planta',
      'ice': 'Hielo',
      'fighting': 'Lucha',
      'poison': 'Veneno',
      'ground': 'Tierra',
      'flying': 'Volador',
      'psychic': 'Psíquico',
      'bug': 'Bicho',
      'rock': 'Roca',
      'ghost': 'Fantasma',
      'dragon': 'Dragón',
      'dark': 'Siniestro',
      'steel': 'Acero',
      'fairy': 'Hada',
    };
    return typeNames[type] ?? type.toUpperCase();
  }
}
