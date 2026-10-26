class Movimiento {
  final String nombre;
  final String id;
  final String? descripcion;
  final int? potencia;
  final int? precision;
  final int? pp;
  final String metodoAprendizaje;
  final int nivelAprendizaje;
  final String? generacionAprendizaje;

  Movimiento({
    required this.nombre,
    required this.id,
    required this.descripcion,
    required this.potencia,
    required this.precision,
    required this.pp,
    required this.metodoAprendizaje,
    required this.nivelAprendizaje,
    required this.generacionAprendizaje,
  });
}