// lib/models/cita.dart
import 'centro_vacunacion.dart';
import 'vacunacion.dart';
import 'campana.dart';

enum CitaEstado { disponible, reservada, reagendada, completada, cancelada }

class CitaEvento {
  const CitaEvento({
    required this.estado,
    required this.responsable,
    required this.fechaHora,
    required this.detalle,
  });

  final CitaEstado estado;
  final String responsable;
  final DateTime fechaHora;
  final String detalle;

  @override
  String toString() {
    return 'CitaEvento{estado: ${estado.label}, responsable: $responsable, fechaHora: $fechaHora, detalle: $detalle}';
  }
}

extension CitaEstadoLabel on CitaEstado {
  String get label {
    switch (this) {
      case CitaEstado.disponible:
        return 'DISPONIBLE';
      case CitaEstado.reservada:
        return 'RESERVADA';
      case CitaEstado.reagendada:
        return 'REAGENDADA';
      case CitaEstado.completada:
        return 'COMPLETADA';
      case CitaEstado.cancelada:
        return 'CANCELADA';
    }
  }
}

class Cita {
  int id;
  String fechaHora;
  CitaEstado estado;
  String? pacienteRut;
  String? pacienteNombre;
  String? pacienteCorreo;
  Campana? campana;
  CentroVacunacion? centroVacunacion;
  Vacunacion? vacunacion;
  List<CitaEvento> historial = [];

  // Constructor principal
  Cita({
    required this.id,
    required this.fechaHora,
    this.estado = CitaEstado.disponible,
    this.pacienteRut,
    this.pacienteNombre,
    this.pacienteCorreo,
    this.campana,
    this.centroVacunacion,
    this.vacunacion,
    List<CitaEvento>? historial,
  }) : historial = historial ?? [];

  void registrarCambioEstado(
    CitaEstado nuevoEstado, {
    required String responsable,
    String detalle = '',
  }) {
    estado = nuevoEstado;
    historial.add(
      CitaEvento(
        estado: nuevoEstado,
        responsable: responsable,
        fechaHora: DateTime.now(),
        detalle: detalle,
      ),
    );
  }

  bool get estaDisponible => estado == CitaEstado.disponible;

  bool get estaReservada => estado == CitaEstado.reservada;

  bool get estaReagendada => estado == CitaEstado.reagendada;

  bool get estaCompletada => estado == CitaEstado.completada;

  bool get estaCancelada => estado == CitaEstado.cancelada;

  void reservar({
    required String rut,
    required String nombre,
    required String correo,
    String responsable = 'Sistema',
  }) {
    pacienteRut = rut;
    pacienteNombre = nombre;
    pacienteCorreo = correo;
    registrarCambioEstado(
      CitaEstado.reservada,
      responsable: responsable,
      detalle: 'Reserva creada para $correo',
    );
  }

  Cita reagendar({
    required int nuevaId,
    required String nuevaFechaHora,
    String responsable = 'Sistema',
  }) {
    registrarCambioEstado(
      CitaEstado.reagendada,
      responsable: responsable,
      detalle: 'La cita fue reagendada a $nuevaFechaHora',
    );
    return Cita(
      id: nuevaId,
      fechaHora: nuevaFechaHora,
      estado: CitaEstado.reservada,
      pacienteRut: pacienteRut,
      pacienteNombre: pacienteNombre,
      pacienteCorreo: pacienteCorreo,
      campana: campana,
      centroVacunacion: centroVacunacion,
      historial: [
        CitaEvento(
          estado: CitaEstado.reservada,
          responsable: responsable,
          fechaHora: DateTime.now(),
          detalle: 'Nueva cita generada desde reagendamiento',
        ),
      ],
    );
  }

  void completar({
    Vacunacion? nuevaVacunacion,
    String responsable = 'Sistema',
  }) {
    vacunacion = nuevaVacunacion;
    registrarCambioEstado(
      CitaEstado.completada,
      responsable: responsable,
      detalle: 'Se registró vacunación',
    );
  }

  void cancelar({String responsable = 'Sistema'}) {
    registrarCambioEstado(
      CitaEstado.cancelada,
      responsable: responsable,
      detalle: 'La cita fue cancelada',
    );
  }

  @override
  String toString() {
    // "Cita{id=$id, fechaHora='$fechaHora', estado='$estado', campana=$campana, centroVacunacion=$centroVacunacion, vacunacion=$vacunacion}";
    return "Cita{id=$id, fechaHora='$fechaHora', estado='${estado.label}', pacienteNombre='$pacienteNombre', centroVacunacion=$centroVacunacion}";
  }
}
