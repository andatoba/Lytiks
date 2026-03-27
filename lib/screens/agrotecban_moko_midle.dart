import 'package:flutter/material.dart';
import 'agrotecban_moko_contencion.dart';
import 'agrotecban_moko_preventivo.dart';

class AgrotecbanMokoMidleScreen extends StatefulWidget {
  final Map<String, dynamic>? clientData;
  const AgrotecbanMokoMidleScreen({Key? key, this.clientData}) : super(key: key);

  @override
  State<AgrotecbanMokoMidleScreen> createState() => _AgrotecbanMokoMidleScreenState();
}

class _AgrotecbanMokoMidleScreenState extends State<AgrotecbanMokoMidleScreen> {
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _loteController = TextEditingController();

  @override
  void dispose() {
    _clienteController.dispose();
    _loteController.dispose();
    super.dispose();
  }

  void _goToContencion() {
    if (_clienteController.text.isEmpty || _loteController.text.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgrotecbanMokoContencionScreen(
          clientData: {
            'cliente': _clienteController.text,
            'lote': _loteController.text,
          },
        ),
      ),
    );
  }

  void _goToPreventivo() {
    if (_clienteController.text.isEmpty || _loteController.text.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgrotecbanMokoPreventivoScreen(
          clientData: {
            'cliente': _clienteController.text,
            'lote': _loteController.text,
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
              TextField(
                controller: _clienteController,
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _loteController,
                decoration: const InputDecoration(
                  labelText: 'Lote',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
