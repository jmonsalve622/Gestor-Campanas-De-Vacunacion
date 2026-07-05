class Vacunador {
  String _rut;
  String _nombres;
  String _apellidos;
  String _correo;

  Vacunador({
    required String rut,
    required String nombres,
    required String apellidos,
    required String correo,
  })  : _rut = rut,
        _nombres = nombres,
        _apellidos = apellidos,
        _correo = correo;

  @override
  String toString() {
    return 'Vacunador{_rut: $_rut, _nombres: $_nombres, _apellidos: $_apellidos, _correo: $_correo}';
  }
}