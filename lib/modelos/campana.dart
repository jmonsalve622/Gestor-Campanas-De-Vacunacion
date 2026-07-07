import 'centro_vacunacion.dart';
import 'vacunacion.dart';
import 'componente_vacunacion.dart';

class Campana implements ComponenteVacunacion {
  int id;
  String nombre;
  String descripcion;
  String fechaInicio;
  String fechaFin;
  String estado;
  List<CentroVacunacion> centros = [];
  List<Vacunacion> vacunaciones = [];

  Campana({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    this.estado = "ACTIVA",
  });

  void agregarCentroVacunacion(CentroVacunacion centro) {
    if (!centros.any((element) => element.id == centro.id)) {
      centros.add(centro);
      centro.vincularCampana(this);
    }
  }

  void eliminarCentroVacunacion(CentroVacunacion centro) {
    centros.remove(centro);
  }

  List<CentroVacunacion> get centrosVacunacion => centros;

  void agregarVacunacion(Vacunacion vacunacion) {
    vacunaciones.add(vacunacion);
  }

  @override
  int getCitas() {
    int totalCitas = 0;
    for (var centro in centros) {
      totalCitas += centro.getCitas();
    }
    return totalCitas;
  }

  @override
  int getVacunas() {
    return vacunaciones.length;
  }

  @override
  String toString() {
    return 'Campana(id: $id, nombre: $nombre, descripcion: $descripcion, fechaInicio: $fechaInicio, fechaFin: $fechaFin, estado: $estado, centros: $centros, vacunaciones: $vacunaciones)';
  }
}
