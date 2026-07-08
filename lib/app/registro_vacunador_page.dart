import 'package:flutter/material.dart';
import '../servicios/auth/auth_service.dart';

class RegistroVacunadorPage extends StatefulWidget {
  const RegistroVacunadorPage({
    super.key,
    required this.operadorName,
    required this.centroName,
    required this.vacunadoresDisponibles,
    required this.onAsignarExistente,
    required this.onCrearNuevo,
    required this.onLogout,
  });

  final String operadorName;
  final String centroName;
  final List<AppUser> vacunadoresDisponibles;
  final void Function(AppUser) onAsignarExistente;
  final void Function(String rut, String fullName, String email, String password) onCrearNuevo;
  final VoidCallback onLogout;

  @override
  State<RegistroVacunadorPage> createState() => _RegistroVacunadorPageState();
}

class _RegistroVacunadorPageState extends State<RegistroVacunadorPage> {
  AppUser? _selectedVacunador;
  
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
    if (_selectedVacunador == null) return;
    widget.onAsignarExistente(_selectedVacunador!);
    setState(() {
      _selectedVacunador = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vacunador asignado exitosamente al centro.'), backgroundColor: Colors.green),
    );
  }

  void _registrarNuevo() {
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

    try {
      widget.onCrearNuevo(rut, fullName, email, password);
      _rutController.clear();
      _fullNameController.clear();
      _emailController.clear();
      _passwordController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vacunador creado y asignado exitosamente.'), backgroundColor: Colors.green),
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
        title: const Text('Gestión de Vacunadores', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00AAFF),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person, color: Colors.white),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text('Operador: ${widget.operadorName}'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Cerrar sesión'),
              ),
            ],
            onSelected: (val) {
              if (val == 'logout') widget.onLogout();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF003355), Color(0xFF00AAFF), Color(0xFFE8F7FF)],
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Centro de Vacunación:', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black54)),
                        Text(widget.centroName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF003355))),
                        const SizedBox(height: 8),
                        const Text('Asigna un vacunador existente o crea una nueva cuenta para este centro.', style: TextStyle(color: Colors.black54)),
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
                              const Text('1. Asignar vacunador existente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                          dropdownMenuEntries: widget.vacunadoresDisponibles.map((v) {
                                            return DropdownMenuEntry<AppUser>(
                                              value: v,
                                              label: '${v.rut ?? "Sin RUT"} - ${v.fullName}',
                                            );
                                          }).toList(),
                                          onSelected: (val) => setState(() => _selectedVacunador = val),
                                        );
                                      }
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  FilledButton.icon(
                                    onPressed: _selectedVacunador != null ? _asignarExistente : null,
                                    icon: const Icon(Icons.link),
                                    label: const Text('Asignar'),
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
                              const Text('2. Registrar nuevo vacunador', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                  label: const Text('Registrar y Asignar'),
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
    );
  }
}
