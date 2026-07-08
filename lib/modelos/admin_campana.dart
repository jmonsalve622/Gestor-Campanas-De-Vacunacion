class AdminCampana {
  final String _rut;
  final String _nombres;
  final String _apellidos;
  final String _correo;

  AdminCampana({
    required String rut,
    required String nombres,
    required String apellidos,
    required String correo,
  }) : _rut = rut,
       _nombres = nombres,
       _apellidos = apellidos,
       _correo = correo{
    if (!_esRutValido(_rut)) throw Exception("El RUT ingresado no es valido.");

    if (!_esCorreoValido(_correo))
      throw Exception("El correo ingresado no es valido.");

  }

  // Verificacion formato caracteres@caracteres.2oMasCaracteres.
  bool _esCorreoValido(String correo) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(correo);
  }

  // Verifica tanto el formato del RUT, como si cumple con los requisitos de nu numero verificador.
  bool _esRutValido(String rut) {
    // Primero ve como fue ingresado este rut.
    int? puntos;
    if (!rut.contains("-")) return false;
    if (rut.contains(".")) {
      if (rut.length < 11) return false;
      puntos = 0;
    } else {
      if (rut.length < 9) return false;
    }

    // Verificacion caracter a caracter segun revision anterior.
    List<String> digitosRut = rut.split("");
    int nums = 0;
    bool raya = false;
    for (int j = 0; j < digitosRut.length; j++) {
      int? i = int.tryParse(digitosRut[j]);
      if (i == null) {
        if (digitosRut[j] == "." && puntos != null) {
          if (puntos > 2) {
            return false;
          }
          puntos++;
          continue;
        } else if ((digitosRut[j] == "-") && (j == digitosRut.length - 2)) {
          raya = true;
          continue;
        } else if (raya && ((digitosRut[j] == "k") || (digitosRut[j] == "K")))
          continue;
        return false;
      }
      if (!raya) {
        nums *= 10;
        nums += i;
      }
    }
    if (nums > 40000000 ||
        nums < 500000 ||
        (puntos != 2 && rut.contains("."))) {
      return false;
    }

    return _verificarModulo11(rut);
  }

  bool _verificarModulo11(String rut) {
    // Dejamos el RUT solo con numeros y, si tiene, la k.
    String rutLimpio = rut
        .replaceAll('.', '')
        .replaceAll('-', '')
        .toUpperCase();

    if (rutLimpio.length < 2) return false;

    // Separamos del dígito verificador (el último carácter).
    String cuerpo = rutLimpio.substring(0, rutLimpio.length - 1);
    String dvIngresado = rutLimpio.substring(rutLimpio.length - 1);

    int suma = 0;
    int multiplicador = 2;

    for (int i = cuerpo.length - 1; i >= 0; i--) {
      int? digito = int.tryParse(cuerpo[i]);
      if (digito == null) return false;

      suma += digito * multiplicador;

      multiplicador++;
      if (multiplicador > 7) {
        multiplicador = 2;
      }
    }

    int resto = suma % 11;
    int resultado = 11 - resto;

    // Transformamos el resultado matemático al dígito esperado.
    String dvEsperado;
    if (resultado == 11) {
      dvEsperado = "0";
    } else if (resultado == 10) {
      dvEsperado = "K";
    } else {
      dvEsperado = resultado.toString();
    }

    return dvIngresado == dvEsperado;
  }

  String getRut() {
    return _rut;
  }

  String get rut => _rut;

  String getNombres() {
    return _nombres;
  }

  String get nombres => _nombres;

  String getApellidos() {
    return _apellidos;
  }

  String get apellidos => _apellidos;

  String getCorreo() {
    return _correo;
  }

  String get correo => _correo;
  @override
  String toString() {
    String pre =
        "Persona{RUT=$_rut, nombres=$_nombres, apellidos=$_apellidos , correo=$_correo";

    return pre;
  }
}
