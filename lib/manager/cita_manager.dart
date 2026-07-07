// lib/manager/cita_manager.dart
import '../modelos/cita.dart';
import '../observer/cita_listener.dart';

class CitaManager {
  final List<CitaListener> _listeners = [];
  final List<Cita> _citas = [];
  int _contadorId = 1;

  void subscribe(CitaListener listener) {
    _listeners.add(listener);
  }

  void unsubscribe(CitaListener listener) {
    _listeners.remove(listener);
  }

  void _notificar(Cita cita, String evento) {
    for (var l in _listeners) {
      switch (evento) {
        case "AGENDADA":
          l.onCitaAgendada(cita);
          break;
        case "CANCELADA":
          l.onCitaCancelada(cita);
          break;
        case "REPROGRAMADA":
          l.onCitaReprogramada(cita);
          break;
      }
    }
  }

  void agendarCita(String fechaHora) {
    Cita cita = Cita(
      id: _contadorId++,
      fechaHora: fechaHora,
      estado: CitaEstado.reservada,
    );
    _citas.add(cita);
    _notificar(cita, "AGENDADA");
  }

  void cancelarCita(int id) {
    Cita? cita = _buscarPorId(id);
    if (cita == null) {
      print("Cita no encontrada.");
      return;
    }
    cita.estado = CitaEstado.cancelada;
    _notificar(cita, "CANCELADA");
  }

  void reprogramarCita(int id, String nuevaFecha) {
    Cita? cita = _buscarPorId(id);
    if (cita == null) {
      print("Cita no encontrada.");
      return;
    }
    cita.estado = CitaEstado.reagendada;
    Cita nuevaCita = Cita(
      id: _contadorId++,
      fechaHora: nuevaFecha,
      estado: CitaEstado.reservada,
      campana: cita.campana,
      centroVacunacion: cita.centroVacunacion,
      pacienteRut: cita.pacienteRut,
      pacienteNombre: cita.pacienteNombre,
      pacienteCorreo: cita.pacienteCorreo,
    );
    _citas.add(nuevaCita);
    _notificar(cita, "REPROGRAMADA");
  }

  void listarCitas() {
    if (_citas.isEmpty) {
      print("No hay citas registradas.");
      return;
    }
    for (var cita in _citas) {
      print(cita.toString());
    }
  }

  List<Cita> get citas => _citas;

  Cita? _buscarPorId(int id) {
    try {
      return _citas.firstWhere((c) => c.id == id);
    } catch (e) {
      return null; // Devuelve null si no encuentra coincidencias
    }
  }
}
