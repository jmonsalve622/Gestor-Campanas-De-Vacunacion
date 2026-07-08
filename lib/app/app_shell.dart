import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../modelos/Persona.dart';
import '../modelos/campana.dart';
import '../modelos/cita.dart';
import '../modelos/centro_vacunacion.dart';
import '../modelos/vacunacion.dart';
import '../servicios/auth/auth_service.dart';
import '../servicios/notificaciones/notification_service.dart';
import '../servicios/notificaciones/resend_notification_service.dart';
import 'peticion_cita_page.dart';
import 'registro_vacuna_page.dart';
import 'creacion_campana_page.dart';

class GestorCampanasApp extends StatelessWidget {
  const GestorCampanasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de campañas de vacunación',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00AAFF)),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'CL'),
        Locale('es'),
        Locale('en'),
      ],
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final AuthService _authService = AuthService();
  final ResendNotificationService _notificationService = ResendNotificationService();

  final List<Campana> _campanas = [];
  final List<CentroVacunacion> _centros = [];
  final Map<int, Persona> _personasPorCita = {};
  final Map<String, Persona> _pacientesRegistrados = {};

  final TextEditingController _loginEmailController = TextEditingController(
    text: 'admin@demo.cl',
  );
  final TextEditingController _loginPasswordController = TextEditingController(
    text: '123456',
  );

  final TextEditingController _pacienteRutController = TextEditingController(
    text: '21.343.419-5',
  );
  final TextEditingController _pacienteNombresController =
      TextEditingController(text: 'Ana');
  final TextEditingController _pacienteApellidosController =
      TextEditingController(text: 'Perez');
  final TextEditingController _pacienteCorreoController = TextEditingController(
    text: 'paciente@demo.cl',
  );
  final TextEditingController _pacienteTelefonoController =
      TextEditingController(text: '+56912345678');

  final TextEditingController _campanaNombreController =
      TextEditingController();
  final TextEditingController _campanaDescripcionController =
      TextEditingController();
  final TextEditingController _campanaInicioController =
      TextEditingController();
  final TextEditingController _campanaFinController = TextEditingController();

  final TextEditingController _centroNombreController = TextEditingController();
  final TextEditingController _centroTipoController = TextEditingController(
    text: 'Publico',
  );
  final TextEditingController _centroDireccionController =
      TextEditingController();
  final TextEditingController _centroComunaController = TextEditingController();
  final TextEditingController _centroRegionController = TextEditingController();
  final TextEditingController _centroHorariosController = TextEditingController(
    text: '09:00, 09:30, 10:00, 10:30, 11:00, 11:30, 12:00, 12:30',
  );

  final TextEditingController _linkCampanaController = TextEditingController();
  final TextEditingController _linkCentroController = TextEditingController();
  final TextEditingController _searchCentroNombreController =
      TextEditingController();
  final TextEditingController _personaConsultaController =
      TextEditingController();
  final TextEditingController _registroPacientePasswordController =
      TextEditingController(text: '123456');
  final TextEditingController _resendApiKeyController =
      TextEditingController();

  int? _selectedLinkCampanaId;
  int? _selectedLinkCentroId;
  int? _selectedSearchCampanaId;

  int _nextCampanaId = 3;
  int _nextCentroId = 3;
  int _nextCitaId = 10;
  int _nextVacunacionId = 1;
  String _status = 'Listo para administrar campañas, centros y citas.';
  bool _showPeticionCita = false;
  bool _showRegistroVacuna = false;
  bool _showCreacionCampana = false;
  Timer? _reminderTimer;

  @override
  void initState() {
    super.initState();
    _seedDemoData();
    // Iniciar chequeo de recordatorios cada 1 minuto (o 30s para pruebas)
    _reminderTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _revisarRecordatorios();
    });
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _resendApiKeyController.dispose();
    _pacienteRutController.dispose();
    _pacienteNombresController.dispose();
    _pacienteApellidosController.dispose();
    _pacienteCorreoController.dispose();
    _pacienteTelefonoController.dispose();
    _campanaNombreController.dispose();
    _campanaDescripcionController.dispose();
    _campanaInicioController.dispose();
    _campanaFinController.dispose();
    _centroNombreController.dispose();
    _centroTipoController.dispose();
    _centroDireccionController.dispose();
    _centroComunaController.dispose();
    _centroRegionController.dispose();
    _centroHorariosController.dispose();
    _linkCampanaController.dispose();
    _linkCentroController.dispose();
    _searchCentroNombreController.dispose();
    _personaConsultaController.dispose();
    _registroPacientePasswordController.dispose();
    super.dispose();
  }

  void _seedDemoData() {
    // Campaña de Sarampión (coincide con la imagen de referencia)
    final campanaSarampion = Campana(
      id: 1,
      nombre: 'Sarampión',
      descripcion:
          'Campaña de vacunación contra el Sarampión para la población general.',
      fechaInicio: '2027-06-01',
      fechaFin: '2027-12-31',
    );

    final campanaInvierno = Campana(
      id: 2,
      nombre: 'Influenza Invierno 2027',
      descripcion:
          'Cobertura preventiva para adultos mayores y pacientes cronicos.',
      fechaInicio: '2027-06-01',
      fechaFin: '2027-08-31',
    );

    // Centro principal (coincide con la imagen)
    final centro1 = CentroVacunacion(
      id: 1,
      nombre: 'Hospital Clínico Regional Dr. Guillermo Grant Benavente',
      tipo: 'Publico',
      direccion: 'San Martín 1436',
      comuna: 'Concepción',
      region: 'Bío Bío',
      horariosBase: const [
        '09:00', '09:10', '09:20', '09:30', '09:40', '09:50',
        '10:00', '10:10', '10:20', '10:30', '10:40', '10:50',
        '11:00', '11:10',
      ],
    );

    final centro2 = CentroVacunacion(
      id: 2,
      nombre: 'CESFAM Central Concepción',
      tipo: 'Publico',
      direccion: 'Av. Los Carrera 850',
      comuna: 'Concepción',
      region: 'Bío Bío',
      horariosBase: const ['08:00', '08:30', '09:00', '09:30', '10:00'],
    );

    campanaSarampion.agregarCentroVacunacion(centro1);
    campanaSarampion.agregarCentroVacunacion(centro2);
    campanaInvierno.agregarCentroVacunacion(centro2);

    final pacienteDemo = Persona(
      rut: '21.343.419-5',
      nombres: 'Gustavo',
      apellidos: 'Riquelme',
      fechaNacimiento: DateTime(1990, 1, 1),
      correo: 'alfonsogg111@gmail.com',
      telefono: '+56912345678',
    );

    final citaReservada = centro1.reservarHorario(
      id: _nextCitaId++,
      horario: '09:00',
      rut: pacienteDemo.rut,
      nombre: '${pacienteDemo.nombres} ${pacienteDemo.apellidos}',
      correo: pacienteDemo.correo,
      campana: campanaSarampion,
    );
    pacienteDemo.agregarCita(citaReservada);
    _personasPorCita[citaReservada.id] = pacienteDemo;

    final citaCompletada = centro1.reservarHorario(
      id: _nextCitaId++,
      horario: '09:30',
      rut: pacienteDemo.rut,
      nombre: '${pacienteDemo.nombres} ${pacienteDemo.apellidos}',
      correo: pacienteDemo.correo,
      campana: campanaSarampion,
    );
    final vacunacion = Vacunacion(
      id: _nextVacunacionId++,
      fechaHora: citaCompletada.fechaHora,
      observaciones: 'Vacuna administrada en demo.',
      campana: campanaSarampion,
      cita: citaCompletada,
    );
    citaCompletada.completar(nuevaVacunacion: vacunacion);
    campanaSarampion.agregarVacunacion(vacunacion);
    pacienteDemo.agregarCita(citaCompletada);
    _personasPorCita[citaCompletada.id] = pacienteDemo;

    _campanas.addAll([campanaSarampion, campanaInvierno]);
    _centros.addAll([centro1, centro2]);
    _pacientesRegistrados[pacienteDemo.correo] = pacienteDemo;
    _linkCampanaController.text = campanaSarampion.id.toString();
    _linkCentroController.text = centro1.id.toString();
    _selectedLinkCampanaId = campanaSarampion.id;
    _selectedLinkCentroId = centro1.id;
    _selectedSearchCampanaId = campanaSarampion.id;
    _personaConsultaController.text = pacienteDemo.correo;
  }

  Campana? _campanaPorId(int id) {
    for (final campana in _campanas) {
      if (campana.id == id) {
        return campana;
      }
    }
    return null;
  }

  CentroVacunacion? _centroPorId(int id) {
    for (final centro in _centros) {
      if (centro.id == id) {
        return centro;
      }
    }
    return null;
  }

  List<String> _parseHorarios(String raw) {
    return raw
        .split(',')
        .map((horario) => horario.trim())
        .where((horario) => horario.isNotEmpty)
        .toList();
  }

  Persona _crearPersonaPaciente() {
    final correo = _pacienteCorreoController.text.trim().toLowerCase();
    
    if (correo.isNotEmpty && _pacientesRegistrados.containsKey(correo)) {
      return _pacientesRegistrados[correo]!;
    }
    
    final nueva = Persona(
      rut: _pacienteRutController.text.trim(),
      nombres: _pacienteNombresController.text.trim(),
      apellidos: _pacienteApellidosController.text.trim(),
      fechaNacimiento: DateTime(1990, 1, 1),
      correo: _pacienteCorreoController.text.trim(),
      telefono: _pacienteTelefonoController.text.trim(),
    );
    
    if (correo.isNotEmpty) {
      _pacientesRegistrados[correo] = nueva;
    }
    
    return nueva;
  }

  Persona? _buscarPersonaConsulta(String consulta) {
    final valor = consulta.trim().toLowerCase();
    if (valor.isEmpty) {
      return null;
    }

    for (final persona in _pacientesRegistrados.values) {
      if (persona.correo.toLowerCase() == valor ||
          persona.rut.toLowerCase() == valor ||
          '${persona.nombres} ${persona.apellidos}'.toLowerCase() == valor) {
        return persona;
      }
    }

    return null;
  }

  String _estadoPersonaEnCampana(Persona persona, Campana campana) {
    final citasDeCampana = persona.citas
        .where((cita) => cita.campana?.id == campana.id)
        .toList();

    if (citasDeCampana.isEmpty) {
      return 'SIN INICIAR';
    }

    return citasDeCampana.last.estado.label;
  }

  List<Cita> _citasPendientesParaRecordatorio() {
    return _centros
        .expand((centro) => centro.citas)
        .where((cita) => cita.estado == CitaEstado.reservada)
        .toList();
  }

  void _cargarPerfilPaciente(String correo) {
    final persona = _pacientesRegistrados[correo.trim().toLowerCase()];
    if (persona == null) {
      return;
    }

    _pacienteRutController.text = persona.rut;
    _pacienteNombresController.text = persona.nombres;
    _pacienteApellidosController.text = persona.apellidos;
    _pacienteCorreoController.text = persona.correo;
    _pacienteTelefonoController.text = persona.telefono;
  }

  Future<void> _login() async {
    try {
      final session = _authService.login(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );
      if (session.user.role == AppRole.paciente) {
        _pacienteCorreoController.text = session.user.email;
        _cargarPerfilPaciente(session.user.email);
      }
      setState(() {
        _status =
            'Sesion iniciada como ${session.user.fullName} (${session.user.role.label}).';
      });
    } catch (error) {
      setState(() {
        _status = 'No se pudo iniciar sesion. Verifica tus credenciales.';
      });
    }
  }

  void _logout() {
    _authService.logout();
    setState(() {
      _status = 'Sesion cerrada.';
    });
  }

  Future<void> _crearCampana() async {
    final session = _authService.requireSession();
    if (session.user.role != AppRole.admin) {
      setState(() {
        _status = 'Solo el admin puede crear campañas.';
      });
      return;
    }

    final nombre = _campanaNombreController.text.trim();
    final descripcion = _campanaDescripcionController.text.trim();
    final inicio = _campanaInicioController.text.trim();
    final fin = _campanaFinController.text.trim();

    if (nombre.isEmpty ||
        descripcion.isEmpty ||
        inicio.isEmpty ||
        fin.isEmpty) {
      setState(() {
        _status = 'Completa todos los datos de la campaña.';
      });
      return;
    }

    final campana = Campana(
      id: _nextCampanaId++,
      nombre: nombre,
      descripcion: descripcion,
      fechaInicio: inicio,
      fechaFin: fin,
    );

    setState(() {
      _campanas.add(campana);
      _linkCampanaController.text = campana.id.toString();
      _status = 'Campaña "$nombre" creada correctamente.';
    });
  }

  Future<void> _crearCentro() async {
    final session = _authService.requireSession();
    if (session.user.role != AppRole.admin) {
      setState(() {
        _status = 'Solo el admin puede crear centros.';
      });
      return;
    }

    final nombre = _centroNombreController.text.trim();
    final tipo = _centroTipoController.text.trim();
    final direccion = _centroDireccionController.text.trim();
    final comuna = _centroComunaController.text.trim();
    final region = _centroRegionController.text.trim();
    final horarios = _parseHorarios(_centroHorariosController.text);

    if (nombre.isEmpty ||
        tipo.isEmpty ||
        direccion.isEmpty ||
        comuna.isEmpty ||
        region.isEmpty ||
        horarios.isEmpty) {
      setState(() {
        _status = 'Completa todos los datos del centro y sus horarios.';
      });
      return;
    }

    final centro = CentroVacunacion(
      id: _nextCentroId++,
      nombre: nombre,
      tipo: tipo,
      direccion: direccion,
      comuna: comuna,
      region: region,
      horariosBase: horarios,
    );

    setState(() {
      _centros.add(centro);
      _linkCentroController.text = centro.id.toString();
      _status = 'Centro "$nombre" creado correctamente.';
    });
  }

  Future<void> _vincularCentroACampana() async {
    final session = _authService.requireSession();
    if (session.user.role != AppRole.admin) {
      setState(() {
        _status = 'Solo el admin puede vincular centros con campañas.';
      });
      return;
    }

    final campana = _campanaPorId(_selectedLinkCampanaId ?? -1);
    final centro = _centroPorId(_selectedLinkCentroId ?? -1);
    if (campana == null || centro == null) {
      setState(() {
        _status = 'Selecciona una campaña y un centro válidos.';
      });
      return;
    }

    campana.agregarCentroVacunacion(centro);
    setState(() {
      _status =
          'Centro ${centro.nombre} vinculado a la campaña ${campana.nombre}.';
    });
  }

  Future<void> _registrarPaciente() async {
    final session = _authService.requireSession();
    if (session.user.role != AppRole.admin) {
      setState(() {
        _status = 'Solo el admin puede registrar pacientes.';
      });
      return;
    }

    final fullName =
        '${_pacienteNombresController.text.trim()} ${_pacienteApellidosController.text.trim()}'
            .trim();
    final email = _pacienteCorreoController.text.trim();
    final password = _registroPacientePasswordController.text;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _status = 'Completa nombre, correo y contraseña del paciente.';
      });
      return;
    }

    try {
      _authService.registerPatient(
        email: email,
        password: password,
        fullName: fullName,
      );
      final persona = _crearPersonaPaciente();
      _pacientesRegistrados[email.toLowerCase()] = persona;
      setState(() {
        _status = 'Paciente $fullName registrado correctamente.';
      });
    } catch (error) {
      setState(() {
        _status =
            'No se pudo registrar el paciente. Revisa los datos ingresados.';
      });
    }
  }

  Future<void> _reservarHorario(CentroVacunacion centro, String horario, {String? fecha}) async {
    try {
      _authService.requireSession();
      final persona = _crearPersonaPaciente();
      final campana = centro.campanas.isNotEmpty
          ? centro.campanas.first
          : (_campanas.isNotEmpty ? _campanas.first : null);

      final cita = centro.reservarHorario(
        id: _nextCitaId++,
        horario: horario,
        rut: persona.rut,
        nombre: '${persona.nombres} ${persona.apellidos}',
        correo: persona.correo,
        fecha: fecha,
        campana: campana,
      );
      persona.agregarCita(cita);
      _personasPorCita[cita.id] = persona;

      await _notificationService.sendReservationConfirmation(
        from: 'Gestor Vacunas <onboarding@resend.dev>',
        to: persona.correo,
        persona: persona,
        cita: cita,
      );

      setState(() {
        _status =
            'Reserva creada para ${persona.nombres} ${persona.apellidos} en ${centro.nombre}${fecha != null ? ' el $fecha' : ''}.';
      });
    } catch (error) {
      setState(() {
        _status = 'No se pudo reservar el horario.';
      });
    }
  }

  Future<String?> _pedirNuevoHorario(String horarioActual) async {
    TimeOfDay initialTime = TimeOfDay.now();
    try {
      final parts = horarioActual.split(':');
      if (parts.length == 2) {
        initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (_) {}

    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Seleccionar nuevo horario para reagendar',
    );

    if (newTime != null) {
      final hh = newTime.hour.toString().padLeft(2, '0');
      final mm = newTime.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
    return null;
  }

  Future<void> _reagendarCita(CentroVacunacion centro, Cita cita) async {
    final session = _authService.requireSession();
    final esPaciente = session.user.role == AppRole.paciente;
    final esPropia = cita.pacienteCorreo == session.user.email;

    if (!session.user.canCreateAppointments && !(esPaciente && esPropia)) {
      setState(() {
        _status = 'No tienes permiso para reagendar esta cita.';
      });
      return;
    }

    final nuevoHorario = await _pedirNuevoHorario(cita.fechaHora);
    if (nuevoHorario == null || nuevoHorario.isEmpty) {
      return;
    }

    try {
      final nuevaCita = centro.reagendarCita(
        cita: cita,
        nuevaId: _nextCitaId++,
        nuevoHorario: nuevoHorario,
        responsable: session.user.fullName,
      );
      final persona = _personasPorCita[cita.id];
      if (persona != null) {
        persona.agregarCita(nuevaCita);
        _personasPorCita[nuevaCita.id] = persona;
        await _notificationService.sendRescheduleNotification(
          from: 'Gestor Vacunas <onboarding@resend.dev>',
          to: persona.correo,
          persona: persona,
          cita: cita,
          nuevoHorario: nuevoHorario,
        );
      }

      setState(() {
        _status =
            'Cita ${cita.id} reagendada. Nueva cita ${nuevaCita.id} creada en $nuevoHorario.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error al reagendar: $e';
      });
    }
  }

  Future<void> _registrarVacunacion(
      Persona paciente, Cita cita, String nombreVacuna, String observaciones) async {
    final session = _authService.requireSession();
    if (!session.user.canRegisterVaccinations) {
      throw Exception('Permisos insuficientes para registrar vacunas.');
    }

    if (cita.campana == null) {
      throw Exception('La cita no tiene campaña asociada.');
    }

    final now = DateTime.now();
    final fechaFormat = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final vacunacion = Vacunacion(
      id: _nextVacunacionId++,
      fechaHora: fechaFormat,
      observaciones: 'Vacuna: $nombreVacuna. $observaciones',
      campana: cita.campana,
      cita: cita,
    );

    setState(() {
      cita.completar(nuevaVacunacion: vacunacion);
      cita.campana!.agregarVacunacion(vacunacion);
      _status = 'Vacuna registrada para ${paciente.nombres} ${paciente.apellidos}.';
    });

    try {
      await _notificationService.sendVaccinationConfirmation(
        from: 'Gestor Vacunas <onboarding@resend.dev>',
        to: paciente.correo,
        persona: paciente,
        cita: cita,
      );
    } catch (e) {
      // Si falla la notificación no deshacemos el registro
      debugPrint('No se pudo enviar la notificación de vacunación: $e');
    }
  }

  Future<void> _cancelarCita(CentroVacunacion centro, Cita cita) async {
    final session = _authService.requireSession();
    final esPaciente = session.user.role == AppRole.paciente;
    final esPropia = cita.pacienteCorreo == session.user.email;

    if (esPaciente && !esPropia) {
      setState(() {
        _status = 'Solo puedes cancelar tus propias citas.';
      });
      return;
    }

    if (cita.estado == CitaEstado.completada ||
        cita.estado == CitaEstado.cancelada) {
      setState(() {
        _status = 'La cita ya no puede cancelarse.';
      });
      return;
    }

    try {
      centro.cancelarCita(cita, responsable: session.user.fullName);
      setState(() {
        _status = 'La cita ${cita.id} fue cancelada en ${centro.nombre}.';
      });
    } catch (error) {
      setState(() {
        _status = 'No se pudo cancelar la cita.';
      });
    }
  }

  List<CentroVacunacion> _filtrarCentros() {
    final filtroCentro = _searchCentroNombreController.text
        .trim()
        .toLowerCase();
    final filtroCampana = _selectedSearchCampanaId == null
        ? ''
        : _campanaPorId(_selectedSearchCampanaId!)?.nombre.toLowerCase() ?? '';

    return _centros.where((centro) {
      final coincideCentro =
          filtroCentro.isEmpty ||
          centro.nombre.toLowerCase().contains(filtroCentro);
      final coincideCampana =
          filtroCampana.isEmpty ||
          (_selectedSearchCampanaId != null
              ? centro.campanas.any(
                  (campana) => campana.id == _selectedSearchCampanaId,
                )
              : centro.campanas.any(
                  (campana) =>
                      campana.nombre.toLowerCase().contains(filtroCampana),
                ));
      return coincideCentro && coincideCampana;
    }).toList();
  }

  Future<void> _completarCita(CentroVacunacion centro, Cita cita) async {
    final session = _authService.requireSession();
    if (!session.user.canRegisterVaccinations) {
      setState(() {
        _status =
            'El rol ${session.user.role.label} no puede registrar vacunaciones.';
      });
      return;
    }

    try {
      final persona = _personasPorCita[cita.id] ?? _crearPersonaPaciente();
      final vacunacion = Vacunacion(
        id: _nextVacunacionId++,
        fechaHora: cita.fechaHora,
        observaciones: 'Vacunacion completada desde la app.',
        campana: cita.campana,
        cita: cita,
      );

      cita.completar(
        nuevaVacunacion: vacunacion,
        responsable: session.user.fullName,
      );
      cita.campana?.agregarVacunacion(vacunacion);

      await _notificationService.sendVaccinationConfirmation(
        from: 'Gestor Vacunas <onboarding@resend.dev>',
        to: persona.correo,
        persona: persona,
        cita: cita,
      );

      setState(() {
        _status =
            'La cita ${cita.id} de ${centro.nombre} quedo marcada como COMPLETADA.';
      });
    } catch (error) {
      setState(() {
        _status = 'No se pudo completar la cita.';
      });
    }
  }

  Future<void> _revisarRecordatorios() async {
    final now = DateTime.now();

    for (final centro in _centros) {
      for (final cita in centro.citas) {
        // Solo para citas reservadas que no han recibido recordatorio
        if (cita.estado == CitaEstado.reservada && !cita.recordatorioEnviado) {
          // Parsear fecha y hora
          DateTime citaDate;
          try {
            // Si no tiene fecha específica, asumimos el mismo día para pruebas
            final datePart = cita.fecha ?? 
                "\${now.year}-\${now.month.toString().padLeft(2, '0')}-\${now.day.toString().padLeft(2, '0')}";
            final timePart = cita.fechaHora.length == 5 ? "\${cita.fechaHora}:00" : cita.fechaHora; // "09:00" -> "09:00:00"
            citaDate = DateTime.parse("\$datePart \$timePart");
          } catch (e) {
            continue; // Ignorar citas con fechas mal formateadas
          }

          final diferenciaHoras = citaDate.difference(now).inHours;

          // Si la cita es en 24 horas o menos y aún está en el futuro
          if (diferenciaHoras >= 0 && diferenciaHoras <= 24) {
            cita.recordatorioEnviado = true; // Marcar para no reenviar
            final persona = _personasPorCita[cita.id];
            
            if (persona != null) {
              await _notificationService.sendReminderNotification(
                from: 'Gestor Vacunas <onboarding@resend.dev>',
                to: persona.correo,
                persona: persona,
                cita: cita,
              );
              // Podríamos actualizar el estado o log si queremos
            }
          }
        }
      }
    }
  }

  Future<void> _enviarRecordatoriosSimulados() async {
    final session = _authService.requireSession();
    if (!session.user.canCreateAppointments &&
        !session.user.canRegisterVaccinations) {
      setState(() {
        _status = 'No tienes permisos para enviar recordatorios.';
      });
      return;
    }

    final pendientes = _citasPendientesParaRecordatorio();
    for (final cita in pendientes) {
      final persona = _personasPorCita[cita.id];
      if (persona == null) {
        continue;
      }

      await _notificationService.sendReminderNotification(
        from: 'Gestor Vacunas <onboarding@resend.dev>',
        to: persona.correo,
        persona: persona,
        cita: cita,
      );
    }

    setState(() {
      _status = pendientes.isEmpty
          ? 'No hay recordatorios pendientes.'
          : 'Se procesaron ${pendientes.length} recordatorios simulados.';
    });
  }

  Color _colorEstado(CitaEstado estado) {
    switch (estado) {
      case CitaEstado.disponible:
        return const Color(0xFF00AAFF);
      case CitaEstado.reservada:
        return const Color(0xFF0088DD);
      case CitaEstado.reagendada:
        return const Color(0xFFF59E0B);
      case CitaEstado.completada:
        return const Color(0xFF16A34A);
      case CitaEstado.cancelada:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _authService.currentSession;
    final esAdmin = session?.user.role == AppRole.admin;
    final puedeGestionarCitas =
        session?.user.canRegisterVaccinations == true ||
        session?.user.canCreateAppointments == true;
    final centrosVisibles = _filtrarCentros();

    // ─── Vista de Petición de Cita ───
    if (_showPeticionCita && session != null) {
      return PeticionCitaPage(
        campanas: _campanas,
        centros: _centros,
        userName: session.user.fullName,
        onConfirmar: (centro, horario, {String? fecha}) =>
            _reservarHorario(centro, horario, fecha: fecha),
        onBack: () => setState(() => _showPeticionCita = false),
      );
    }

    final esVacunador = session?.user.role == AppRole.vacunador;
    final userCentrosIds = session?.user.centrosIds ?? [];
    final centrosAsignados = _centros.where((c) => userCentrosIds.contains(c.id)).toList();
    final centrosParaRegistro = (centrosAsignados.isEmpty && session?.user.role == AppRole.admin) 
        ? _centros 
        : centrosAsignados;

    final userCampanasIds = session?.user.campanasIds ?? [];
    final campanasAsignadas = _campanas.where((c) => userCampanasIds.contains(c.id)).toList();
    final campanasParaRegistro = (campanasAsignadas.isEmpty && session?.user.role == AppRole.admin)
        ? _campanas
        : campanasAsignadas;

    // ─── Vista de Registro de Vacuna ───
    if (session != null && (esVacunador || (_showRegistroVacuna && puedeGestionarCitas))) {
      return RegistroVacunaPage(
        campanasAsignadas: campanasParaRegistro,
        centrosAsignados: centrosParaRegistro,
        personalMedicoNombre: session.user.fullName,
        onSearchRut: _buscarPersonaConsulta,
        onRegistrar: _registrarVacunacion,
        onBack: esVacunador ? null : () => setState(() => _showRegistroVacuna = false),
        onLogout: esVacunador ? _logout : null,
      );
    }

    // ─── Vista de Creación de Campaña ───
    if (_showCreacionCampana && session != null && esAdmin) {
      return CreacionCampanaPage(
        adminName: session.user.fullName,
        todosLosCentros: _centros,
        onCrearCampana: (nuevaCampana, vacunaNombre, admins) {
          setState(() {
            nuevaCampana.id = _nextCampanaId++;
            _campanas.add(nuevaCampana);
            // Optionally link admins if needed in the future
            _showCreacionCampana = false;
            _status = 'Campaña ${nuevaCampana.nombre} creada exitosamente.';
          });
        },
        onLogout: _logout,
      );
    }

    // ─── Vista principal (panel de administración) ───
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sistema de campañas de vacunación',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Ministerio de Salud',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00AAFF),
        foregroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        actions: [
          if (session != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: PopupMenuButton<String>(
                offset: const Offset(0, 48),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0088DD),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getUserInitials(session.user.fullName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Text(
                      '${session.user.fullName} · ${session.user.role.label}',
                    ),
                  ),
                  const PopupMenuDivider(),
                  if (puedeGestionarCitas && !esAdmin)
                    const PopupMenuItem<String>(
                      value: 'registro_vacuna',
                      child: Row(
                        children: [
                          Icon(Icons.vaccines, size: 18, color: Color(0xFF00AAFF)),
                          SizedBox(width: 8),
                          Text('Registrar vacuna'),
                        ],
                      ),
                    ),
                  if (puedeGestionarCitas && !esAdmin) const PopupMenuDivider(),
                  if (esAdmin)
                    const PopupMenuItem<String>(
                      value: 'creacion_campana',
                      child: Row(
                        children: [
                          Icon(Icons.add_box, size: 18, color: Color(0xFF00AAFF)),
                          SizedBox(width: 8),
                          Text('Crear Campaña'),
                        ],
                      ),
                    ),
                  if (esAdmin) const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Cerrar sesion'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'logout') {
                    _logout();
                  } else if (value == 'registro_vacuna') {
                    setState(() => _showRegistroVacuna = true);
                  } else if (value == 'creacion_campana') {
                    setState(() => _showCreacionCampana = true);
                  }
                },
              ),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF003355), Color(0xFF00AAFF), Color(0xFFE8F7FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: Card(
                  elevation: 14,
                  color: Colors.white.withValues(alpha: 0.96),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Sistema de Vacunación',
                                style: Theme.of(context).textTheme.headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_status),
                        const SizedBox(height: 16),
                        if (session == null)
                          _LoginPanel(
                            emailController: _loginEmailController,
                            passwordController: _loginPasswordController,
                            onLogin: _login,
                          )
                        else ...[
                          if (!esAdmin) ...[
                            _PatientProfilePanel(
                              rutController: _pacienteRutController,
                              nombresController: _pacienteNombresController,
                              apellidosController: _pacienteApellidosController,
                              correoController: _pacienteCorreoController,
                              telefonoController: _pacienteTelefonoController,
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (esAdmin)
                            _AdminManagementPanel(
                              centroNombreController: _centroNombreController,
                              centroTipoController: _centroTipoController,
                              centroDireccionController:
                                  _centroDireccionController,
                              centroComunaController: _centroComunaController,
                              centroRegionController: _centroRegionController,
                              centroHorariosController:
                                  _centroHorariosController,
                              linkCampanaController: _linkCampanaController,
                              linkCentroController: _linkCentroController,
                              campanas: _campanas,
                              centros: _centros,
                              selectedCampanaId: _selectedLinkCampanaId,
                              selectedCentroId: _selectedLinkCentroId,
                              onCampanaSelected: (value) {
                                setState(() {
                                  _selectedLinkCampanaId = value;
                                });
                              },
                              onCentroSelected: (value) {
                                setState(() {
                                  _selectedLinkCentroId = value;
                                });
                              },
                              onCrearCentro: _crearCentro,
                              onVincular: _vincularCentroACampana,
                              resendApiKeyController: _resendApiKeyController,
                              onUpdateApiKey: () {
                                _notificationService.dynamicApiKey =
                                    _resendApiKeyController.text.trim();
                                setState(() {
                                  _status = 'API Key de notificaciones actualizada.';
                                });
                              },
                            ),
                          if (esAdmin) ...[
                            const SizedBox(height: 16),
                            _PatientRegistrationPanel(
                              rutController: _pacienteRutController,
                              nombresController: _pacienteNombresController,
                              apellidosController: _pacienteApellidosController,
                              correoController: _pacienteCorreoController,
                              telefonoController: _pacienteTelefonoController,
                              passwordController:
                                  _registroPacientePasswordController,
                              onRegistrarPaciente: _registrarPaciente,
                            ),
                          ],
                          const SizedBox(height: 16),
                          _CampaignsPanel(
                            campanas: _campanas,
                            esAdmin: esAdmin,
                            onTerminarCampana: (campana) {
                              setState(() {
                                campana.estado = 'TERMINADA';
                                _status = 'Campaña ${campana.nombre} terminada.';
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _CentersPanel(
                            session: session,
                            centros: _centros,
                            canManageAppointments: session.user.canCreateAppointments,
                            onCompletar: _completarCita,
                            onReagendar: _reagendarCita,
                            onCancelar: _cancelarCita,
                            colorEstado: _colorEstado,
                          ),
                          const SizedBox(height: 24),
                          // ─── Gran botón de acción (Depende del rol) ───
                          SizedBox(
                            width: double.infinity,
                            height: 72,
                            child: FilledButton.icon(
                              onPressed: () {
                                if (esAdmin) {
                                  setState(() => _showCreacionCampana = true);
                                } else if (esVacunador) {
                                  setState(() => _showRegistroVacuna = true);
                                } else {
                                  setState(() => _showPeticionCita = true);
                                }
                              },
                              icon: Icon(
                                esAdmin 
                                    ? Icons.add_box 
                                    : (esVacunador ? Icons.vaccines : Icons.calendar_month_rounded), 
                                size: 28,
                              ),
                              label: Text(
                                esAdmin 
                                    ? 'Crear campaña' 
                                    : (esVacunador ? 'Registrar vacuna' : 'Pedir cita')
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: esAdmin 
                                    ? const Color(0xFF10B981) // Green for create
                                    : (esVacunador ? const Color(0xFF374151) : const Color(0xFF00AAFF)),
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getUserInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Inicio de sesion',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo de acceso',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onLogin, child: const Text('Entrar')),
        ],
      ),
    );
  }
}

class _PatientProfilePanel extends StatelessWidget {
  const _PatientProfilePanel({
    required this.rutController,
    required this.nombresController,
    required this.apellidosController,
    required this.correoController,
    required this.telefonoController,
  });

  final TextEditingController rutController;
  final TextEditingController nombresController;
  final TextEditingController apellidosController;
  final TextEditingController correoController;
  final TextEditingController telefonoController;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Datos del paciente para reservas',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: rutController,
                  decoration: const InputDecoration(labelText: 'RUT'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: nombresController,
                  decoration: const InputDecoration(labelText: 'Nombres'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: apellidosController,
                  decoration: const InputDecoration(labelText: 'Apellidos'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: correoController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: telefonoController,
                  decoration: const InputDecoration(labelText: 'Telefono'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminManagementPanel extends StatelessWidget {
  const _AdminManagementPanel({
    required this.centroNombreController,
    required this.centroTipoController,
    required this.centroDireccionController,
    required this.centroComunaController,
    required this.centroRegionController,
    required this.centroHorariosController,
    required this.linkCampanaController,
    required this.linkCentroController,
    required this.campanas,
    required this.centros,
    required this.selectedCampanaId,
    required this.selectedCentroId,
    required this.onCampanaSelected,
    required this.onCentroSelected,
    required this.onCrearCentro,
    required this.onVincular,
    required this.resendApiKeyController,
    required this.onUpdateApiKey,
  });

  final TextEditingController centroNombreController;
  final TextEditingController centroTipoController;
  final TextEditingController centroDireccionController;
  final TextEditingController centroComunaController;
  final TextEditingController centroRegionController;
  final TextEditingController centroHorariosController;
  final TextEditingController linkCampanaController;
  final TextEditingController linkCentroController;
  final List<Campana> campanas;
  final List<CentroVacunacion> centros;
  final int? selectedCampanaId;
  final int? selectedCentroId;
  final ValueChanged<int?> onCampanaSelected;
  final ValueChanged<int?> onCentroSelected;
  final VoidCallback onCrearCentro;
  final VoidCallback onVincular;
  final TextEditingController resendApiKeyController;
  final VoidCallback onUpdateApiKey;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Administracion',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Configuración API de Notificaciones (Resend)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: resendApiKeyController,
                  decoration: const InputDecoration(labelText: 'Ingresa tu API Key (re_...)'),
                  obscureText: true,
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonal(
                onPressed: onUpdateApiKey,
                child: const Text('Actualizar'),
              ),
            ],
          ),
          const Divider(height: 32),
          Text('Crear centro', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: centroNombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: centroTipoController,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: centroDireccionController,
                  decoration: const InputDecoration(labelText: 'Direccion'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: centroComunaController,
                  decoration: const InputDecoration(labelText: 'Comuna'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: centroRegionController,
                  decoration: const InputDecoration(labelText: 'Region'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: centroHorariosController,
                  decoration: const InputDecoration(
                    labelText: 'Horarios disponibles separados por coma',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonal(
                onPressed: onCrearCentro,
                child: const Text('Crear centro'),
              ),
            ],
          ),
          const Divider(height: 32),
          Text(
            'Vincular centro con campaña',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  initialValue: selectedCampanaId,
                  decoration: const InputDecoration(
                    labelText: 'Campaña disponible',
                  ),
                  items: campanas
                      .map(
                        (campana) => DropdownMenuItem<int?>(
                          value: campana.id,
                          child: Text('${campana.id} - ${campana.nombre}'),
                        ),
                      )
                      .toList(),
                  onChanged: onCampanaSelected,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  initialValue: selectedCentroId,
                  decoration: const InputDecoration(
                    labelText: 'Centro disponible',
                  ),
                  items: centros
                      .map(
                        (centro) => DropdownMenuItem<int?>(
                          value: centro.id,
                          child: Text('${centro.id} - ${centro.nombre}'),
                        ),
                      )
                      .toList(),
                  onChanged: onCentroSelected,
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: onVincular,
                child: const Text('Vincular'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Campañas creadas: ${campanas.length} | Centros creados: ${centros.length}',
          ),
        ],
      ),
    );
  }
}

class _CampaignsPanel extends StatelessWidget {
  const _CampaignsPanel({required this.campanas, required this.onTerminarCampana, required this.esAdmin});

  final List<Campana> campanas;
  final ValueChanged<Campana> onTerminarCampana;
  final bool esAdmin;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Campañas activas',
      child: campanas.isEmpty
          ? const Text('No hay campañas registradas.')
          : Wrap(
              spacing: 12,
              runSpacing: 12,
              children: campanas
                  .map(
                    (campana) => Chip(
                      label: Text(
                        '#${campana.id} ${campana.nombre} | Centros: ${campana.centros.length} | Estado: ${campana.estado}',
                      ),
                      backgroundColor: campana.estado == 'TERMINADA' ? Colors.grey[300] : null,
                      onDeleted: (!esAdmin || campana.estado == 'TERMINADA')
                          ? null 
                          : () => onTerminarCampana(campana),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _CentersPanel extends StatelessWidget {
  const _CentersPanel({
    required this.session,
    required this.centros,
    required this.canManageAppointments,
    required this.onCompletar,
    required this.onReagendar,
    required this.onCancelar,
    required this.colorEstado,
  });

  final Session? session;
  final List<CentroVacunacion> centros;
  final bool canManageAppointments;
  final Future<void> Function(CentroVacunacion centro, Cita cita) onCompletar;
  final Future<void> Function(CentroVacunacion centro, Cita cita) onReagendar;
  final Future<void> Function(CentroVacunacion centro, Cita cita) onCancelar;
  final Color Function(CitaEstado estado) colorEstado;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Centros de vacunacion y citas',
      child: Column(
        children: centros
            .map(
              (centro) => _CenterCard(
                session: session,
                centro: centro,
                canManageAppointments: canManageAppointments,
                onCompletar: onCompletar,
                onReagendar: onReagendar,
                onCancelar: onCancelar,
                colorEstado: colorEstado,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CenterCard extends StatelessWidget {
  const _CenterCard({
    required this.session,
    required this.centro,
    required this.canManageAppointments,
    required this.onCompletar,
    required this.onReagendar,
    required this.onCancelar,
    required this.colorEstado,
  });

  final Session? session;
  final CentroVacunacion centro;
  final bool canManageAppointments;
  final Future<void> Function(CentroVacunacion centro, Cita cita) onCompletar;
  final Future<void> Function(CentroVacunacion centro, Cita cita) onReagendar;
  final Future<void> Function(CentroVacunacion centro, Cita cita) onCancelar;
  final Color Function(CitaEstado estado) colorEstado;

  String _nombreVisible(Cita cita) {
    final esPaciente = session?.user.role == AppRole.paciente;
    final esPropia =
        cita.pacienteCorreo != null &&
        cita.pacienteCorreo == session?.user.email;

    if (!esPaciente || esPropia) {
      return cita.pacienteNombre ?? 'Sin asignar';
    }

    return 'Paciente reservado';
  }

  bool _puedeCancelar(Cita cita) {
    final esPaciente = session?.user.role == AppRole.paciente;
    final esPropia =
        cita.pacienteCorreo != null &&
        cita.pacienteCorreo == session?.user.email;
    return esPaciente == true &&
        esPropia &&
        cita.estado != CitaEstado.completada &&
        cita.estado != CitaEstado.cancelada;
  }

  bool _puedeReagendar(Cita cita) {
    if (cita.estado == CitaEstado.completada || cita.estado == CitaEstado.cancelada) {
      return false;
    }
    return canManageAppointments || _puedeCancelar(cita);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD0E8FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      centro.nombre,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${centro.tipo} | ${centro.direccion}, ${centro.comuna} - ${centro.region}',
                    ),
                  ],
                ),
              ),
              Text(
                'Reservadas: ${centro.citasReservadas.length} | Completadas: ${centro.citasCompletadas.length} | Canceladas: ${centro.citasCanceladas.length}',
                textAlign: TextAlign.right,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: centro.campanas.isEmpty
                ? [const Chip(label: Text('Sin campaña vinculada'))]
                : centro.campanas
                      .map(
                        (campana) => Chip(
                          label: Text(
                            'Campana #${campana.id}: ${campana.nombre}',
                          ),
                        ),
                      )
                      .toList(),
          ),
          const Divider(height: 28),
          Text(
            'Citas del centro',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (centro.citas.isEmpty)
            const Text('Todavia no hay citas asociadas a este centro.')
          else
            ...centro.citas.map(
              (cita) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorEstado(cita.estado).withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colorEstado(cita.estado),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cita #${cita.id} - ${cita.fecha != null ? '${cita.fecha} ' : ''}${cita.fechaHora}'),
                          const SizedBox(height: 4),
                          Text(
                            'Estado: ${cita.estado.label} | Paciente: ${_nombreVisible(cita)}',
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (canManageAppointments &&
                            cita.estado != CitaEstado.completada &&
                            cita.estado != CitaEstado.cancelada)
                          FilledButton.tonal(
                            onPressed: () => onCompletar(centro, cita),
                            child: const Text('Completar'),
                          ),
                        if (_puedeReagendar(cita))
                          OutlinedButton(
                            onPressed: () => onReagendar(centro, cita),
                            child: const Text('Reagendar'),
                          ),
                        if (_puedeCancelar(cita))
                          FilledButton.tonal(
                            onPressed: () => onCancelar(centro, cita),
                            child: const Text('Cancelar'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CentersSearchPanel extends StatelessWidget {
  const _CentersSearchPanel({
    required this.centroNombreController,
    required this.campanas,
    required this.selectedCampanaId,
    required this.onCampanaChanged,
    required this.onChanged,
  });

  final TextEditingController centroNombreController;
  final List<Campana> campanas;
  final int? selectedCampanaId;
  final ValueChanged<int?> onCampanaChanged;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Buscar centros',
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: centroNombreController,
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre de centro',
              ),
              onChanged: (_) => onChanged(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<int?>(
              initialValue: selectedCampanaId,
              decoration: const InputDecoration(
                labelText: 'Buscar por campaña',
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Todas las campañas'),
                ),
                ...campanas.map(
                  (campana) => DropdownMenuItem<int?>(
                    value: campana.id,
                    child: Text(campana.nombre),
                  ),
                ),
              ],
              onChanged: onCampanaChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientRegistrationPanel extends StatelessWidget {
  const _PatientRegistrationPanel({
    required this.rutController,
    required this.nombresController,
    required this.apellidosController,
    required this.correoController,
    required this.telefonoController,
    required this.passwordController,
    required this.onRegistrarPaciente,
  });

  final TextEditingController rutController;
  final TextEditingController nombresController;
  final TextEditingController apellidosController;
  final TextEditingController correoController;
  final TextEditingController telefonoController;
  final TextEditingController passwordController;
  final VoidCallback onRegistrarPaciente;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Registro de pacientes',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: rutController,
                  decoration: const InputDecoration(labelText: 'RUT'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: nombresController,
                  decoration: const InputDecoration(labelText: 'Nombres'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: apellidosController,
                  decoration: const InputDecoration(labelText: 'Apellidos'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: correoController,
                  decoration: const InputDecoration(
                    labelText: 'Correo del paciente',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: telefonoController,
                  decoration: const InputDecoration(labelText: 'Telefono'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: onRegistrarPaciente,
              child: const Text('Registrar paciente'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD0E8FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
