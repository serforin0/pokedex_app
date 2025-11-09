import 'package:flutter/material.dart';

class GenerationFilter extends StatefulWidget {
  final int selectedGeneration;
  final Function(int) onGenerationChanged;

  const GenerationFilter({
    Key? key,
    required this.selectedGeneration,
    required this.onGenerationChanged,
  }) : super(key: key);

  @override
  State<GenerationFilter> createState() => _GenerationFilterState();
}

class _GenerationFilterState extends State<GenerationFilter> {
  final Map<int, String> _generations = {
    1: 'Kanto (1-151)',
    2: 'Johto (152-251)',
    3: 'Hoenn (252-386)',
    4: 'Sinnoh (387-493)',
    5: 'Unova (494-649)',
    6: 'Kalos (650-721)',
    7: 'Alola (722-809)',
    8: 'Galar (810-905)',
    9: 'Paldea (906-1025)',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Generación:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _generations.entries.map((entry) {
              final isSelected = widget.selectedGeneration == entry.key;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    entry.value,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.red[400],
                  selected: isSelected,
                  onSelected: (selected) {
                    widget.onGenerationChanged(entry.key);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
