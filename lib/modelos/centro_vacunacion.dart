import 'componente_vacunacion.dart';

// Actúa como el 'Leaf' en el Patrón Composite
class CentroVacunacion implements ComponenteVacunacion {
  final int id;
  final String nombre;
  final String direccion;

  // Atributos internos para cumplir con el patrón Composite
  final int _citasAgendadas;
  final int _vacunasDisponibles;

  CentroVacunacion({
    required this.id,
    required this.nombre,
    required this.direccion,
    int citasAgendadas = 0,
    int vacunasDisponibles = 0,
  }) : _citasAgendadas = citasAgendadas,
       _vacunasDisponibles = vacunasDisponibles;

  // --- Implementación del Patrón Composite ---
  @override
  int getCitas() {
    return _citasAgendadas;
  }

  @override
  int getVacunas() {
    return _vacunasDisponibles;
  }

  // Constructor de fábrica
  factory CentroVacunacion.fromJson(Map<String, dynamic> json) {
    return CentroVacunacion(
      id: json['id'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      citasAgendadas: json['citas_agendadas'] ?? 0,
      vacunasDisponibles: json['vacunas_disponibles'] ?? 0,
    );
  }
}
