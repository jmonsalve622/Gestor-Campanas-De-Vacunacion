import '../modelos/cita.dart';

class NotificacionService {
  
  //RF-16
  void enviarRecordatoriosDiarios(List<Cita> citasDelDiaSiguiente) {
    print("⏰ Iniciando proceso automático de recordatorios...");
    
    if (citasDelDiaSiguiente.isEmpty) {
      print("No hay citas para recordar.");
      return;
    }

    for (var cita in citasDelDiaSiguiente) {
      if (cita.estado == "AGENDADA" || cita.estado == "REPROGRAMADA") {
        print("🔔 [RECORDATORIO SMS/EMAIL] Recuerde que mañana tiene su cita de vacunación a las ${cita.fechaHora}. (ID Cita: ${cita.id})");
      }
    }
    print("✅ Proceso de recordatorios finalizado.");
  }
}