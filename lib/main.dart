// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex_app/bloc/pokemon_list/pokemon_list_bloc.dart';
import 'package:pokedex_app/screens/pokemon_list_screen.dart';
import 'package:pokedex_app/services/pokemon_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PokemonListBloc>(
          create: (context) => PokemonListBloc(pokemonService: PokemonService())
            ..add(const PokemonListFetch()),
        ),
      ],
      child: MaterialApp(
        title: 'Pokédex',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const PokemonListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
