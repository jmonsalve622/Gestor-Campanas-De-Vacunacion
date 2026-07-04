import 'package:gestor_aplicacion/modelos/cita.dart';

class Persona{
  String _rut;
  String _nombres;
  String _apellidos;
  DateTime _fechaNacimiento;
  String _correo;
  String _telefono;
  List<Cita> _citas = [];

  Persona({
    required this._rut,
    required this._nombres,
    required this._apellidos,
    required this._fechaNacimiento,
    required this._correo,
    required this._telefono
  }){
 
    if(!_esRutValido(_rut))
      throw Exception("El RUT ingresado no es valido.");
    
    if(!_esCorreoValido(_correo))
      throw Exception("El correo ingresado no es valido.");

    if(!_esTelefonoValido(_telefono))
      throw Exception("El telefono ingresado no es valido.");

    

  }

  void agregarCita(Cita cita) {
    _citas.add(cita);
  }

  void eliminarCita(Cita cita) {
    _citas.remove(cita);
  }

  // Verificacion formato caracteres@caracteres.2oMasCaracteres.
  bool _esCorreoValido(String correo){
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(correo);
  }

  // Verifica telofono sea de Chile.
  bool _esTelefonoValido(String telefono){
    String telefonoJunto = telefono.replaceAll(' ', '');
    return RegExp(r'^\+569[0-9]{8}$').hasMatch(telefonoJunto);
  }

  // Verifica tanto el formato del RUT, como si cumple con los requisitos de nu numero verificador.
  bool _esRutValido(String rut){

    // Primero ve como fue ingresado este rut.
    int? puntos;
    if(!rut.contains("-"))
      return false;
    if(rut.contains(".")){
      if(rut.length<11)
        return false;
      puntos = 0;
    }else{
      if(rut.length<9)
        return false;
    }

    // Verificacion caracter a caracter segun revision anterior.
    List<String> digitosRut = rut.split("");
    int nums = 0;
    bool raya = false;
    for (int j = 0; j < digitosRut.length; j++) {
      int? i = int.tryParse(digitosRut[j]);
      if(i == null){
        if(digitosRut[j] == "." && puntos != null){
          if (puntos > 2){
            return false;
          }
          puntos++;
          continue;
        } else if((digitosRut[j] == "-") && (j == digitosRut.length-2)){
          raya = true;  
          continue;
        }else if(raya && ((digitosRut[j] == "k") || (digitosRut[j] == "K")))
          continue;
        return false;
      }
      if(!raya){
        nums *= 10;
        nums += i;
      }
    }
    if (nums>40000000 || nums < 500000 || (puntos !=2 && rut.contains("."))){
      return false;
    }

    return _verificarModulo11(rut);
  }
  
  bool _verificarModulo11(String rut) {
    // Dejamos el RUT solo con numeros y, si tiene, la k.
    String rutLimpio = rut.replaceAll('.', '').replaceAll('-', '').toUpperCase();

    if (rutLimpio.length < 2) 
      return false;

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

  String getRut(){
    return _rut;
  }

  String getNombres(){
    return _nombres;
  }

  String getApellidos(){
    return _apellidos;
  }

  DateTime getFechaNacimiento(){
    return _fechaNacimiento;
  }

  String getCorreo(){
    return _correo;
  }

  String getTelefono(){
    return _telefono;
  }

  List<Cita> getCitas(){
    return _citas;
  }

  int getEdad() {
    DateTime hoy = DateTime.now();
    int edad = hoy.year - _fechaNacimiento.year;
    
    if (hoy.month < _fechaNacimiento.month || 
      (hoy.month == _fechaNacimiento.month && hoy.day < _fechaNacimiento.day)) {
      edad--;
    }
    
    return edad;
  }

  @override
  String toString() {
    String pre = "Persona{RUT=$_rut, nombres=$_nombres, apellidos=$_apellidos , fecha_nacimiento=${_fechaNacimiento.toString()}, correo=$_correo, telefono=$_telefono \n\nCitas:\n";
    String listaCitas = _citas.map((c) => "- ${c.toString()}").join('\n');

    return pre+listaCitas;
  }

}

void main(){
  Persona p = Persona(rut: "21.343.419-5", nombres: "poya", apellidos: "apellidos", fechaNacimiento: DateTime(2000), correo: "correo@gmail.cl", telefono: "+56966774455");
  print(p.toString());
  print("object");
}