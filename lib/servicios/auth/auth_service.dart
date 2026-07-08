import 'package:bcrypt/bcrypt.dart';

import '../seguridad/jwt_service.dart';
import '../seguridad/security_controller.dart';

/// Roles del sistema. [claim] es el valor exacto que va dentro del JWT
/// (coincide con los nombres usados en el Esquema de Seguridad:
/// paciente, vacunador, coordinador, admin). "operador" del código original
/// se mapea a "coordinador" del Esquema.
enum AppRole {
  admin('Admin', 'admin'),
  operador('Operador', 'coordinador'),
  vacunador('Vacunador', 'vacunador'),
  paciente('Paciente', 'paciente');

  const AppRole(this.label, this.claim);

  final String label;
  final String claim;

  static AppRole desdeClaim(String claim) {
    return AppRole.values.firstWhere(
      (r) => r.claim == claim,
      orElse: () => throw StateError('Rol desconocido: $claim'),
    );
  }
}

class AppUser {
  AppUser({
    required this.rut,
    required this.email,
    required String passwordHash,
    required this.fullName,
    required this.role,
    this.centroAsignadoId,
  }) : _passwordHash = passwordHash;

  final String rut;
  final String email;
  final String _passwordHash;
  final String fullName;
  final AppRole role;

  /// Solo aplica a vacunador/coordinador — usado por el control fino por
  /// centro (punto 6 del Esquema).
  final int? centroAsignadoId;

  bool verificarPassword(String plano) => BCrypt.checkpw(plano, _passwordHash);

  bool get canCreateAppointments =>
      role == AppRole.admin || role == AppRole.operador;

  bool get canRegisterVaccinations =>
      role == AppRole.admin || role == AppRole.vacunador;
}

class Session {
  const Session({required this.user, required this.token});

  final AppUser user;
  final String token;

  /// La validez real la determina el claim exp del JWT, no un campo local.
  bool get isExpired {
    try {
      SecurityController.validarToken(token);
      return false;
    } on AccesoDenegadoException {
      return true;
    }
  }

  TokenPayload get payload => SecurityController.validarToken(token);
}

class AuthService {
  AuthService() : _users = [] {
    // Datos demo. En un backend real, esto se reemplaza por la consulta al
    // Sistema Gubernamental (identidad) + tabla de roles interna (punto 1
    // del Esquema de Seguridad).
    _users.addAll([
      AppUser(
        rut: '11.111.111-1',
        email: 'admin@demo.cl',
        passwordHash: BCrypt.hashpw('123456', BCrypt.gensalt()),
        fullName: 'Administrador Sistema',
        role: AppRole.admin,
      ),
      AppUser(
        rut: '22.222.222-2',
        email: 'operador@demo.cl',
        passwordHash: BCrypt.hashpw('123456', BCrypt.gensalt()),
        fullName: 'Operador Central',
        role: AppRole.operador,
        centroAsignadoId: 1,
      ),
      AppUser(
        rut: '33.333.333-3',
        email: 'vacunador@demo.cl',
        passwordHash: BCrypt.hashpw('123456', BCrypt.gensalt()),
        fullName: 'Vacunador Equipo',
        role: AppRole.vacunador,
        centroAsignadoId: 1,
      ),
      AppUser(
        rut: '21.343.419-5',
        email: 'paciente@demo.cl',
        passwordHash: BCrypt.hashpw('123456', BCrypt.gensalt()),
        fullName: 'Paciente Demo',
        role: AppRole.paciente,
      ),
    ]);
  }

  final List<AppUser> _users;
  Session? _currentSession;

  // Rate limiting simple en memoria — protección básica anti fuerza bruta,
  // no estaba en el Esquema original pero es una recomendación de mínima
  // seguridad para el login.
  final Map<String, List<DateTime>> _intentosFallidos = {};
  static const int _maxIntentos = 5;
  static const Duration _ventanaBloqueo = Duration(minutes: 5);

  Session? get currentSession {
    final session = _currentSession;
    if (session == null) return null;
    if (session.isExpired) {
      _currentSession = null;
      return null;
    }
    return session;
  }

  bool _bloqueadoPorIntentos(String email) {
    final intentos = _intentosFallidos[email];
    if (intentos == null) return false;
    intentos.removeWhere((t) => DateTime.now().difference(t) > _ventanaBloqueo);
    return intentos.length >= _maxIntentos;
  }

  void _registrarIntentoFallido(String email) {
    _intentosFallidos.putIfAbsent(email, () => []).add(DateTime.now());
  }

  Session login({required String email, required String password}) {
    final emailNorm = email.trim().toLowerCase();

    if (_bloqueadoPorIntentos(emailNorm)) {
      throw StateError(
        'Demasiados intentos fallidos. Intenta nuevamente en unos minutos.',
      );
    }

    AppUser? user;
    for (final candidato in _users) {
      if (candidato.email.toLowerCase() == emailNorm) {
        user = candidato;
        break;
      }
    }

    if (user == null || !user.verificarPassword(password)) {
      _registrarIntentoFallido(emailNorm);
      throw StateError('Credenciales inválidas.');
    }

    _intentosFallidos.remove(emailNorm);

    final token = JwtService.generar(
      rut: user.rut,
      rol: user.role.claim,
      nombre: user.fullName,
    );

    _currentSession = Session(user: user, token: token);
    return _currentSession!;
  }

  AppUser registerPatient({
    required String email,
    required String password,
    required String fullName,
    String rut = '',
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    if (_users.any((u) => u.email.toLowerCase() == normalizedEmail)) {
      throw StateError('Ya existe un usuario con ese correo.');
    }

    final patient = AppUser(
      rut: rut,
      email: normalizedEmail,
      passwordHash: BCrypt.hashpw(password, BCrypt.gensalt()),
      fullName: fullName.trim(),
      role: AppRole.paciente,
    );
    _users.add(patient);
    return patient;
  }

  List<AppUser> get patients =>
      _users.where((u) => u.role == AppRole.paciente).toList();

  Session requireSession() {
    final session = currentSession;
    if (session == null) {
      throw StateError('No hay una sesión activa.');
    }
    return session;
  }

  void logout() {
    _currentSession = null;
  }
}
