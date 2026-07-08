import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// Controlador de Seguridad — emisión y validación de JWT.
/// Corresponde al punto 1 ("Emisión de token") y 2 ("Manejo de Sesión")
/// del Esquema de Seguridad.
class JwtService {
  // LIMITACIÓN DE PROTOTIPO: al no existir un backend separado, la clave de
  // firma vive embebida en el cliente Flutter. En un despliegue real esto
  // NUNCA debe estar hardcodeado: debe vivir solo en el backend, cargada
  // desde variable de entorno (.env, nunca versionada en git).
  // Se documenta como limitación conocida en el informe, igual que la
  // ausencia de blacklist de tokens.
  static const String _secret =
      'REEMPLAZAR_POR_VARIABLE_DE_ENTORNO_EN_PRODUCCION';

  static const Duration duracionSesion = Duration(hours: 24);

  /// Genera un JWT firmado HS256 con los claims descritos en el Esquema:
  /// sub (RUT), rol, nombre, iat (emisión) y exp (expiración, 24h).
  static String generar({
    required String rut,
    required String rol,
    required String nombre,
  }) {
    final jwt = JWT({
      'sub': rut,
      'rol': rol,
      'nombre': nombre,
    });

    return jwt.sign(
      SecretKey(_secret),
      algorithm: JWTAlgorithm.HS256,
      expiresIn: duracionSesion,
    );
  }

  /// Verifica firma y expiración. Retorna el payload si es válido.
  /// Lanza [JWTExpiredError] o [JWTInvalidError] si no lo es — el llamador
  /// (SecurityController) es responsable de traducir eso a 401/403.
  static Map<String, dynamic> verificar(String token) {
    final jwt = JWT.verify(token, SecretKey(_secret));
    return Map<String, dynamic>.from(jwt.payload as Map);
  }
}