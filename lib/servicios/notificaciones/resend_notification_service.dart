import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../modelos/Persona.dart';
import '../../modelos/cita.dart';
import 'notification_service.dart';

class ResendNotificationService implements NotificationService {
  const ResendNotificationService();

  String? get _apiKey => Platform.environment['RESEND_API_KEY'];

  @override
  Future<void> sendReservationConfirmation({
    required String from,
    required String to,
    required Persona persona,
    required Cita cita,
  }) async {
    await _sendEmail(
      from: from,
      to: to,
      subject: 'Confirmacion de cita reservada',
      html:
          '''
        <h1>Tu cita fue registrada</h1>
        <p>Hola ${persona.nombres} ${persona.apellidos},</p>
        <p>La cita <strong>#${cita.id}</strong> quedo agendada para <strong>${cita.fechaHora}</strong>.</p>
        <p>Centro: ${cita.centroVacunacion?.nombre ?? 'No especificado'}</p>
      ''',
    );
  }

  @override
  Future<void> sendVaccinationConfirmation({
    required String from,
    required String to,
    required Persona persona,
    required Cita cita,
  }) async {
    await _sendEmail(
      from: from,
      to: to,
      subject: 'Confirmacion de vacunacion',
      html:
          '''
        <h1>Vacunacion registrada</h1>
        <p>Hola ${persona.nombres} ${persona.apellidos},</p>
        <p>La cita <strong>#${cita.id}</strong> fue marcada como <strong>${cita.estado}</strong>.</p>
        <p>Gracias por participar en la campana.</p>
      ''',
    );
  }

  @override
  Future<void> sendReminderNotification({
    required String from,
    required String to,
    required Persona persona,
    required Cita cita,
  }) async {
    await _sendEmail(
      from: from,
      to: to,
      subject: 'Recordatorio de cita de vacunacion',
      html:
          '''
        <h1>Recordatorio de cita</h1>
        <p>Hola ${persona.nombres} ${persona.apellidos},</p>
        <p>Recuerda tu cita <strong>#${cita.id}</strong> para <strong>${cita.fechaHora}</strong>.</p>
      ''',
      fallbackLog: '[NOTIFY][RECORDATORIO] cita=${cita.id} destino=$to',
    );
  }

  @override
  Future<void> sendRescheduleNotification({
    required String from,
    required String to,
    required Persona persona,
    required Cita cita,
    required String nuevoHorario,
  }) async {
    await _sendEmail(
      from: from,
      to: to,
      subject: 'Cita reagendada',
      html:
          '''
        <h1>Tu cita fue reagendada</h1>
        <p>Hola ${persona.nombres} ${persona.apellidos},</p>
        <p>La cita <strong>#${cita.id}</strong> se movio al horario <strong>$nuevoHorario</strong>.</p>
        <p>El estado anterior quedo como REAGENDADA y se creo una nueva cita.</p>
      ''',
    );
  }

  Future<void> _sendEmail({
    required String from,
    required String to,
    required String subject,
    required String html,
    String? fallbackLog,
  }) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint(
        fallbackLog ??
            '[NOTIFY][SIMULADO] subject=$subject destino=$to sin RESEND_API_KEY',
      );
      return;
    }

    final uri = Uri.parse('https://api.resend.com/emails');
    final request = await HttpClient().postUrl(uri);
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.write(
      jsonEncode({
        'from': from,
        'to': [to],
        'subject': subject,
        'html': html,
      }),
    );

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Resend respondio con ${response.statusCode}: $responseBody',
        uri: uri,
      );
    }
  }
}
