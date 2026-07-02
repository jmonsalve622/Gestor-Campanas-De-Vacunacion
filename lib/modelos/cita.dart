// lib/models/cita.dart
import 'centro_vacunacion.dart';

class Cita {
  int id;
  String fechaHora;
  String estado;
  //Campana? campana;
  CentroVacunacion? centroVacunacion;
  //Vacunacion? vacunacion;

  // Constructor principal
  Cita({
    required this.id,
    required this.fechaHora,
    this.estado = "AGENDADA",
    //this.campana,
    this.centroVacunacion,
    //this.vacunacion,
  });

  @override
  String toString() {
    // "Cita{id=$id, fechaHora='$fechaHora', estado='$estado', campana=$campana, centroVacunacion=$centroVacunacion, vacunacion=$vacunacion}";
    return "Cita{id=$id, fechaHora='$fechaHora', estado='$estado', centroVacunacion=$centroVacunacion}";
  }
}
