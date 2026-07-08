import 'package:flutter/material.dart';

import '../modelos/campana.dart';
import '../modelos/centro_vacunacion.dart';

class CreacionCampanaPage extends StatefulWidget {
  const CreacionCampanaPage({
    super.key,
    required this.adminName,
    required this.todosLosCentros,
    required this.onCrearCampana,
    this.onLogout,
  });

  final String adminName;
  final List<CentroVacunacion> todosLosCentros;
  final Function(Campana campana, String vacunaNombre, List<String> admins) onCrearCampana;
  final VoidCallback? onLogout;

  @override
  State<CreacionCampanaPage> createState() => _CreacionCampanaPageState();
}

class _CreacionCampanaPageState extends State<CreacionCampanaPage> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _adminRutController = TextEditingController();
  final _vacunaController = TextEditingController();

  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  final List<String> _administradoresRuts = [];
  final List<CentroVacunacion> _centrosAnadidos = [];
  CentroVacunacion? _centroSeleccionado;

  Future<void> _seleccionarFecha(BuildContext context, bool isInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      helpText: isInicio ? 'Seleccionar Fecha de Inicio' : 'Seleccionar Fecha de Fin',
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _fechaInicio = picked;
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  void _anadirAdministrador() {
    final rut = _adminRutController.text.trim();
    if (rut.isNotEmpty && !_administradoresRuts.contains(rut)) {
      setState(() {
        _administradoresRuts.add(rut);
        _adminRutController.clear();
      });
    }
  }

  void _anadirCentro() {
    if (_centroSeleccionado != null && !_centrosAnadidos.contains(_centroSeleccionado!)) {
      setState(() {
        _centrosAnadidos.add(_centroSeleccionado!);
        _centroSeleccionado = null; // Reset
      });
    }
  }

  void _crearCampana() {
    final nombre = _nombreController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final vacuna = _vacunaController.text.trim();

    if (nombre.isEmpty || descripcion.isEmpty || _fechaInicio == null || _fechaFin == null || vacuna.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos obligatorios.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_fechaFin!.isBefore(_fechaInicio!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha de fin no puede ser anterior a la de inicio.'), backgroundColor: Colors.red),
      );
      return;
    }

    final String fechaInicioStr = '${_fechaInicio!.year}-${_fechaInicio!.month.toString().padLeft(2, '0')}-${_fechaInicio!.day.toString().padLeft(2, '0')}';
    final String fechaFinStr = '${_fechaFin!.year}-${_fechaFin!.month.toString().padLeft(2, '0')}-${_fechaFin!.day.toString().padLeft(2, '0')}';

    final nuevaCampana = Campana(
      id: 0, // Será asignado por el Shell
      nombre: nombre,
      descripcion: descripcion,
      fechaInicio: fechaInicioStr,
      fechaFin: fechaFinStr,
    );

    for (var centro in _centrosAnadidos) {
      nuevaCampana.agregarCentroVacunacion(centro);
    }

    widget.onCrearCampana(nuevaCampana, vacuna, _administradoresRuts);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00AAFF),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text('Sistema de campañas de vacunación', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Ministerio de Salud', style: TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Cuenta de administrador: ${widget.adminName}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          if (widget.onLogout != null)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Cerrar sesión',
              onPressed: widget.onLogout,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Creación campaña de vacunación',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Nombre de la campaña principal
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    hintText: 'Nombre campaña de vacunación',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 48),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- COLUMNA IZQUIERDA ---
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Añadir administradores', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _adminRutController,
                                  decoration: InputDecoration(
                                    hintText: 'Ingrese RUT',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                                  ),
                                  onSubmitted: (_) => _anadirAdministrador(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Color(0xFF00AAFF), size: 32),
                                onPressed: _anadirAdministrador,
                                tooltip: 'Añadir RUT',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _administradoresRuts.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'Aún no se han añadido administradores a esta campaña',
                                        style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _administradoresRuts.length,
                                    itemBuilder: (context, index) {
                                      final rut = _administradoresRuts[index];
                                      return ListTile(
                                        title: Text(rut),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              _administradoresRuts.removeAt(index);
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 32),
                          const Text('Descripción campaña:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _descripcionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Escriba una descripción detallada...',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text('Fecha de inicio de campaña:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _seleccionarFecha(context, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today, color: Color(0xFF00AAFF), size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    _fechaInicio != null ? _formatDate(_fechaInicio!) : 'Seleccionar fecha',
                                    style: TextStyle(color: _fechaInicio != null ? Colors.black : Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text('Fecha de fin de campaña:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _seleccionarFecha(context, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today, color: Color(0xFF00AAFF), size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    _fechaFin != null ? _formatDate(_fechaFin!) : 'Seleccionar fecha',
                                    style: TextStyle(color: _fechaFin != null ? Colors.black : Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 64),
                    // --- COLUMNA DERECHA ---
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Añadir centros de vacunación:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<CentroVacunacion>(
                                  value: _centroSeleccionado,
                                  decoration: InputDecoration(
                                    hintText: 'Seleccionar centro...',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                                  ),
                                  items: widget.todosLosCentros.map((c) {
                                    return DropdownMenuItem(
                                      value: c,
                                      child: Text(c.nombre),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _centroSeleccionado = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Color(0xFF00AAFF), size: 32),
                                onPressed: _anadirCentro,
                                tooltip: 'Añadir Centro',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _centrosAnadidos.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'Aún no se han añadido centros de vacunación a esta campaña',
                                        style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _centrosAnadidos.length,
                                    itemBuilder: (context, index) {
                                      final centro = _centrosAnadidos[index];
                                      return ListTile(
                                        title: Text(centro.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text('${centro.direccion}, ${centro.comuna}\nRegión: ${centro.region}'),
                                        isThreeLine: true,
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              _centrosAnadidos.removeAt(index);
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 32),
                          const Text('Nombre de la vacuna a administrar:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _vacunaController,
                            decoration: InputDecoration(
                              hintText: 'Ej: Vacuna triple vírica',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                            ),
                          ),
                          const SizedBox(height: 48),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: _crearCampana,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF374151), // Gris oscuro como en la imagen
                                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Crear campaña', style: TextStyle(fontSize: 16, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
