import 'campana.dart';
import 'cita.dart';

class Vacunacion {
  int id;
  String fechaHora;
  String observaciones;
  Campana? campana;
  Cita? cita;

  // Constructor principal
  Vacunacion({
    required this.id,
    required this.fechaHora,
    this.observaciones = "",
    this.campana,
    this.cita,
  });

  @override
  String toString() {
    return 'Vacunacion(id: $id, fechaHora: $fechaHora, observaciones: $observaciones, campana: $campana, cita: $cita)';
  }
}