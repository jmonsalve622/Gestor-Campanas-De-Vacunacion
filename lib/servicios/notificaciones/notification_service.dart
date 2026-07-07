import '../../modelos/Persona.dart';
import '../../modelos/cita.dart';

abstract class NotificationService {
  Future<void> sendReservationConfirmation({
    required String from,
    required String to,
    required Persona persona,
    required Cita cita,
  });

  Future<void> sendVaccinationConfirmation({
    required String from,
    required String to,
    required Persona persona,
    required Cita cita,
  });

  Future<void> sendRescheduleNotification({
    required String from,
    required String to,
    required Persona persona,
    required Cita cita,
    required String nuevoHorario,
  });

  Future<void> sendReminderNotification({
    required String from,
    required String to,
    required Persona persona,
    required Cita cita,
  });
}
