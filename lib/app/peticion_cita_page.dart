import 'package:flutter/material.dart';

import '../modelos/campana.dart';
import '../modelos/centro_vacunacion.dart';
import '../modelos/cita.dart';

/// Pantalla de "Petición de cita" para pacientes.
/// Muestra información de campaña, selección de centro, fecha
/// y grilla de horarios disponibles con paginación.
class PeticionCitaPage extends StatefulWidget {
  const PeticionCitaPage({
    super.key,
    required this.campanas,
    required this.centros,
    required this.userName,
    required this.onConfirmar,
    required this.onBack,
  });

  final List<Campana> campanas;
  final List<CentroVacunacion> centros;
  final String userName;
  final Future<void> Function(CentroVacunacion centro, String horario, {String? fecha}) onConfirmar;
  final VoidCallback onBack;

  @override
  State<PeticionCitaPage> createState() => _PeticionCitaPageState();
}

class _PeticionCitaPageState extends State<PeticionCitaPage> {
  static const Color kPrimaryBlue = Color(0xFF00AAFF);
  static const Color kDarkBlue = Color(0xFF0088DD);
  static const Color kLightBg = Color(0xFFF0F0F0);
  static const Color kFooterBlue = Color(0xFF00AAFF);

  Campana? _selectedCampana;
  CentroVacunacion? _selectedCentro;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedHorario;
  int _currentPage = 0;
  bool _isConfirming = false;

  /// Horarios de 09:00 a 14:00 cada 10 minutos (para demo)
  static final List<String> _allTimeSlots = _generateTimeSlots();

  static List<String> _generateTimeSlots() {
    final slots = <String>[];
    for (int hour = 9; hour <= 14; hour++) {
      for (int minute = 0; minute < 60; minute += 10) {
        if (hour == 14 && minute > 0) break;
        slots.add(
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
        );
      }
    }
    return slots;
  }

  /// Centros vinculados a la campaña seleccionada
  List<CentroVacunacion> get _centrosDisponibles {
    if (_selectedCampana == null) return widget.centros;
    return _selectedCampana!.centros.isNotEmpty
        ? _selectedCampana!.centros
        : widget.centros;
  }

  /// Fecha seleccionada formateada como 'YYYY-MM-DD'
  String get _fechaStr {
    return '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
  }

  /// Horarios que ya están reservados/completados en el centro PARA LA FECHA SELECCIONADA
  Set<String> get _horariosOcupados {
    if (_selectedCentro == null) return {};
    final fecha = _fechaStr;
    final ocupados = <String>{};
    for (final cita in _selectedCentro!.citas) {
      if ((cita.estado == CitaEstado.reservada || cita.estado == CitaEstado.completada) &&
          cita.fecha == fecha) {
        ocupados.add(cita.fechaHora);
      }
    }
    return ocupados;
  }

  /// Cantidad de horarios disponibles para la fecha seleccionada
  int get _vacunasDisponibles {
    if (_selectedCentro == null) return 0;
    return _selectedCentro!.horariosDisponiblesPorFecha(_fechaStr).length;
  }

  /// Slots organizados en columnas (3 columnas por página)
  List<String> get _activeSlotsSource {
    if (_selectedCentro != null && _selectedCentro!.horariosBase.isNotEmpty) {
      return _selectedCentro!.horariosBase;
    }
    return _allTimeSlots;
  }

  int get _slotsPerColumn => (_activeSlotsSource.length / 3).ceil();
  int get _totalPages => (_activeSlotsSource.length / (_slotsPerColumn * 3)).ceil().clamp(1, 99);

  List<List<String>> get _pagedColumns {
    final source = _activeSlotsSource;
    final columns = <List<String>>[];
    final startSlot = _currentPage * _slotsPerColumn * 3;

    for (int col = 0; col < 3; col++) {
      final colStart = startSlot + col * _slotsPerColumn;
      final colEnd = (colStart + _slotsPerColumn).clamp(0, source.length);
      if (colStart < source.length) {
        columns.add(source.sublist(colStart, colEnd));
      } else {
        columns.add([]);
      }
    }
    return columns;
  }

  String get _userInitials {
    final parts = widget.userName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  @override
  void initState() {
    super.initState();
    if (widget.campanas.isNotEmpty) {
      _selectedCampana = widget.campanas.first;
    }
    final centrosDisp = _centrosDisponibles;
    if (centrosDisp.isNotEmpty) {
      _selectedCentro = centrosDisp.first;
    }
  }

  Future<void> _onConfirmar() async {
    if (_selectedCentro == null || _selectedHorario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un horario disponible antes de confirmar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isConfirming = true);
    try {
      await widget.onConfirmar(_selectedCentro!, _selectedHorario!, fecha: _fechaStr);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cita confirmada a las $_selectedHorario.'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedHorario = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al confirmar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'CL'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedHorario = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBg,
      body: Column(
        children: [
          // ─── AppBar personalizado ───
          _buildAppBar(),
          // ─── Contenido principal ───
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Panel izquierdo ───
                  Expanded(
                    flex: 4,
                    child: _buildLeftPanel(),
                  ),
                  const SizedBox(width: 32),
                  // ─── Panel derecho (horarios) ───
                  Expanded(
                    flex: 6,
                    child: _buildRightPanel(),
                  ),
                ],
              ),
            ),
          ),
          // ─── Footer azul ───
          Container(
            height: 32,
            color: kFooterBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: kPrimaryBlue,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Logo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const Spacer(),
            // Título central
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sistema de campañas de vacunación',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ministerio de Salud',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Avatar usuario
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kDarkBlue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
              ),
              child: Center(
                child: Text(
                  _userInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftPanel() {
    final campanaNombre = _selectedCampana?.nombre ?? 'Sin campaña';
    final centroDir = _selectedCentro != null
        ? '${_selectedCentro!.direccion}, ${_selectedCentro!.comuna}, Region del ${_selectedCentro!.region}'
        : 'Selecciona un centro';
    final vacunasDisp = _vacunasDisponibles;
    final centroNombre = _selectedCentro?.nombre ?? '';
    final campNombre = _selectedCampana?.nombre ?? 'la campaña';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Título
        const Text(
          'Peticion de cita',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A1A),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        // Subtítulo campaña
        Text(
          'Campaña vacunación $campanaNombre',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: kPrimaryBlue,
          ),
        ),
        const SizedBox(height: 32),

        // ─── Selector de campaña (si hay más de 1) ───
        if (widget.campanas.length > 1) ...[
          const Text(
            'Campaña',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedCampana?.id,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: kPrimaryBlue),
                items: widget.campanas.map((c) {
                  return DropdownMenuItem<int>(
                    value: c.id,
                    child: Text(c.nombre, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (id) {
                  setState(() {
                    _selectedCampana = widget.campanas.firstWhere((c) => c.id == id);
                    final centrosDisp = _centrosDisponibles;
                    _selectedCentro = centrosDisp.isNotEmpty ? centrosDisp.first : null;
                    _selectedHorario = null;
                    _currentPage = 0;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // ─── Lugar ───
        const Text(
          'Lugar',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDDDDDD)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedCentro?.id,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: kPrimaryBlue),
              items: _centrosDisponibles.map((centro) {
                return DropdownMenuItem<int>(
                  value: centro.id,
                  child: Text(centro.nombre, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (id) {
                setState(() {
                  _selectedCentro = _centrosDisponibles.firstWhere((c) => c.id == id);
                  _selectedHorario = null;
                  _currentPage = 0;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ─── Dirección ───
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Direccion:   ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
            Expanded(
              child: Text(
                centroDir,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ─── Vacunas disponibles (con tooltip contextual) ───
        Row(
          children: [
            const Text(
              'Cantidad de vacunas disponibles:   ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              '$vacunasDisp',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kPrimaryBlue,
              ),
            ),
            const SizedBox(width: 6),
            Tooltip(
              message:
                  '$vacunasDisp horarios disponibles para $campNombre\nen $centroNombre para el día seleccionado.',
              preferBelow: true,
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(color: Colors.white, fontSize: 12),
              child: const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: kPrimaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ─── Fecha de la cita (DatePicker unificado) ───
        const Text(
          'Fecha de la cita',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: kPrimaryBlue, size: 20),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')} / ${_selectedDate.month.toString().padLeft(2, '0')} / ${_selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF999999)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // ─── Botón volver ───
        TextButton.icon(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: const Text('Volver al panel'),
          style: TextButton.styleFrom(
            foregroundColor: kPrimaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel() {
    final columns = _pagedColumns;
    final ocupados = _horariosOcupados;

    return Column(
      children: [
        // ─── Paginación ───
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _currentPage > 0
                  ? () => setState(() {
                        _currentPage--;
                        _selectedHorario = null;
                      })
                  : null,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Anterior'),
              style: TextButton.styleFrom(
                foregroundColor: _currentPage > 0 ? const Color(0xFF555555) : const Color(0xFFBBBBBB),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${_currentPage + 1}/$_totalPages',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(width: 16),
            _currentPage < _totalPages - 1
                ? FilledButton.icon(
                    onPressed: () => setState(() {
                      _currentPage++;
                      _selectedHorario = null;
                    }),
                    icon: const Text('Siguiente'),
                    label: const Icon(Icons.arrow_forward, size: 16),
                    style: FilledButton.styleFrom(
                      backgroundColor: kPrimaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: null,
                    icon: const Text('Siguiente'),
                    label: const Icon(Icons.arrow_forward, size: 16),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFBBBBBB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
          ],
        ),
        const SizedBox(height: 16),

        // ─── Grilla de horarios ───
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(columns.length, (colIndex) {
            final col = columns[colIndex];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: colIndex > 0 ? 8 : 0,
                  right: colIndex < columns.length - 1 ? 8 : 0,
                ),
                child: Column(
                  children: col.map((slot) {
                    final isOccupied = ocupados.contains(slot);
                    final isSelected = _selectedHorario == slot;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _TimeSlotButton(
                        time: slot,
                        isAvailable: !isOccupied,
                        isSelected: isSelected,
                        onTap: isOccupied
                            ? null
                            : () {
                                setState(() {
                                  _selectedHorario = slot;
                                });
                              },
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        // ─── Botón Confirmar ───
        SizedBox(
          width: 200,
          height: 48,
          child: FilledButton(
            onPressed: _isConfirming ? null : _onConfirmar,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF222222),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: _isConfirming
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Confirmar'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Botón individual de horario en la grilla
class _TimeSlotButton extends StatefulWidget {
  const _TimeSlotButton({
    required this.time,
    required this.isAvailable,
    required this.isSelected,
    required this.onTap,
  });

  final String time;
  final bool isAvailable;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  State<_TimeSlotButton> createState() => _TimeSlotButtonState();
}

class _TimeSlotButtonState extends State<_TimeSlotButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final Color borderColor;

    if (widget.isSelected) {
      bgColor = const Color(0xFF0088DD);
      textColor = Colors.white;
      borderColor = const Color(0xFF0066BB);
    } else if (widget.isAvailable) {
      bgColor = _isHovered
          ? const Color(0xFF0099EE)
          : const Color(0xFF00AAFF);
      textColor = Colors.white;
      borderColor = const Color(0xFF0088DD);
    } else {
      bgColor = const Color(0xFFE0E0E0);
      textColor = const Color(0xFF999999);
      borderColor = const Color(0xFFD0D0D0);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isAvailable
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isSelected
                  ? borderColor
                  : borderColor.withValues(alpha: 0.4),
              width: widget.isSelected ? 2.5 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF00AAFF).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              widget.time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
