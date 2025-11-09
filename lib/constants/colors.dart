import 'package:flutter/material.dart';

class PokemonColors {
  static const Color psychic = Color(0xFFEF3F7A);
  static const Color steel = Color(0xFF002BB8);
  static const Color bug = Color(0xFF92A212);
  static const Color dragon = Color(0xFF4F60E2);
  static const Color ghost = Color(0xFF713F71);
  static const Color fairy = Color(0xFFEF71F0);
  static const Color normal = Color(0xFFA0A2A0);
  static const Color rock = Color(0xFFB0AB82);
  static const Color ground = Color(0xFF92501B);
  static const Color flying = Color(0xFF82BAF0);
  static const Color poison = Color(0xFF923FCC);
  static const Color fighting = Color(0xFFC03028); // Añadí color para lucha
  static const Color ice = Color(0xFF98D8D8); // Añadí color para hielo

  // Colores estándar
  static const Color grass = Colors.green;
  static const Color fire = Colors.red;
  static const Color water = Colors.blue;
  static const Color electric = Color(0xFFF7D02C);
  static const Color dark = Colors.brown;
}

Color getTypeColor(String type) {
  switch (type.toLowerCase()) {
    case 'grass':
      return PokemonColors.grass;
    case 'fire':
      return PokemonColors.fire;
    case 'water':
      return PokemonColors.water;
    case 'electric':
      return PokemonColors.electric;
    case 'psychic':
      return PokemonColors.psychic;
    case 'ice':
      return PokemonColors.ice;
    case 'dragon':
      return PokemonColors.dragon;
    case 'dark':
      return PokemonColors.dark;
    case 'fairy':
      return PokemonColors.fairy;
    case 'normal':
      return PokemonColors.normal;
    case 'fighting':
      return PokemonColors.fighting;
    case 'flying':
      return PokemonColors.flying;
    case 'poison':
      return PokemonColors.poison;
    case 'ground':
      return PokemonColors.ground;
    case 'rock':
      return PokemonColors.rock;
    case 'bug':
      return PokemonColors.bug;
    case 'ghost':
      return PokemonColors.ghost;
    case 'steel':
      return PokemonColors.steel;
    default:
      return Colors.grey;
  }
}
