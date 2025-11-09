import 'package:flutter/material.dart';

class PokemonSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onClear;

  const PokemonSearchBar({
    Key? key,
    required this.onSearchChanged,
    required this.onClear,
  }) : super(key: key);

  @override
  State<PokemonSearchBar> createState() => _PokemonSearchBarState();
}

class _PokemonSearchBarState extends State<PokemonSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Buscar Pokémon...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onChanged: (value) {
          setState(() {
            _hasText = value.isNotEmpty;
          });
          widget.onSearchChanged(value);
        },
      ),
    );
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _hasText = false;
    });
    widget.onClear();
  }
}
