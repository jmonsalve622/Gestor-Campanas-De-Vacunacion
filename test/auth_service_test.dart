import 'package:flutter_test/flutter_test.dart';

import 'package:gestor_aplicacion/servicios/auth/auth_service.dart';
import 'package:gestor_aplicacion/servicios/seguridad/security_controller.dart';

void main() {
  group('AuthService - login', () {
    test('login exitoso con credenciales correctas', () {
      final auth = AuthService();
      final session = auth.login(email: 'admin@demo.cl', password: '123456');

      expect(session.user.role, AppRole.admin);
      expect(session.token, isNotEmpty);
      expect(session.isExpired, isFalse);
    });

    test('login falla con password incorrecta', () {
      final auth = AuthService();

      expect(
        () => auth.login(email: 'admin@demo.cl', password: 'password-mala'),
        throwsA(isA<StateError>()),
      );
    });

    test('login falla con correo inexistente', () {
      final auth = AuthService();

      expect(
        () => auth.login(email: 'no-existe@demo.cl', password: '123456'),
        throwsA(isA<StateError>()),
      );
    });

    test('bloquea tras 5 intentos fallidos seguidos', () {
      final auth = AuthService();

      for (var i = 0; i < 5; i++) {
        expect(
          () => auth.login(email: 'admin@demo.cl', password: 'mala'),
          throwsA(isA<StateError>()),
        );
      }

      expect(
        () => auth.login(email: 'admin@demo.cl', password: '123456'),
        throwsA(
          predicate(
            (e) => e is StateError && e.message.contains('Demasiados intentos'),
          ),
        ),
      );
    });

    test('el token contiene el rol correcto como claim', () {
      final auth = AuthService();
      final session = auth.login(
        email: 'vacunador@demo.cl',
        password: '123456',
      );

      final payload = SecurityController.validarToken(session.token);
      expect(payload.rol, 'vacunador');
      expect(payload.rut, '33.333.333-3');
    });
  });

  group('AuthService - sesión', () {
    test('requireSession lanza error si no hay sesión activa', () {
      final auth = AuthService();
      expect(() => auth.requireSession(), throwsA(isA<StateError>()));
    });

    test('logout limpia la sesión actual', () {
      final auth = AuthService();
      auth.login(email: 'admin@demo.cl', password: '123456');
      expect(auth.currentSession, isNotNull);

      auth.logout();
      expect(auth.currentSession, isNull);
    });
  });

  group('AuthService - registro de pacientes', () {
    test('registra un paciente nuevo correctamente', () {
      final auth = AuthService();
      final paciente = auth.registerPatient(
        email: 'nuevo@demo.cl',
        password: 'clave123',
        fullName: 'Nuevo Paciente',
        rut: '15.111.222-3',
      );

      expect(paciente.role, AppRole.paciente);
      final session = auth.login(email: 'nuevo@demo.cl', password: 'clave123');
      expect(session.user.email, 'nuevo@demo.cl');
      expect(session.user.rut, '15.111.222-3');
    });

    test('no permite registrar un correo ya existente', () {
      final auth = AuthService();
      expect(
        () => auth.registerPatient(
          email: 'admin@demo.cl',
          password: 'x',
          fullName: 'Duplicado',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('SecurityController - RBAC', () {
    late String tokenPaciente;
    late String tokenAdmin;
    late String tokenVacunador;

    setUp(() {
      final auth = AuthService();
      tokenPaciente = auth
          .login(email: 'paciente@demo.cl', password: '123456')
          .token;
      tokenAdmin = auth.login(email: 'admin@demo.cl', password: '123456').token;
      tokenVacunador = auth
          .login(email: 'vacunador@demo.cl', password: '123456')
          .token;
    });

    test('verificarRol permite si el rol está en la lista', () {
      final payload = SecurityController.validarToken(tokenAdmin);
      expect(
        () => SecurityController.verificarRol(payload, ['admin']),
        returnsNormally,
      );
    });

    test('verificarRol lanza 403 si el rol no está permitido', () {
      final payload = SecurityController.validarToken(tokenPaciente);
      expect(
        () => SecurityController.verificarRol(payload, ['admin']),
        throwsA(
          isA<AccesoDenegadoException>().having((e) => e.codigo, 'codigo', 403),
        ),
      );
    });

    test('verificarPropiedadPaciente bloquea acceso a RUT ajeno', () {
      final payload = SecurityController.validarToken(tokenPaciente);
      expect(
        () => SecurityController.verificarPropiedadPaciente(
          payload,
          '99.999.999-9',
        ),
        throwsA(isA<AccesoDenegadoException>()),
      );
    });

    test('verificarPropiedadPaciente permite acceso a su propio RUT', () {
      final payload = SecurityController.validarToken(tokenPaciente);
      expect(
        () =>
            SecurityController.verificarPropiedadPaciente(payload, payload.rut),
        returnsNormally,
      );
    });

    test('validarToken lanza 401 con un token corrupto', () {
      expect(
        () => SecurityController.validarToken('esto-no-es-un-jwt-valido'),
        throwsA(
          isA<AccesoDenegadoException>().having((e) => e.codigo, 'codigo', 401),
        ),
      );
    });

    // --- Nuevos: control fino por centro (vacunador/coordinador) ---

    test('vacunador puede operar sobre su propio centro (id 1)', () {
      final payload = SecurityController.validarToken(tokenVacunador);
      expect(
        () => SecurityController.verificarPropiedadCentro(
          payload,
          centroIdRecurso: 1,
          centroIdAsignado: 1, // el vacunador demo tiene centroAsignadoId: 1
        ),
        returnsNormally,
      );
    });

    test('vacunador NO puede operar sobre un centro distinto (id 2)', () {
      final payload = SecurityController.validarToken(tokenVacunador);
      expect(
        () => SecurityController.verificarPropiedadCentro(
          payload,
          centroIdRecurso: 2,
          centroIdAsignado: 1,
        ),
        throwsA(isA<AccesoDenegadoException>()),
      );
    });

    test('admin no está restringido por centro (bypass)', () {
      final payload = SecurityController.validarToken(tokenAdmin);
      expect(
        () => SecurityController.verificarPropiedadCentro(
          payload,
          centroIdRecurso: 2,
          centroIdAsignado: null, // el admin no tiene centro asignado
        ),
        returnsNormally,
      );
    });

    test('paciente no está sujeto al control de centro', () {
      final payload = SecurityController.validarToken(tokenPaciente);
      expect(
        () => SecurityController.verificarPropiedadCentro(
          payload,
          centroIdRecurso: 2,
          centroIdAsignado: null,
        ),
        returnsNormally, // la regla solo aplica a vacunador/coordinador
      );
    });
  });
}
