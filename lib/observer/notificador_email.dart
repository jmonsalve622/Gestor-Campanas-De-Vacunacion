import 'cita_listener.dart';
import '../modelos/cita.dart';

class NotificadorEmail implements CitaListener {
  
  //RF-15
  @override
  void onCitaAgendada(Cita cita) {
    print("✉️ [EMAIL ENVIADO] Confirmación: Su cita (ID: ${cita.id}) ha sido agendada exitosamente para la fecha ${cita.fechaHora}.");
  }

  //RF-17 Cancelar cita
  @override
  void onCitaCancelada(Cita cita) {
    print("✉️ [EMAIL ENVIADO] Alerta: Su cita (ID: ${cita.id}) ha sido CANCELADA según lo solicitado.");
  }

  //RF-17 Reprogramar cita
  @override
  void onCitaReprogramada(Cita cita) {
    print("✉️ [EMAIL ENVIADO] Actualización: Su cita (ID: ${cita.id}) ha sido REPROGRAMADA para la nueva fecha ${cita.fechaHora}.");
  }
}