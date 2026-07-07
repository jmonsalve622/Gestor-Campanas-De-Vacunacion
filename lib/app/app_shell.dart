import 'package:flutter/material.dart';

import '../modelos/Persona.dart';
import '../modelos/campana.dart';
import '../modelos/cita.dart';
import '../modelos/centro_vacunacion.dart';
import '../modelos/vacunacion.dart';
import '../servicios/auth/auth_service.dart';
import '../servicios/notificaciones/notification_service.dart';
import '../servicios/notificaciones/resend_notification_service.dart';

class GestorCampanasApp extends StatelessWidget {
  const GestorCampanasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestor de Campanas de Vacunacion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        useMaterial3: true,
      ),
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
  final NotificationService _notificationService = ResendNotificationService();

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

  int? _selectedLinkCampanaId;
  int? _selectedLinkCentroId;
  int? _selectedSearchCampanaId;

  int _nextCampanaId = 3;
  int _nextCentroId = 3;
  int _nextCitaId = 10;
  int _nextVacunacionId = 1;
  String _status = 'Listo para administrar campañas, centros y citas.';

  @override
  void initState() {
    super.initState();
    _seedDemoData();
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
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
    final campana = Campana(
      id: 1,
      nombre: 'Campana Invierno 2026',
      descripcion:
          'Cobertura preventiva para adultos mayores y pacientes cronicos.',
      fechaInicio: '2026-06-01',
      fechaFin: '2026-08-31',
    );

    final centro1 = CentroVacunacion(
      id: 1,
      nombre: 'CESFAM Central',
      tipo: 'Publico',
      direccion: 'Av. Principal 123',
      comuna: 'Santiago',
      region: 'Metropolitana',
      horariosBase: const [
        '09:00',
        '09:30',
        '10:00',
        '10:30',
        '11:00',
        '11:30',
      ],
    );

    final centro2 = CentroVacunacion(
      id: 2,
      nombre: 'Posta Norte',
      tipo: 'Publico',
      direccion: 'Calle Norte 456',
      comuna: 'Recoleta',
      region: 'Metropolitana',
      horariosBase: const ['08:00', '08:30', '09:00', '09:30', '10:00'],
    );

    campana.agregarCentroVacunacion(centro1);
    campana.agregarCentroVacunacion(centro2);

    final pacienteDemo = Persona(
      rut: '21.343.419-5',
      nombres: 'Ana',
      apellidos: 'Perez',
      fechaNacimiento: DateTime(1990, 1, 1),
      correo: 'paciente@demo.cl',
      telefono: '+56912345678',
    );

    final citaReservada = centro1.reservarHorario(
      id: _nextCitaId++,
      horario: '09:00',
      rut: pacienteDemo.rut,
      nombre: '${pacienteDemo.nombres} ${pacienteDemo.apellidos}',
      correo: pacienteDemo.correo,
      campana: campana,
    );
    pacienteDemo.agregarCita(citaReservada);
    _personasPorCita[citaReservada.id] = pacienteDemo;

    final citaCompletada = centro1.reservarHorario(
      id: _nextCitaId++,
      horario: '09:30',
      rut: pacienteDemo.rut,
      nombre: '${pacienteDemo.nombres} ${pacienteDemo.apellidos}',
      correo: pacienteDemo.correo,
      campana: campana,
    );
    final vacunacion = Vacunacion(
      id: _nextVacunacionId++,
      fechaHora: citaCompletada.fechaHora,
      observaciones: 'Vacuna administrada en demo.',
      campana: campana,
      cita: citaCompletada,
    );
    citaCompletada.completar(nuevaVacunacion: vacunacion);
    campana.agregarVacunacion(vacunacion);
    pacienteDemo.agregarCita(citaCompletada);
    _personasPorCita[citaCompletada.id] = pacienteDemo;

    _campanas.add(campana);
    _centros.addAll([centro1, centro2]);
    _pacientesRegistrados[pacienteDemo.correo] = pacienteDemo;
    _linkCampanaController.text = campana.id.toString();
    _linkCentroController.text = centro1.id.toString();
    _selectedLinkCampanaId = campana.id;
    _selectedLinkCentroId = centro1.id;
    _selectedSearchCampanaId = campana.id;
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
    return Persona(
      rut: _pacienteRutController.text.trim(),
      nombres: _pacienteNombresController.text.trim(),
      apellidos: _pacienteApellidosController.text.trim(),
      fechaNacimiento: DateTime(1990, 1, 1),
      correo: _pacienteCorreoController.text.trim(),
      telefono: _pacienteTelefonoController.text.trim(),
    );
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

  Future<void> _reservarHorario(CentroVacunacion centro, String horario) async {
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
            'Reserva creada para ${persona.nombres} ${persona.apellidos} en ${centro.nombre}.';
      });
    } catch (error) {
      setState(() {
        _status = 'No se pudo reservar el horario.';
      });
    }
  }

  Future<String?> _pedirNuevoHorario(String horarioActual) {
    final controller = TextEditingController(text: horarioActual);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reagendar cita'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nuevo horario'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _reagendarCita(CentroVacunacion centro, Cita cita) async {
    final session = _authService.requireSession();
    if (!session.user.canCreateAppointments) {
      setState(() {
        _status = 'El rol ${session.user.role.label} no puede reagendar citas.';
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
    } catch (error) {
      setState(() {
        _status = 'No se pudo reagendar la cita. Revisa la disponibilidad.';
      });
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
        return const Color(0xFF0F766E);
      case CitaEstado.reservada:
        return const Color(0xFF2563EB);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Vacunacion'),
        centerTitle: false,
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        actions: [
          if (session != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: PopupMenuButton<String>(
                offset: const Offset(0, 48),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6FFFA),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFF99F6E4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_circle_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(session.user.fullName),
                    ],
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
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: const Text('Cerrar sesion'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'logout') {
                    _logout();
                  }
                },
              ),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF042F2E), Color(0xFF0F766E), Color(0xFFECFEFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
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
                        Text(
                          'Sistema de Vacunacion',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
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
                          _PatientProfilePanel(
                            rutController: _pacienteRutController,
                            nombresController: _pacienteNombresController,
                            apellidosController: _pacienteApellidosController,
                            correoController: _pacienteCorreoController,
                            telefonoController: _pacienteTelefonoController,
                          ),
                          const SizedBox(height: 16),
                          if (esAdmin)
                            _AdminManagementPanel(
                              campanaNombreController: _campanaNombreController,
                              campanaDescripcionController:
                                  _campanaDescripcionController,
                              campanaInicioController: _campanaInicioController,
                              campanaFinController: _campanaFinController,
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
                              onCrearCampana: _crearCampana,
                              onCrearCentro: _crearCentro,
                              onVincular: _vincularCentroACampana,
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
                          _CampaignsPanel(campanas: _campanas),
                          const SizedBox(height: 16),
                          _CentersSearchPanel(
                            centroNombreController:
                                _searchCentroNombreController,
                            campanas: _campanas,
                            selectedCampanaId: _selectedSearchCampanaId,
                            onCampanaChanged: (value) {
                              setState(() {
                                _selectedSearchCampanaId = value;
                              });
                            },
                            onChanged: () => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          _CentersPanel(
                            session: session,
                            centros: centrosVisibles,
                            canReserve: true,
                            canManageAppointments: puedeGestionarCitas,
                            onReservar: _reservarHorario,
                            onCompletar: _completarCita,
                            onReagendar: _reagendarCita,
                            onCancelar: _cancelarCita,
                            colorEstado: _colorEstado,
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
    );
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
    required this.campanaNombreController,
    required this.campanaDescripcionController,
    required this.campanaInicioController,
    required this.campanaFinController,
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
    required this.onCrearCampana,
    required this.onCrearCentro,
    required this.onVincular,
  });

  final TextEditingController campanaNombreController;
  final TextEditingController campanaDescripcionController;
  final TextEditingController campanaInicioController;
  final TextEditingController campanaFinController;
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
  final VoidCallback onCrearCampana;
  final VoidCallback onCrearCentro;
  final VoidCallback onVincular;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Administracion',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Crear campaña', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: campanaNombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: campanaDescripcionController,
                  decoration: const InputDecoration(labelText: 'Descripcion'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: campanaInicioController,
                  decoration: const InputDecoration(labelText: 'Fecha inicio'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: campanaFinController,
                  decoration: const InputDecoration(labelText: 'Fecha fin'),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: onCrearCampana,
                child: const Text('Crear campaña'),
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
  const _CampaignsPanel({required this.campanas});

  final List<Campana> campanas;

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
                        '#${campana.id} ${campana.nombre} | Centros: ${campana.centros.length} | Vacunaciones: ${campana.vacunaciones.length}',
                      ),
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
    required this.canReserve,
    required this.canManageAppointments,
    required this.onReservar,
    required this.onCompletar,
    required this.onReagendar,
    required this.onCancelar,
    required this.colorEstado,
  });

  final Session? session;
  final List<CentroVacunacion> centros;
  final bool canReserve;
  final bool canManageAppointments;
  final Future<void> Function(CentroVacunacion centro, String horario)
  onReservar;
  final Future<void> Function(CentroVacunacion centro, Cita cita) onCompletar;
  final Future<void> Function(CentroVacunacion centro, Cita cita) onReagendar;
  final Future<void> Function(CentroVacunacion centro, Cita cita) onCancelar;
  final Color Function(CitaEstado estado) colorEstado;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Centros de vacunacion y horarios',
      child: Column(
        children: centros
            .map(
              (centro) => _CenterCard(
                session: session,
                centro: centro,
                canReserve: canReserve,
                canManageAppointments: canManageAppointments,
                onReservar: onReservar,
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
    required this.canReserve,
    required this.canManageAppointments,
    required this.onReservar,
    required this.onCompletar,
    required this.onReagendar,
    required this.onCancelar,
    required this.colorEstado,
  });

  final Session? session;
  final CentroVacunacion centro;
  final bool canReserve;
  final bool canManageAppointments;
  final Future<void> Function(CentroVacunacion centro, String horario)
  onReservar;
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FFFE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCFCE7)),
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
                'Disponibles: ${centro.horariosDisponibles.length} | Reservadas: ${centro.citasReservadas.length} | Reagendadas: ${centro.citasReagendadas.length} | Completadas: ${centro.citasCompletadas.length} | Canceladas: ${centro.citasCanceladas.length}',
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
          const SizedBox(height: 12),
          Text(
            'Horarios disponibles',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (centro.horariosDisponibles.isEmpty)
            const Text('No hay horarios disponibles en este centro.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: centro.horariosDisponibles
                  .map(
                    (horario) => ActionChip(
                      label: Text(horario),
                      onPressed: canReserve
                          ? () => onReservar(centro, horario)
                          : null,
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
                          Text('Cita #${cita.id} - ${cita.fechaHora}'),
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
                        if (canManageAppointments &&
                            cita.estado != CitaEstado.completada &&
                            cita.estado != CitaEstado.cancelada)
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
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
