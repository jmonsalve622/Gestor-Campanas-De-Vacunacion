enum AppRole {
  admin('Admin'),
  operador('Operador'),
  vacunador('Vacunador'),
  paciente('Paciente');

  const AppRole(this.label);

  final String label;
}

class AppUser {
  AppUser({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
    this.rut,
    this.centrosIds = const [],
    this.campanasIds = const [],
  });

  final String email;
  final String password;
  final String fullName;
  final String? rut;
  final AppRole role;
  List<int> centrosIds;
  List<int> campanasIds;

  bool get canCreateAppointments =>
      role == AppRole.admin;
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
          rut: '11.111.111-1',
          role: AppRole.admin,
          centrosIds: [1, 2],
          campanasIds: [1, 2],
        ),
        AppUser(
          email: 'operador@demo.cl',
          password: '123456',
          fullName: 'Operador Central',
          rut: '22.222.222-2',
          role: AppRole.operador,
          centrosIds: [1],
          campanasIds: [1],
        ),
        AppUser(
          email: 'vacunador@demo.cl',
          password: '123456',
          fullName: 'Vacunador Equipo',
          rut: '33.333.333-3',
          role: AppRole.vacunador,
          centrosIds: [1],
          campanasIds: [1],
        ),
        AppUser(
          email: 'vacunador2@demo.cl',
          password: '123456',
          fullName: 'Vacunador Sur',
          rut: '44.444.444-4',
          role: AppRole.vacunador,
          centrosIds: [2],
          campanasIds: [2],
        ),
        AppUser(
          email: 'paciente@demo.cl',
          password: '123456',
          fullName: 'Paciente Demo',
          rut: '55.555.555-5',
          role: AppRole.paciente,
        ),
        AppUser(
          email: 'alfonsogg111@gmail.com',
          password: '123456',
          fullName: 'Alfonso Gonzalez',
          rut: '66.666.666-6',
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

  AppUser registerVaccinator({
    required String email,
    required String password,
    required String fullName,
    required String rut,
    List<int> centrosIds = const [],
    required List<int> campanasIds,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    if (_users.any((user) => user.email.toLowerCase() == normalizedEmail)) {
      throw StateError('Ya existe un usuario con ese correo.');
    }

    final vaccinator = AppUser(
      email: normalizedEmail,
      password: password,
      fullName: fullName,
      rut: rut,
      role: AppRole.vacunador,
      centrosIds: centrosIds,
      campanasIds: campanasIds,
    );
    _users.add(vaccinator);
    return vaccinator;
  }

  AppUser registerOperator({
    required String email,
    required String password,
    required String fullName,
    required String rut,
    List<int> centrosIds = const [],
    List<int> campanasIds = const [],
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    if (_users.any((u) => u.email == normalizedEmail)) {
      throw StateError('El correo ya esta en uso.');
    }
    
    final operator = AppUser(
      email: normalizedEmail,
      password: password,
      fullName: fullName,
      rut: rut,
      role: AppRole.operador,
      centrosIds: centrosIds,
      campanasIds: campanasIds,
    );
    _users.add(operator);
    return operator;
  }

  void assignVaccinatorToCenter(AppUser vaccinator, int centroId, int campanaId) {
    if (!vaccinator.centrosIds.contains(centroId)) {
      vaccinator.centrosIds = List.from(vaccinator.centrosIds)..add(centroId);
    }
    if (!vaccinator.campanasIds.contains(campanaId)) {
      vaccinator.campanasIds = List.from(vaccinator.campanasIds)..add(campanaId);
    }
  }

  void assignOperatorToCenter(AppUser operator, int centroId, int campanaId) {
    if (!operator.centrosIds.contains(centroId)) {
      operator.centrosIds = List.from(operator.centrosIds)..add(centroId);
    }
    if (!operator.campanasIds.contains(campanaId)) {
      operator.campanasIds = List.from(operator.campanasIds)..add(campanaId);
    }
  }

  List<AppUser> get vaccinators =>
      _users.where((user) => user.role == AppRole.vacunador).toList();

  List<AppUser> get patients =>
      _users.where((user) => user.role == AppRole.paciente).toList();

  List<AppUser> get operators =>
      _users.where((user) => user.role == AppRole.operador).toList();

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
