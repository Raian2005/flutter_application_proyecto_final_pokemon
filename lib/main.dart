import 'package:flutter/material.dart';
import 'package:flutter_application_proyecto_final_pokemon/app_shell.dart';
import 'package:flutter_application_proyecto_final_pokemon/core/theme/app_theme.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/connectivity/presentation/connectivity_banner.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/favorites/presentation/favorites_page.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/presentation/pages/pokemon_catalog_page.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/setting/presentation/settings_page.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/trivia/presentation/trivia_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const PokedexApp());
}

class PokedexApp extends StatefulWidget {
  const PokedexApp({super.key});

  @override
  State<PokedexApp> createState() => _PokedexAppState();
}

class _PokedexAppState extends State<PokedexApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    PokemonCatalogPage(),
    FavoritesPage(),
    TriviaPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      home: AppShell(
        currentIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        connectivityIndicator: const ConnectivityBanner(),
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
    );
  }
}
