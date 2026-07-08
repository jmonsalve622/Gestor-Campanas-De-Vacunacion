// lib/models/centro_vacunacion.dart
import 'componente_vacunacion.dart';
import 'cita.dart';
import 'campana.dart';

class CentroVacunacion implements ComponenteVacunacion {
  int id;
  String nombre;
  String tipo;
  String direccion;
  String comuna;
  String region;
  List<String> horariosBase;
  List<Cita> citas = [];
  List<Campana> campanas = [];

  CentroVacunacion({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.direccion,
    required this.comuna,
    required this.region,
    List<String>? horariosBase,
  }) : horariosBase = horariosBase ?? const [];

  // --- Composite: gestión de citas ---
  void agregarCita(Cita cita) {
    citas.add(cita);
  }

  void eliminarCita(Cita cita) {
    citas.remove(cita);
  }

  void vincularCampana(Campana campana) {
    if (!campanas.any((element) => element.id == campana.id)) {
      campanas.add(campana);
    }
  }

  bool horarioDisponible(String horario, {String? fecha}) {
    return !citas.any(
      (cita) =>
          cita.fechaHora == horario &&
          (fecha == null || cita.fecha == null || cita.fecha == fecha) &&
          (cita.estado == CitaEstado.reservada ||
              cita.estado == CitaEstado.completada),
    );
  }

  List<String> get horariosDisponibles {
    if (horariosBase.isEmpty) {
      return [];
    }
    return horariosBase.where((h) => horarioDisponible(h)).toList();
  }

  /// Horarios disponibles para una fecha específica
  List<String> horariosDisponiblesPorFecha(String fecha) {
    if (horariosBase.isEmpty) {
      return [];
    }
    return horariosBase.where((h) => horarioDisponible(h, fecha: fecha)).toList();
  }

  List<Cita> get citasDisponibles =>
      citas.where((cita) => cita.estado == CitaEstado.disponible).toList();

  List<Cita> get citasReservadas =>
      citas.where((cita) => cita.estado == CitaEstado.reservada).toList();

  List<Cita> get citasReagendadas =>
      citas.where((cita) => cita.estado == CitaEstado.reagendada).toList();

  List<Cita> get citasCompletadas =>
      citas.where((cita) => cita.estado == CitaEstado.completada).toList();

  List<Cita> get citasCanceladas =>
      citas.where((cita) => cita.estado == CitaEstado.cancelada).toList();

  List<Cita> get citasList => citas;

  Cita reservarHorario({
    required int id,
    required String horario,
    required String rut,
    required String nombre,
    required String correo,
    String? fecha,
    Campana? campana,
    String responsable = 'Sistema',
  }) {
    if (!horarioDisponible(horario, fecha: fecha)) {
      throw StateError('El horario no esta disponible.');
    }

    final cita = Cita(
      id: id,
      fechaHora: horario,
      fecha: fecha,
      estado: CitaEstado.reservada,
      pacienteRut: rut,
      pacienteNombre: nombre,
      pacienteCorreo: correo,
      centroVacunacion: this,
      campana: campana,
    );
    cita.registrarCambioEstado(
      CitaEstado.reservada,
      responsable: responsable,
      detalle: 'Reserva registrada en ${nombre} para horario $horario${fecha != null ? ' el $fecha' : ''}',
    );
    citas.add(cita);
    return cita;
  }

  Cita reagendarCita({
    required Cita cita,
    required int nuevaId,
    required String nuevoHorario,
    String responsable = 'Sistema',
  }) {
    if (!citas.contains(cita)) {
      throw StateError('La cita no pertenece a este centro.');
    }

    final nuevaCita = cita.reagendar(
      nuevaId: nuevaId,
      nuevaFechaHora: nuevoHorario,
      responsable: responsable,
    );
    nuevaCita.centroVacunacion = this;
    citas.add(nuevaCita);
    return nuevaCita;
  }

  void completarCita(Cita cita, {String responsable = 'Sistema'}) {
    if (!citas.contains(cita)) {
      throw StateError('La cita no pertenece a este centro.');
    }
    cita.completar(responsable: responsable);
  }

  void cancelarCita(Cita cita, {String responsable = 'Sistema'}) {
    if (!citas.contains(cita)) {
      throw StateError('La cita no pertenece a este centro.');
    }
    cita.cancelar(responsable: responsable);
  }

  @override
  int getCitas() {
    return citas.length;
  }

  @override
  int getVacunas() {
    return citas.where((cita) => cita.estado == CitaEstado.completada).length;
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
    return "CentroVacunacion{id=$id, nombre='$nombre', tipo='$tipo', direccion='$direccion', comuna='$comuna', region='$region', horariosBase=$horariosBase}";
  }
}
