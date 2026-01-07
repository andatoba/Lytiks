import 'dart:async';
import 'package:flutter/material.dart';
import '../services/registro_moko_service.dart';
import '../services/seguimiento_moko_service.dart';

class SeguimientoFocosScreen extends StatefulWidget {
  const SeguimientoFocosScreen({super.key});

  @override
  State<SeguimientoFocosScreen> createState() => _SeguimientoFocosScreenState();
}

class _SeguimientoFocosScreenState extends State<SeguimientoFocosScreen> {
  // Servicios
  final RegistroMokoService _registroMokoService = RegistroMokoService();
  final SeguimientoMokoService _seguimientoMokoService =
      SeguimientoMokoService();

  // Estado
  List<Map<String, dynamic>> focos = [];
  Map<String, dynamic>? focoSeleccionado;
  bool _isLoading = true;
  bool _isSaving = false;

  // Controladores para seguimiento específico
  final TextEditingController _plantasAfectadasController =
      TextEditingController();
  final TextEditingController _plantasInyectadasController =
      TextEditingController();
  final TextEditingController _ppmSolucionController = TextEditingController();

  // Variables booleanas para medidas de control
  bool _controlVectores = false;
  bool _cuarentenaActiva = false;
  bool _unicaEntradaHabilitada = false;
  bool _eliminacionMalezaHospedera = false;
  bool _controlPicudoAplicado = false;
  bool _inspeccionPlantasVecinas = false;
  bool _corteRiego = false;
  bool _pediluvioActivo = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final focosData = await _registroMokoService.getRegistros();

      setState(() {
        focos = focosData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error al cargar datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFED8936),
        title: const Text(
          'Seguimiento de Focos',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : focoSeleccionado == null
          ? _buildSeleccionFoco()
          : _buildFormularioSeguimiento(),
    );
  }

  Widget _buildSeleccionFoco() {
    if (focos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay focos registrados para seguimiento',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: focos.length,
            itemBuilder: (context, index) {
              final foco = focos[index];
              return _buildFocoSeleccionCard(foco);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFED8936), Color(0xFFDD6B20)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.track_changes, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seguimiento de Focos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Selecciona un foco para actualizar su estado',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocoSeleccionCard(Map<String, dynamic> foco) {
    final severidad = foco['severidad'] ?? 'Desconocida';
    final severidadColor = _getSeveridadColor(severidad);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _seleccionarFoco(foco),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFED8936).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Foco #${foco['numeroFoco']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFED8936),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: severidadColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      severidad.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: severidadColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.eco, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${foco['plantasAfectadas'] ?? 0} plantas afectadas',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Detectado: ${_formatearFecha(foco['fechaDeteccion'])}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Toca para hacer seguimiento',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFFED8936),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormularioSeguimiento() {
    return Column(
      children: [
        _buildHeaderSeguimiento(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoFocoActual(),
                const SizedBox(height: 20),
                _buildFormularioActualizacion(),
                const SizedBox(height: 100), // Espacio para botón flotante
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSeguimiento() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFED8936),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  focoSeleccionado = null;
                  _limpiarFormulario();
                });
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seguimiento Foco #${focoSeleccionado!['numeroFoco']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Semana ${_calcularSemanaInicio(focoSeleccionado!['fechaDeteccion'])}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoFocoActual() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFED8936).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: const Color(0xFFED8936)),
              const SizedBox(width: 8),
              const Text(
                'Información del Foco',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFED8936),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildInfoItem('Foco ID', '#${focoSeleccionado!['numeroFoco']}'),
          _buildInfoItem(
            'Semana de Inicio',
            'Semana ${_calcularSemanaInicio(focoSeleccionado!['fechaDeteccion'])}',
          ),
          _buildInfoItem(
            'Plantas Afectadas Iniciales',
            '${focoSeleccionado!['plantasAfectadas']} plantas',
          ),
          _buildInfoItem(
            'Fecha Detección',
            _formatearFecha(focoSeleccionado!['fechaDeteccion']),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildFormularioActualizacion() {
    return Column(
      children: [
        // Campos numéricos
        _buildCard(
          title: 'Plantas Afectadas Actuales',
          icon: Icons.eco,
          child: TextField(
            controller: _plantasAfectadasController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Número actual de plantas afectadas',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.eco_outlined),
            ),
          ),
        ),
        const SizedBox(height: 16),

        _buildCard(
          title: 'Plantas Inyectadas',
          icon: Icons.medical_services,
          child: TextField(
            controller: _plantasInyectadasController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Número de plantas inyectadas',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.medical_services_outlined),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Medidas de control (switches)
        _buildCard(
          title: 'Medidas de Control Implementadas',
          icon: Icons.security,
          child: Column(
            children: [
              _buildSwitchItem('Control de vectores', _controlVectores, (
                value,
              ) {
                setState(() {
                  _controlVectores = value;
                });
              }),
              _buildSwitchItem('Cuarentena activa', _cuarentenaActiva, (value) {
                setState(() {
                  _cuarentenaActiva = value;
                });
              }),
              _buildSwitchItem(
                'Única entrada habilitada',
                _unicaEntradaHabilitada,
                (value) {
                  setState(() {
                    _unicaEntradaHabilitada = value;
                  });
                },
              ),
              _buildSwitchItem(
                'Eliminación de maleza hospedera',
                _eliminacionMalezaHospedera,
                (value) {
                  setState(() {
                    _eliminacionMalezaHospedera = value;
                  });
                },
              ),
              _buildSwitchItem(
                'Control de picudo aplicado',
                _controlPicudoAplicado,
                (value) {
                  setState(() {
                    _controlPicudoAplicado = value;
                  });
                },
              ),
              _buildSwitchItem(
                'Inspección a plantas vecinas',
                _inspeccionPlantasVecinas,
                (value) {
                  setState(() {
                    _inspeccionPlantasVecinas = value;
                  });
                },
              ),
              _buildSwitchItem('Corte del riego', _corteRiego, (value) {
                setState(() {
                  _corteRiego = value;
                });
              }),
              _buildSwitchItem('Pediluvio activo', _pediluvioActivo, (value) {
                setState(() {
                  _pediluvioActivo = value;
                });
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // PPM Solución desinfectante
        _buildCard(
          title: 'PPM Solución Desinfectante',
          icon: Icons.science,
          child: TextField(
            controller: _ppmSolucionController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Concentración en PPM',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.science_outlined),
              suffixText: 'PPM',
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Botón de guardar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _guardarSeguimiento,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFED8936),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSaving
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Guardando...'),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save),
                      SizedBox(width: 8),
                      Text(
                        'Guardar Seguimiento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFED8936), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFED8936),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitchItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFED8936),
          ),
        ],
      ),
    );
  }

  void _seleccionarFoco(Map<String, dynamic> foco) {
    setState(() {
      focoSeleccionado = foco;
      // Pre-llenar algunos campos con valores actuales si existen
      _plantasAfectadasController.text = (foco['plantasAfectadas'] ?? 0)
          .toString();
    });
  }

  void _limpiarFormulario() {
    _plantasAfectadasController.clear();
    _plantasInyectadasController.clear();
    _ppmSolucionController.clear();

    setState(() {
      _controlVectores = false;
      _cuarentenaActiva = false;
      _unicaEntradaHabilitada = false;
      _eliminacionMalezaHospedera = false;
      _controlPicudoAplicado = false;
      _inspeccionPlantasVecinas = false;
      _corteRiego = false;
      _pediluvioActivo = false;
    });
  }

  Future<void> _guardarSeguimiento() async {
    if (!_validarFormulario()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Preparar datos para guardar
      Map<String, dynamic> datosSeguimiento = {
        'focoId': focoSeleccionado!['id'],
        'numeroFoco': focoSeleccionado!['numeroFoco'],
        'semanaInicio': _calcularSemanaInicio(
          focoSeleccionado!['fechaDeteccion'],
        ),
        'plantasAfectadas': int.tryParse(_plantasAfectadasController.text) ?? 0,
        'plantasInyectadas':
            int.tryParse(_plantasInyectadasController.text) ?? 0,
        'controlVectores': _controlVectores,
        'cuarentenaActiva': _cuarentenaActiva,
        'unicaEntradaHabilitada': _unicaEntradaHabilitada,
        'eliminacionMalezaHospedera': _eliminacionMalezaHospedera,
        'controlPicudoAplicado': _controlPicudoAplicado,
        'inspeccionPlantasVecinas': _inspeccionPlantasVecinas,
        'corteRiego': _corteRiego,
        'pediluvioActivo': _pediluvioActivo,
        'ppmSolucionDesinfectante':
            int.tryParse(_ppmSolucionController.text) ?? 0,
      };

      // Guardar en la base de datos
      await _seguimientoMokoService.guardarSeguimiento(datosSeguimiento);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seguimiento guardado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Volver a la lista de focos
        setState(() {
          focoSeleccionado = null;
          _limpiarFormulario();
        });

        // Recargar los datos
        _initializeData();
      }
    } catch (e) {
      _showError('Error al guardar seguimiento: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  bool _validarFormulario() {
    if (_plantasAfectadasController.text.isEmpty) {
      _showError('Debe ingresar el número de plantas afectadas');
      return false;
    }

    if (_plantasInyectadasController.text.isEmpty) {
      _showError('Debe ingresar el número de plantas inyectadas');
      return false;
    }

    return true;
  }

  Color _getSeveridadColor(String severidad) {
    switch (severidad.toLowerCase()) {
      case 'bajo':
        return Colors.green;
      case 'medio':
        return Colors.orange;
      case 'alto':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatearFecha(String? fecha) {
    if (fecha == null) return 'Sin fecha';

    try {
      final DateTime dt = DateTime.parse(fecha);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  int _calcularSemanaInicio(String? fecha) {
    if (fecha == null) return 1;

    try {
      final DateTime fechaDeteccion = DateTime.parse(fecha);
      final DateTime inicioAno = DateTime(fechaDeteccion.year, 1, 1);
      final int diasDesdeFecha = fechaDeteccion.difference(inicioAno).inDays;
      return (diasDesdeFecha / 7).ceil() + 1;
    } catch (e) {
      return 1;
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _plantasAfectadasController.dispose();
    _plantasInyectadasController.dispose();
    _ppmSolucionController.dispose();
    super.dispose();
  }
}
