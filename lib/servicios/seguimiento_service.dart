import '../modelos/persona.dart';
import '../modelos/campana.dart';
import '../modelos/cita.dart';

class SeguimientoService {
  
  //RF-12: Consulta el historial de vacunas recibidas
  List<Cita> obtenerHistorialVacunacion(Persona persona) {
    // Filtramos la lista de citas de la persona para retornar SOLO aquellas 
    // donde el objeto 'vacunacion' no sea nulo (es decir, el acto médico ya ocurrió).
    return persona.getCitas().where((cita) => cita.vacunacion != null).toList();
  }

  //RF-13: Consulta el estado del ciudadano en una campaña específica
  String consultarEstadoEnCampana(Persona persona, Campana campana) {
    List<Cita> historial = persona.getCitas();

    for (var cita in historial) {
      //Verificamos si la cita pertenece a la campaña consultada
      if (cita.campana?.id == campana.id) {
        
        if (cita.vacunacion != null) {
          return "VACUNADA"; //Ya recibió la dosis para esta campaña
        } 
        
        if (cita.estado == "AGENDADA" || cita.estado == "REPROGRAMADA") {
          return "CITA PENDIENTE"; //Está en proceso de asistir
        }
      }
    }
    
    //Si recorre todo el historial y no hay coincidencia válida
    return "NO INICIADA";
  }
}