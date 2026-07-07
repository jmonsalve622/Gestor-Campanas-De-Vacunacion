enum AppRole {
  admin('Admin'),
  operador('Operador'),
  vacunador('Vacunador'),
  paciente('Paciente');

  const AppRole(this.label);

  final String label;
}

class AppUser {
  const AppUser({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
  });

  final String email;
  final String password;
  final String fullName;
  final AppRole role;

  bool get canCreateAppointments =>
      role == AppRole.admin || role == AppRole.operador;
  bool get canRegisterVaccinations =>
      role == AppRole.admin || role == AppRole.vacunador;
}

class Session {
  const Session({
    required this.user,
    required this.token,
    required this.expiresAt,
  });

  final AppUser user;
  final String token;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class AuthService {
  AuthService()
    : _users = [
        AppUser(
          email: 'admin@demo.cl',
          password: '123456',
          fullName: 'Administrador Sistema',
          role: AppRole.admin,
        ),
        AppUser(
          email: 'operador@demo.cl',
          password: '123456',
          fullName: 'Operador Central',
          role: AppRole.operador,
        ),
        AppUser(
          email: 'vacunador@demo.cl',
          password: '123456',
          fullName: 'Vacunador Equipo',
          role: AppRole.vacunador,
        ),
        AppUser(
          email: 'paciente@demo.cl',
          password: '123456',
          fullName: 'Paciente Demo',
          role: AppRole.paciente,
        ),
      ];

  final List<AppUser> _users;
  Session? _currentSession;

  Session? get currentSession {
    final session = _currentSession;
    if (session == null) {
      return null;
    }
    if (session.isExpired) {
      _currentSession = null;
      return null;
    }
    return session;
  }

  Session login({required String email, required String password}) {
    final user = _users.firstWhere(
      (candidate) =>
          candidate.email.toLowerCase() == email.toLowerCase() &&
          candidate.password == password,
      orElse: () => throw StateError('Credenciales invalidas.'),
    );

    _currentSession = Session(
      user: user,
      token: DateTime.now().microsecondsSinceEpoch.toString(),
      expiresAt: DateTime.now().add(const Duration(hours: 8)),
    );

    return _currentSession!;
  }

  AppUser registerPatient({
    required String email,
    required String password,
    required String fullName,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    if (_users.any((user) => user.email.toLowerCase() == normalizedEmail)) {
      throw StateError('Ya existe un usuario con ese correo.');
    }

    final patient = AppUser(
      email: normalizedEmail,
      password: password,
      fullName: fullName.trim(),
      role: AppRole.paciente,
    );
    _users.add(patient);
    return patient;
  }

  List<AppUser> get patients =>
      _users.where((user) => user.role == AppRole.paciente).toList();

  Session requireSession() {
    final session = currentSession;
    if (session == null) {
      throw StateError('No hay una sesion activa.');
    }
    return session;
  }

  void logout() {
    _currentSession = null;
  }
}
