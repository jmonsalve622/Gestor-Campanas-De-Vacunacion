import '../modelos/campana.dart';

class CampanaBuilder {
  int contadorId = 0;
  String _nombre = '';
  String _descripcion = '';
  String _fechaInicio = '';
  String _fechaFin = '';

  CampanaBuilder setNombre(String nombre) {
    _nombre = nombre;
    return this;
  }

  CampanaBuilder setDescripcion(String descripcion) {
    _descripcion = descripcion;
    return this;
  }

  CampanaBuilder setFechaInicio(String fechaInicio) {
    _fechaInicio = fechaInicio;
    return this;
  }

  CampanaBuilder setFechaFin(String fechaFin) {
    _fechaFin = fechaFin;
    return this;
  }

  Campana build() {
    if (_nombre.isEmpty || _descripcion.isEmpty || _fechaInicio.isEmpty || _fechaFin.isEmpty) {
      throw Exception('Todos los campos son obligatorios para construir una Campaña.');
    }
    
    return Campana(
      id: ++contadorId,
      nombre: _nombre,
      descripcion: _descripcion,
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
    );
  }
}