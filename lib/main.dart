import 'package:flutter/material.dart';
import 'package:pokedex_app/screens/pokemon_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _CustomPageTransitionBuilder(),
            TargetPlatform.iOS: _CustomPageTransitionBuilder(),
          },
        ),
      ),
      home: PokemonListScreen(), // QUITA el 'const' aquí
      debugShowCheckedModeBanner: false,
    );
  }
}

class _CustomPageTransitionBuilder extends PageTransitionsBuilder {
  const _CustomPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}
