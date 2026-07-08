import 'jwt_service.dart';

/// Se lanza cuando una validación de seguridad falla.
/// [codigo] sigue la misma convención HTTP del Esquema: 401 = token
/// inválido/expirado, 403 = rol o recurso no autorizado.
class AccesoDenegadoException implements Exception {
  AccesoDenegadoException(this.mensaje, {this.codigo = 403});

  final String mensaje;
  final int codigo;

  @override
  String toString() => 'AccesoDenegadoException($codigo): $mensaje';
}

/// Datos extraídos del JWT ya validado.
class TokenPayload {
  const TokenPayload({
    required this.rut,
    required this.rol,
    required this.nombre,
  });

  final String rut;
  final String rol;
  final String nombre;
}

/// Controlador de Seguridad — centraliza RBAC y control fino por recurso.
/// Corresponde a los puntos 4 y 6 del Esquema de Seguridad. Toda pantalla u
/// operación sensible debe pasar por acá antes de ejecutar su lógica,
/// en vez de reimplementar el chequeo caso a caso.
class SecurityController {
  SecurityController._();

  /// Verifica firma + expiración del token. Lanza 401 si falla.
  static TokenPayload validarToken(String token) {
    try {
      final payload = JwtService.verificar(token);
      return TokenPayload(
        rut: payload['sub'] as String,
        rol: payload['rol'] as String,
        nombre: payload['nombre'] as String,
      );
    } catch (_) {
      throw AccesoDenegadoException('Token inválido o expirado', codigo: 401);
    }
  }

  /// RBAC: el rol del token debe estar en la lista de roles permitidos.
  static void verificarRol(TokenPayload token, List<String> rolesPermitidos) {
    if (!rolesPermitidos.contains(token.rol)) {
      throw AccesoDenegadoException(
        'El rol "${token.rol}" no tiene permiso para esta operación',
      );
    }
  }

  /// Control fino — Paciente: solo puede operar sobre su propio RUT,
  /// aunque tenga un token válido (punto 6 del Esquema).
  static void verificarPropiedadPaciente(
    TokenPayload token,
    String rutRecurso,
  ) {
    if (token.rol == 'paciente' && token.rut != rutRecurso) {
      throw AccesoDenegadoException(
        'Solo puedes operar sobre tu propia información',
      );
    }
  }

  /// Control fino — Vacunador/Coordinador: solo pueden operar sobre el
  /// centro que tienen asignado.
  static void verificarPropiedadCentro(
    TokenPayload token, {
    required int centroIdRecurso,
    required int? centroIdAsignado,
  }) {
    final rolesConCentro = {'vacunador', 'coordinador'};
    if (rolesConCentro.contains(token.rol) &&
        centroIdAsignado != centroIdRecurso) {
      throw AccesoDenegadoException('No tienes acceso a este centro');
    }
  }

  /// Restricción — Admin: no puede acceder a historiales médicos
  /// individuales, solo a métricas agregadas de campaña.
  static void prohibirHistorialIndividualParaAdmin(TokenPayload token) {
    if (token.rol == 'admin') {
      throw AccesoDenegadoException(
        'El rol admin no puede acceder a historiales individuales de pacientes',
      );
    }
  }
}