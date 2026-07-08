import 'package:flutter/material.dart';

import '../modelos/Persona.dart';
import '../modelos/campana.dart';
import '../modelos/centro_vacunacion.dart';
import '../modelos/cita.dart';

class RegistroVacunaPage extends StatefulWidget {
  const RegistroVacunaPage({
    super.key,
    this.campanasAsignadas = const [],
    this.centrosAsignados = const [],
    required this.personalMedicoNombre,
    required this.onSearchRut,
    required this.onRegistrar,
    this.onBack,
    this.onLogout,
  });

  final List<Campana> campanasAsignadas;
  final List<CentroVacunacion> centrosAsignados;
  final String personalMedicoNombre;
  final Persona? Function(String rut) onSearchRut;
  final Future<void> Function(Persona paciente, Cita cita, String nombreVacuna, String observaciones) onRegistrar;
  final VoidCallback? onBack;
  final VoidCallback? onLogout;

  @override
  State<RegistroVacunaPage> createState() => _RegistroVacunaPageState();
}

class _RegistroVacunaPageState extends State<RegistroVacunaPage> {
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _vacunaController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  Persona? _pacienteEncontrado;
  Cita? _citaSeleccionada;
  CentroVacunacion? _centroActual;
  Campana? _campanaActual;
  String _errorMessage = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _centroActual = widget.centrosAsignados.isNotEmpty ? widget.centrosAsignados.first : null;
    _campanaActual = widget.campanasAsignadas.isNotEmpty ? widget.campanasAsignadas.first : null;
  }

  void _buscarPaciente() {
    final rut = _rutController.text.trim();
    if (rut.isEmpty) return;

    final paciente = widget.onSearchRut(rut);
    setState(() {
      _pacienteEncontrado = paciente;
      _citaSeleccionada = null;
      if (paciente == null) {
        _errorMessage = 'Paciente no encontrado.';
      } else {
        _errorMessage = '';
        final citasPendientes = paciente.citas.where(
          (c) => c.estado.label == 'RESERVADA' && 
                 c.centroVacunacion?.id == _centroActual?.id &&
                 c.campana?.id == _campanaActual?.id
        ).toList();
        if (citasPendientes.isNotEmpty) {
          _citaSeleccionada = citasPendientes.first;
        }
      }
    });
  }

  Future<void> _registrar() async {
    if (_pacienteEncontrado == null) return;
    
    if (_citaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar una cita para registrar la vacuna.'), backgroundColor: Colors.red),
      );
      return;
    }

    final vacuna = _vacunaController.text.trim();
    if (vacuna.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe ingresar el nombre de la vacuna.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.onRegistrar(
        _pacienteEncontrado!,
        _citaSeleccionada!,
        vacuna,
        _observacionesController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vacuna registrada con éxito.'), backgroundColor: Colors.green),
        );
        _vacunaController.clear();
        _observacionesController.clear();
        _buscarPaciente(); // Refrescar los datos
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'Sistema de campañas de vacunación',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00AAFF),
        foregroundColor: Colors.white,
        leading: widget.onBack != null 
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        actions: widget.onLogout != null
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: widget.onLogout,
                  tooltip: 'Cerrar sesión',
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                // ─── Header Simplificado ───
                Text(
                  'Campaña de Vacunación: ${_campanaActual?.nombre ?? 'General'}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Personal Médico: ${widget.personalMedicoNombre}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF00AAFF),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Centro de Vacunación: ${_centroActual?.nombre ?? 'No especificado'}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF00AAFF),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // ─── Contenido Principal ───
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Columna Izquierda: Búsqueda y Paciente ───
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.campanasAsignadas.isNotEmpty) ...[
                            DropdownButtonFormField<Campana>(
                              value: _campanaActual,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Campaña Actual',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                              ),
                              items: widget.campanasAsignadas.map((c) {
                                return DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c.nombre,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _campanaActual = val;
                                  // Limpiar estado
                                  _pacienteEncontrado = null;
                                  _citaSeleccionada = null;
                                  _errorMessage = '';
                                  _rutController.clear();
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (widget.centrosAsignados.isNotEmpty) ...[
                            DropdownButtonFormField<CentroVacunacion>(
                              isExpanded: true,
                              value: _centroActual,
                              decoration: InputDecoration(
                                labelText: 'Centro de Vacunación Actual',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                              ),
                              items: widget.centrosAsignados.map((c) {
                                return DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c.nombre,
                                    overflow: TextOverflow.ellipsis, 
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _centroActual = val;
                                  // Limpiar estado
                                  _pacienteEncontrado = null;
                                  _citaSeleccionada = null;
                                  _errorMessage = '';
                                  _rutController.clear();
                                });
                              },
                            ),
                            const SizedBox(height: 32),
                          ],
                          const Text(
                            'Ingresar RUT del paciente',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: TextField(
                              controller: _rutController,
                              decoration: InputDecoration(
                                hintText: 'Ej: 18.168.357-0',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.search),
                                  onPressed: _buscarPaciente,
                                ),
                              ),
                              onSubmitted: (_) => _buscarPaciente(),
                            ),
                          ),
                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                              child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                            ),
                          const SizedBox(height: 32),
                          if (_pacienteEncontrado != null) ...[
                            _InfoRow(label: 'Nombres:', value: _pacienteEncontrado!.nombres),
                            const SizedBox(height: 24),
                            _InfoRow(label: 'Apellidos:', value: _pacienteEncontrado!.apellidos),
                            const SizedBox(height: 24),
                            _InfoRow(
                              label: 'Fecha Nacimiento:',
                              value: '${_pacienteEncontrado!.fechaNacimiento.day.toString().padLeft(2, '0')}/${_pacienteEncontrado!.fechaNacimiento.month.toString().padLeft(2, '0')}/${_pacienteEncontrado!.fechaNacimiento.year}',
                            ),
                            const SizedBox(height: 24),
                            _InfoRow(label: 'Correo:', value: _pacienteEncontrado!.correo),
                            const SizedBox(height: 24),
                            _InfoRow(label: 'Teléfono:', value: _pacienteEncontrado!.telefono),
                          ] else if (_errorMessage.isEmpty) ...[
                            const Center(
                              child: Text(
                                'Busque un paciente para ver sus datos.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),

                    // ─── Columna Derecha: Historial y Nueva Vacuna ───
                    Expanded(
                      flex: 6,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Historial de vacunas',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 160,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1D5DB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _pacienteEncontrado == null
                                  ? const Center(child: Text('Sin datos'))
                                  : SingleChildScrollView(child: _buildHistorial()),
                            ),
                            const SizedBox(height: 12),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Abrir historial completo', style: TextStyle(color: Colors.black54)),
                                SizedBox(width: 16),
                                Icon(Icons.arrow_back, size: 16),
                                SizedBox(width: 8),
                                Text('1/1'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 16),
                              ],
                            ),
                            const SizedBox(height: 48),
                            if (_pacienteEncontrado != null) ...[
                              Builder(
                                builder: (context) {
                                  final citasPendientes = _pacienteEncontrado!.citas
                                      .where((c) => c.estado.label == 'RESERVADA' &&
                                                    c.centroVacunacion?.id == _centroActual?.id &&
                                                    c.campana?.id == _campanaActual?.id)
                                      .toList();
                                  
                                  if (citasPendientes.isEmpty) return const SizedBox.shrink();
                        
                                  final validCita = citasPendientes.contains(_citaSeleccionada) 
                                      ? _citaSeleccionada 
                                      : null;
                        
                                  // Si la cita seleccionada ya no es válida, la actualizamos en el siguiente frame
                                  if (_citaSeleccionada != null && validCita == null) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      if (mounted) setState(() => _citaSeleccionada = null);
                                    });
                                  }
                        
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Seleccionar Cita:',
                                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 7,
                                        child: DropdownButtonFormField<Cita>(
                                          isExpanded: true,
                                          value: validCita,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                            ),
                                          ),
                                          items: citasPendientes
                                              .map((cita) => DropdownMenuItem(
                                                    value: cita,
                                                    child: Text('ID: ${cita.id} - ${cita.fechaHora} (${cita.campana?.nombre ?? 'General'})'),
                                                  ))
                                              .toList(),
                                          onChanged: (cita) {
                                            setState(() {
                                              _citaSeleccionada = cita;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              ),
                              const SizedBox(height: 24),
                            ],
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Nueva Vacuna:',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 7,
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: _vacunaController,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintText: 'Ej: Vacuna triple vírica',
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Observaciones:',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                  ),
                                ),
                                Expanded(
                                  flex: 7,
                                  child: TextField(
                                    controller: _observacionesController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Añadir observaciones relevantes...',
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: 180,
                                height: 48,
                                child: FilledButton(
                                  onPressed: _isSubmitting || _pacienteEncontrado == null ? null : _registrar,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF374151),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isSubmitting
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text('Registrar vacuna', style: TextStyle(fontSize: 14)),
                                ),
                              ),
                            )
                          ],
                        ),
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

  Widget _buildHistorial() {
    final citasCompletadas = _pacienteEncontrado!.citas
        .where((c) => c.estado.label == 'COMPLETADA' && c.vacunacion != null)
        .toList();

    if (citasCompletadas.isEmpty) {
      return const Center(child: Text('No hay historial de vacunas registradas.'));
    }

    return Column(
      children: citasCompletadas.map((cita) {
        final vacuna = cita.vacunacion!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Campaña #${vacuna.campana?.id ?? '-'}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text('Observaciones:', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      vacuna.observaciones,
                      overflow: TextOverflow.ellipsis, // Corta el texto si es muy largo
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Text('ID: ${vacuna.id}'),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fecha y hora: ', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text(cita.fechaHora),
                  ],
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
        ),
      ],
    );
  }
}
