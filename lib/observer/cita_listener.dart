import '../modelos/cita.dart';

abstract class CitaListener {
  void onCitaAgendada(Cita cita);
  void onCitaCancelada(Cita cita);
  void onCitaReprogramada(Cita cita);
}
