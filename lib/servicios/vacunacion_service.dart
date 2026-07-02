// lib/services/vacunacion_service.dart
import '../modelos/centro_vacunacion.dart';

class VacunacionService {
  final List<String> jornadaCompleta = [
    "09:00",
    "09:30",
    "10:00",
    "10:30",
    "11:00",
    "11:30",
    "12:00",
    "12:30",
  ];

  /// Consulta los horarios disponibles para un componente específico
  Future<List<String>> consultarDisponibilidad(
    CentroVacunacion centro,
    DateTime fecha,
  ) async {
    int idCentro = centro.id;

    // Obtener horarios ya agendados desde la BD
    List<String> horariosOcupados = await obtenerReservasEnBD(idCentro, fecha);

    // Retornar la resta lógica (Jornada - Ocupados)
    return jornadaCompleta
        .where((horario) => !horariosOcupados.contains(horario))
        .toList();
  }

  Future<List<String>> obtenerReservasEnBD(int centroId, DateTime fecha) async {
    // Simulando consulta SQL:
    // SELECT horario FROM Reservas WHERE centro_id = $centroId AND fecha = '$fecha'
    await Future.delayed(const Duration(milliseconds: 500));

    return ["10:00", "11:30"]; // Horarios simulados que ya están tomados
  }
}
