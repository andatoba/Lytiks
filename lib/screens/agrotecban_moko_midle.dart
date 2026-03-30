import 'package:flutter/material.dart';
import 'agrotecban_moko_contencion.dart';
import 'agrotecban_moko_preventivo.dart';
import '../services/client_service.dart';
import '../services/lote_service.dart';

class AgrotecbanMokoMidleScreen extends StatefulWidget {
  final Map<String, dynamic>? clientData;
  const AgrotecbanMokoMidleScreen({Key? key, this.clientData})
      : super(key: key);

  @override
  State<AgrotecbanMokoMidleScreen> createState() =>
      _AgrotecbanMokoMidleScreenState();
}

class _AgrotecbanMokoMidleScreenState extends State<AgrotecbanMokoMidleScreen> {
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _loteController = TextEditingController();
  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _lotes = [];
  Map<String, dynamic>? _clienteSeleccionado;
  Map<String, dynamic>? _loteSeleccionado;
  bool _isLoadingClientes = false;
  bool _isLoadingLotes = false;

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  void _cargarClientes() async {
    setState(() {
      _isLoadingClientes = true;
    });
    final clientes = await ClientService().getClients();
    setState(() {
      _clientes = clientes;
      _isLoadingClientes = false;
    });
  }

  void _cargarLotes() async {
    setState(() {
      _isLoadingLotes = true;
    });
    final lotes = await LoteService().getAllLotes();
    setState(() {
      _lotes = lotes;
      _isLoadingLotes = false;
    });
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _loteController.dispose();
    super.dispose();
  }

  void _goToContencion() {
    if (_clienteSeleccionado == null || _loteSeleccionado == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgrotecbanMokoContencionScreen(
          clientData: {
            'clienteId': _clienteSeleccionado!['id'],
            'cliente': _clienteSeleccionado!['nombre'],
            'loteId': _loteSeleccionado!['id'],
            'lote': _loteSeleccionado!['nombre'],
          },
        ),
      ),
    );
  }

  void _goToPreventivo() {
    if (_clienteSeleccionado == null || _loteSeleccionado == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgrotecbanMokoPreventivoScreen(
          clientData: {
            'clienteId': _clienteSeleccionado!['id'],
            'cliente': _clienteSeleccionado!['nombre'],
            'loteId': _loteSeleccionado!['id'],
            'lote': _loteSeleccionado!['nombre'],
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auditoria Moko'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _isLoadingClientes
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<Map<String, dynamic>>(
                      value: _clienteSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        border: OutlineInputBorder(),
                      ),
                      items: _clientes
                          .map((cliente) => DropdownMenuItem(
                                value: cliente,
                                child: Text(cliente['nombre']),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _clienteSeleccionado = value;
                          _loteSeleccionado = null;
                          _lotes = [];
                        });
                        _cargarLotes();
                      },
                    ),
              const SizedBox(height: 16),
              _isLoadingLotes
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<Map<String, dynamic>>(
                      value: _loteSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Lote',
                        border: OutlineInputBorder(),
                      ),
                      items: _lotes
                          .map((lote) => DropdownMenuItem(
                                value: lote,
                                child: Text(lote['nombre']),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _loteSeleccionado = value;
                        });
                      },
                    ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: _goToContencion,
                              child: const Text('Programa de Contención'),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _goToPreventivo,
                              child: const Text('Programa Preventivo'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: const Text('Auditoria'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
