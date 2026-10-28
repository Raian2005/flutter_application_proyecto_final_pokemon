import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/Estadisticas.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/GrupoHuevo.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/Habilidad.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/Tipo.dart';

class Pokemon {
  final String id;
  final String name;
  final int nationalDex;
  final String arte;
  final String sprite;
  final String shinySprite;
  final String shinyArte;
  final String peso;
  final String altura;

  final List<Tipo> tipos;
  final List<Habilidad> habilidades;
  final List<GrupoHuevo> gruposHuevos;
  final List<String?> evoId;
  final String regionId;
  final bool isFavorito;
  final Estadisticas stats;

  final bool isForma; // Indica si el Pokémon tiene formas alternativas
  final String? forma; // Nombre de la forma alternativa, si aplica
  ///FALTA VER COMO SON LAS FORMAS DEL POKEMON, SI ES QUE TIENE, PARA PODER AGREGARLO AQUI O SEA GALAR, ALOLA, NO OLVIDAR MEGAEVOLUCIONES Y DINA/GIGAMAX
  Pokemon({
    required this.id,
    required this.name,
    required this.nationalDex,
    required this.arte,
    required this.sprite,
    required this.shinySprite,
    required this.shinyArte,
    required this.peso,
    required this.altura,
    required this.tipos,
    required this.habilidades,
    required this.gruposHuevos,
    required this.evoId,
    required this.regionId,
    required this.isFavorito,
    required this.stats,
    required this.isForma,
    this.forma,
  });
}
