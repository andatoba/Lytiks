import 'dart:async';
import 'package:flutter/material.dart';
import '../services/registro_moko_service.dart';
import 'plan_seguimiento_moko_screen.dart';

class ListaFocosScreen extends StatefulWidget {
  const ListaFocosScreen({super.key});

  @override
  State<ListaFocosScreen> createState() => _ListaFocosScreenState();
}

class _ListaFocosScreenState extends State<ListaFocosScreen> {
  // Servicios
  final RegistroMokoService _registroMokoService = RegistroMokoService();

  // Estado
  List<Map<String, dynamic>> focos = [];
  List<Map<String, dynamic>> focosFiltrados = [];
  bool _isLoading = true;
  String _filtroSeveridad = 'Todos';
  String _busquedaTexto = '';

  // Controladores
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarFocos();
  }

  Future<void> _cargarFocos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final registros = await _registroMokoService.getRegistros();
      setState(() {
        focos = registros;
        focosFiltrados = registros;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error al cargar focos: $e');
    }
  }

  void _aplicarFiltros() {
    setState(() {
      focosFiltrados = focos.where((foco) {
        // Filtro por severidad
        bool pasaSeveridad =
            _filtroSeveridad == 'Todos' ||
            (foco['severidad']?.toLowerCase() ==
                _filtroSeveridad.toLowerCase());

        // Filtro por texto de búsqueda
        bool pasaBusqueda =
            _busquedaTexto.isEmpty ||
            foco['numeroFoco'].toString().contains(_busquedaTexto) ||
            (foco['observaciones']?.toLowerCase().contains(
                  _busquedaTexto.toLowerCase(),
                ) ??
                false);

        return pasaSeveridad && pasaBusqueda;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF38A169),
        title: const Text(
          'Lista de Focos',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarFocos,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltros(),
          Expanded(child: _isLoading ? _buildLoading() : _buildLista()),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por número o observaciones...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _busquedaTexto.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _busquedaTexto = '';
                        });
                        _aplicarFiltros();
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _busquedaTexto = value;
              });
              _aplicarFiltros();
            },
          ),
          const SizedBox(height: 12),

          // Filtros de severidad
          Row(
            children: [
              const Text(
                'Severidad: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Todos', 'Bajo', 'Medio', 'Alto'].map((
                      severidad,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(severidad),
                          selected: _filtroSeveridad == severidad,
                          selectedColor: _getSeveridadColor(
                            severidad,
                          ).withOpacity(0.3),
                          onSelected: (selected) {
                            setState(() {
                              _filtroSeveridad = severidad;
                            });
                            _aplicarFiltros();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),

          // Contador de resultados
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${focosFiltrados.length} de ${focos.length} focos',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando focos...'),
        ],
      ),
    );
  }

  Widget _buildLista() {
    if (focosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              focos.isEmpty
                  ? 'No hay focos registrados'
                  : 'No se encontraron focos con los filtros aplicados',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            if (focos.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filtroSeveridad = 'Todos';
                    _busquedaTexto = '';
                    _searchController.clear();
                  });
                  _aplicarFiltros();
                },
                child: const Text('Limpiar filtros'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarFocos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: focosFiltrados.length,
        itemBuilder: (context, index) {
          final foco = focosFiltrados[index];
          return _buildFocoCard(foco);
        },
      ),
    );
  }

  Widget _buildFocoCard(Map<String, dynamic> foco) {
    final severidad = foco['severidad'] ?? 'Desconocida';
    final severidadColor = _getSeveridadColor(severidad);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: severidadColor.withOpacity(0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _verDetallesFoco(foco),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con número y severidad
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38A169).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Foco #${foco['numeroFoco']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF38A169),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: severidadColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSeveridadIcon(severidad),
                          size: 16,
                          color: severidadColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          severidad.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: severidadColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Información principal
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      foco['gpsCoordinates'] ?? 'Sin coordenadas',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              Row(
                children: [
                  Icon(Icons.eco, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${foco['plantasAfectadas'] ?? 0} plantas afectadas',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatearFecha(foco['fechaDeteccion']),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),

              if (foco['observaciones'] != null &&
                  foco['observaciones'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  foco['observaciones'],
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 8),

              // Footer con método y acciones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      foco['metodoComprobacion']?.toUpperCase() ?? 'N/A',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (foco['fotoPath'] != null) ...[
                        Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 8),
                      ],
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  IconData _getSeveridadIcon(String severidad) {
    switch (severidad.toLowerCase()) {
      case 'bajo':
        return Icons.check_circle;
      case 'medio':
        return Icons.warning;
      case 'alto':
        return Icons.dangerous;
      default:
        return Icons.help_outline;
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

  void _verDetallesFoco(Map<String, dynamic> foco) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetallesFoco(foco),
    );
  }

  Widget _buildDetallesFoco(Map<String, dynamic> foco) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Foco #${foco['numeroFoco']}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Contenido
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetalleItem(
                        'Número de Foco',
                        foco['numeroFoco'].toString(),
                      ),
                      _buildDetalleItem(
                        'Coordenadas GPS',
                        foco['gpsCoordinates'] ?? 'Sin coordenadas',
                      ),
                      _buildDetalleItem(
                        'Plantas Afectadas',
                        '${foco['plantasAfectadas'] ?? 0}',
                      ),
                      _buildDetalleItem(
                        'Fecha de Detección',
                        _formatearFecha(foco['fechaDeteccion']),
                      ),
                      _buildDetalleItem(
                        'Severidad',
                        foco['severidad'] ?? 'Desconocida',
                      ),
                      _buildDetalleItem(
                        'Método Comprobación',
                        foco['metodoComprobacion'] ?? 'No especificado',
                      ),
                      if (foco['observaciones'] != null &&
                          foco['observaciones'].toString().isNotEmpty)
                        _buildDetalleItem(
                          'Observaciones',
                          foco['observaciones'],
                        ),

                      if (foco['fotoPath'] != null) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Foto del Foco:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Foto almacenada en servidor'),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Botón para Plan de Seguimiento
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlanSeguimientoMokoScreen(
                                  focoId: foco['id'] ?? 0,
                                  numeroFoco: foco['numeroFoco'] ?? 0,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.assignment, color: Colors.white),
                          label: const Text(
                            'PLAN DE SEGUIMIENTO',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A365D),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetalleItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF38A169),
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
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
    _searchController.dispose();
    super.dispose();
  }
}
