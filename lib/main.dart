import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart'; // 👈 Import necesario para Hive
import 'package:pokedex_app/screens/pokemon_list_screen.dart';
import 'package:pokedex_app/services/pokemon_service.dart';
import 'package:pokedex_app/bloc/pokemon_list/pokemon_list_bloc.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // 👈 Asegura inicialización de Flutter
  await Hive.initFlutter(); // 👈 Inicializa Hive antes de usarlo
  await Hive.openBox('pokemonBox');
  await Hive.openBox('favorites');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PokemonListBloc(pokemonService: PokemonService())
            ..add(const PokemonListFetch()), // 👈 carga inicial del bloc
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pokédex',
        themeMode: _themeMode,
        theme: ThemeData(
          brightness: Brightness.light,
          textTheme: GoogleFonts.poppinsTextTheme(),
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          textTheme: GoogleFonts.poppinsTextTheme(
            ThemeData.dark().textTheme,
          ),
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.dark,
          ),
        ),
        home: Builder(
          builder: (context) {
            return PokemonListScreen(
              onToggleTheme: _toggleTheme, // 👈 callback para cambiar tema
            );
          },
        ),
      ),
    );
  }
}
