import 'package:flutter/material.dart';
import '../servicios/auth/auth_service.dart';
import '../modelos/centro_vacunacion.dart';
import '../modelos/campana.dart';

class RegistroOperadorPage extends StatefulWidget {
  const RegistroOperadorPage({
    super.key,
    required this.adminName,
    required this.centros,
    required this.campanas,
    required this.operadoresDisponibles,
    required this.onAsignarExistente,
    required this.onCrearNuevo,
    required this.onBack,
  });

  final String adminName;
  final List<CentroVacunacion> centros;
  final List<Campana> campanas;
  final List<AppUser> operadoresDisponibles;
  final void Function(AppUser operador, int centroId, int campanaId) onAsignarExistente;
  final void Function(String rut, String fullName, String email, String password, int centroId, int campanaId) onCrearNuevo;
  final VoidCallback onBack;

  @override
  State<RegistroOperadorPage> createState() => _RegistroOperadorPageState();
}

class _RegistroOperadorPageState extends State<RegistroOperadorPage> {
  CentroVacunacion? _selectedCentro;
  AppUser? _selectedOperador;
  
  final _rutController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _rutController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _asignarExistente() {
    if (_selectedCentro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un centro primero.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_selectedOperador == null) return;

    // Asumimos que lo asignamos a la primera campaña (como en el resto del sistema por ahora) o a la campaña asociada al centro.
    // Para simplificar, usamos campanaId = 1 por defecto, o la primera si existe.
    final campanaId = widget.campanas.isNotEmpty ? widget.campanas.first.id : 1;

    widget.onAsignarExistente(_selectedOperador!, _selectedCentro!.id, campanaId);
    setState(() {
      _selectedOperador = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Operador asignado exitosamente al centro.'), backgroundColor: Colors.green),
    );
  }

  void _registrarNuevo() {
    if (_selectedCentro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un centro primero.'), backgroundColor: Colors.red),
      );
      return;
    }

    final rut = _rutController.text.trim();
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    if (rut.isEmpty || fullName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos.'), backgroundColor: Colors.red),
      );
      return;
    }

    final campanaId = widget.campanas.isNotEmpty ? widget.campanas.first.id : 1;

    try {
      widget.onCrearNuevo(rut, fullName, email, password, _selectedCentro!.id, campanaId);
      _rutController.clear();
      _fullNameController.clear();
      _emailController.clear();
      _passwordController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Operador creado y asignado exitosamente.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Operadores', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF10B981), // Verde para Administrador
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF003322), Color(0xFF10B981), Color(0xFFE8F7F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Card(
                  elevation: 14,
                  color: Colors.white.withValues(alpha: 0.96),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Asignación de Operadores', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF003322))),
                          const SizedBox(height: 8),
                          const Text('Selecciona el centro y luego asigna o crea el operador responsable.', style: TextStyle(color: Colors.black54)),
                          const SizedBox(height: 32),
                      
                          // Seleccionar Centro
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFA0E8D0)),
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.green.shade50,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('1. Seleccionar Centro de Vacunación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<CentroVacunacion>(
                                  value: _selectedCentro,
                                  decoration: const InputDecoration(
                                    labelText: 'Centro de Vacunación',
                                    border: OutlineInputBorder(),
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                  items: widget.centros.map((c) {
                                    return DropdownMenuItem(
                                      value: c,
                                      child: Text('${c.nombre} (${c.comuna})'),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => _selectedCentro = val),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Asignar Existente
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFD0E8FF)),
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('2. Asignar operador existente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return DropdownMenu<AppUser>(
                                            width: constraints.maxWidth,
                                            enableFilter: true,
                                            enableSearch: true,
                                            label: const Text('Buscar por RUT o Nombre'),
                                            leadingIcon: const Icon(Icons.search),
                                            dropdownMenuEntries: widget.operadoresDisponibles.map((v) {
                                              return DropdownMenuEntry<AppUser>(
                                                value: v,
                                                label: '${v.rut ?? "Sin RUT"} - ${v.fullName}',
                                              );
                                            }).toList(),
                                            onSelected: (val) => setState(() => _selectedOperador = val),
                                          );
                                        }
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    FilledButton.icon(
                                      onPressed: _selectedOperador != null ? _asignarExistente : null,
                                      icon: const Icon(Icons.link),
                                      label: const Text('Asignar al Centro'),
                                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          const Center(child: Text('O', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey))),
                          const SizedBox(height: 32),
                          
                          // Crear Nuevo
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFD0E8FF)),
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('3. Registrar nuevo operador', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _rutController,
                                        decoration: const InputDecoration(labelText: 'RUT', border: OutlineInputBorder()),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _fullNameController,
                                        decoration: const InputDecoration(labelText: 'Nombre completo', border: OutlineInputBorder()),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _emailController,
                                        decoration: const InputDecoration(labelText: 'Correo electrónico', border: OutlineInputBorder()),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _passwordController,
                                        obscureText: true,
                                        decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FilledButton.icon(
                                    onPressed: _registrarNuevo,
                                    icon: const Icon(Icons.person_add),
                                    label: const Text('Registrar y Asignar al Centro'),
                                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
