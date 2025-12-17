import 'package:flutter/material.dart';
import '../services/registro_moko_service.dart';
import 'guardar_aplicacion_screen.dart';

class ContencionScreen extends StatefulWidget {
  final Map<String, dynamic>? clientData;

  const ContencionScreen({super.key, this.clientData});

  @override
  State<ContencionScreen> createState() => _ContencionScreenState();
}

class _ContencionScreenState extends State<ContencionScreen> {
  final RegistroMokoService _service = RegistroMokoService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _productos = [];
  // IDs de productos ya configurados
  List<int> productosConfigurados = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadProductos();
  }

  Future<void> _loadProductos() async {
    try {
      final productos = await _service.getProductos();
      setState(() {
        _productos = productos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contención'),
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Error: $_error'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Selecciona un producto para la contención:',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFFE53E3E),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _productos.length,
                        itemBuilder: (context, index) {
                          final p = _productos[index];
                          final int? productoId = p['id'] is int ? p['id'] : int.tryParse(p['id']?.toString() ?? '');
                          final bool yaConfigurado = productoId != null && productosConfigurados.contains(productoId);
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p['nombre'] ?? 'Sin nombre',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.inventory_2,
                                        color: Color(0xFF718096),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Presentación: ${p['presentacion'] ?? 'N/A'}',
                                        style: const TextStyle(
                                          color: Color(0xFF718096),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.science,
                                        color: Color(0xFF718096),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Dosis: ${p['dosisSugerida'] ?? 'N/A'}',
                                          style: const TextStyle(
                                            color: Color(0xFF718096),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: yaConfigurado
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'Ya configurado',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          )
                                        : ElevatedButton(
                                            onPressed: () async {
                                              // Navegar y esperar resultado
                                              final resultado = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => GuardarAplicacionScreen(
                                                    clientData: widget.clientData,
                                                    producto: p,
                                                  ),
                                                ),
                                              );
                                              // Si se configuró, agregar a la lista
                                              if (resultado == true && productoId != null) {
                                                setState(() {
                                                  productosConfigurados.add(productoId);
                                                });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFE53E3E),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'Configurar Aplicación',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _initProductos,
        backgroundColor: const Color(0xFFE53E3E),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Future<void> _initProductos() async {
    try {
      await _service.initProductos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Productos inicializados correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      _loadProductos(); // Recargar la lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al inicializar productos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
