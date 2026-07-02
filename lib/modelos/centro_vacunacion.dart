// lib/models/centro_vacunacion.dart
import 'componente_vacunacion.dart';
import 'cita.dart';

class CentroVacunacion implements ComponenteVacunacion {
  int id;
  String nombre;
  String tipo;
  String direccion;
  String comuna;
  String region;
  List<Cita> citas = [];

  CentroVacunacion({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.direccion,
    required this.comuna,
    required this.region,
  });

  // --- Composite: gestión de citas ---
  void agregarCita(Cita cita) {
    citas.add(cita);
  }

  void eliminarCita(Cita cita) {
    citas.remove(cita);
  }

  List<Cita> get citasList => citas;

  @override
  int getCitas() {
    return citas.length;
  }

  @override
  int getVacunas() {
    // citas.where((c) => c.vacunacion != null).length;
    return 0;
  }

  /*
  // Lógica de registro
  bool registrarVacunacion(Cita? citaActual, Campana? campana, String? observaciones, Persona? persona) {
    
    if (persona == null) {
      print("Error: Persona no registrada en el sistema");
      return false;
    }
    if (citaActual == null) {
      print("Error: Cita no valida");
      return false;
    }
    if (campana == null) {
      print("Error: Campana no especificada");
      return false;
    }
    if (observaciones == null || observaciones.isEmpty) {
      print("Error: Observaciones requeridas");
      return false;
    }

    int vacunaId = DateTime.now().millisecondsSinceEpoch % 10000;
    Vacunacion nuevaVacunacion = Vacunacion(
      id: vacunaId,
      fechaHora: citaActual.fechaHora,
      observaciones: observaciones,
      campana: campana,
    );

    print("[Vacunacion creada] ID: $vacunaId, Fecha: ${citaActual.fechaHora}");

    List<Cita> historialCitas = persona.citas;
    bool validacionOK = false;
    int citasConVacunacion = 0;
    bool campanaYaExiste = false;

    for (var cita in historialCitas) {
      if (cita.id != citaActual.id && cita.vacunacion != null) {
        citasConVacunacion++;
        Vacunacion? v = cita.vacunacion;
        Campana? c = v?.campana;

        if (c != null && c.id == campana.id) {
          campanaYaExiste = true;
        }
      }
    }

    if (citasConVacunacion == 0) {
      validacionOK = true;
      print("[Validacion OK] Primera vacunacion permitida");
    } else if (campanaYaExiste) {
      validacionOK = true;
      print("[Validacion OK] Campana ${campana.nombre} existe en historial");
    } else {
      validacionOK = true;
      print("[Validacion OK] Primera vacunacion de campana ${campana.nombre}");
    }

    if (validacionOK) {
      citaActual.vacunacion = nuevaVacunacion;
      nuevaVacunacion.cita = citaActual;
      agregarCita(citaActual); // Registrar la cita en este centro (Composite)
      print("[Exito] Vacunacion registrada para ${persona.nombres}");
      return true;
    } else {
      print("[Validacion Fallida] No se pudo registrar la vacunacion");
      return false;
    }
  }
  */
  @override
  String toString() {
    return "CentroVacunacion{id=$id, nombre='$nombre', tipo='$tipo', direccion='$direccion', comuna='$comuna', region='$region'}";
  }
}
