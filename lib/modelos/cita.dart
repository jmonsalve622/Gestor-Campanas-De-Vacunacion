class Cita {
  final int id;
  final int centroId;
  final DateTime fecha;
  final String hora;
  String estado; // "agendada", "cancelada", "completada"

  Cita({
    required this.id,
    required this.centroId,
    required this.fecha,
    required this.hora,
    this.estado = "agendada",
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'],
      centroId: json['centro_id'],
      fecha: DateTime.parse(json['fecha']),
      hora: json['hora'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'centro_id': centroId,
      'fecha': fecha.toIso8601String().split('T')[0], // Guarda solo YYYY-MM-DD
      'hora': hora,
      'estado': estado,
    };
  }
}
