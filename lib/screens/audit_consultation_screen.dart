import 'package:flutter/material.dart';
import '../services/audit_management_service.dart';

class AuditConsultationScreen extends StatefulWidget {
  const AuditConsultationScreen({super.key});

  @override
  State<AuditConsultationScreen> createState() =>
      _AuditConsultationScreenState();
}

class _AuditConsultationScreenState extends State<AuditConsultationScreen> {
    final TextEditingController _searchController = TextEditingController();
    final AuditManagementService _auditService = AuditManagementService();
    List<Map<String, dynamic>> _audits = [];
    List<Map<String, dynamic>> _filteredAudits = [];
    bool _isLoading = true;
    String _errorMessage = '';

    @override
    void initState() {
      super.initState();
      _loadAudits();
      _searchController.addListener(_performSearch);
    }

    @override
    void dispose() {
      _searchController.dispose();
      super.dispose();
    }

    Future<void> _loadAudits() async {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        final audits = await _auditService.getAllAudits();
        setState(() {
          _audits = audits;
          _filteredAudits = audits;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Error al cargar auditorías: $e';
          _isLoading = false;
        });
      }
    }

    Future<void> _performSearch() async {
      final searchQuery = _searchController.text.trim();
      if (searchQuery.isEmpty) {
        setState(() {
          _filteredAudits = List.from(_audits);
        });
        return;
      }
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        final audits = await _auditService.getAuditsByCedula(searchQuery);
        setState(() {
          _audits = audits;
          _filteredAudits = audits;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Error al buscar auditorías: $e';
          _isLoading = false;
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: const Color(0xFF004B63),
          title: const Text(
            'Consulta de Auditorías',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            _buildSearchHeader(),
            Expanded(child: _buildAuditList()),
          ],
        ),
      );
    }
  // --- FUNCIONES AUXILIARES ---
  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por número de cédula de cliente...',
              prefixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _performSearch(),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Solo búsqueda por cédula
        ],
      ),
    );
  }

  Widget _buildAuditList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }
    if (_filteredAudits.isEmpty) {
      return const Center(child: Text('No hay auditorías para mostrar.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredAudits.length,
      itemBuilder: (context, index) {
        return _buildAuditCard(_filteredAudits[index]);
      },
    );
  }

  Widget _buildAuditCard(Map<String, dynamic> audit) {
    final String auditType = audit['type'] ?? 'Regular';
    final String status = audit['status'] ?? 'Completada';
    final String clientName = audit['nombreCliente'] ?? 'Cliente Desconocido';
    final String date = audit['date'] ?? DateTime.now().toString().split(' ')[0];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
    // ...existing code...
        title: Text(
          '$auditType - $clientName',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('Fecha: $date'), Text('Estado: $status')],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showAuditDetails(context, audit);
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completada':
        return Colors.green;
      case 'Pendiente':
        return Colors.orange;
      case 'En Progreso':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getAuditIcon(String type) {
    switch (type) {
      case 'Moko':
        return Icons.security;
      case 'Sigatoka':
        return Icons.biotech;
      case 'Regular':
        return Icons.assignment;
      default:
        return Icons.description;
    }
  }

  void _showAuditDetails(BuildContext context, Map<String, dynamic> audit) {
    final String auditType = audit['tipo'] ?? audit['type'] ?? 'Regular';
    final String clientName = audit['nombreCliente'] ?? 'Cliente Desconocido';
    final String date = audit['fecha']?.toString() ?? audit['date'] ?? 'Fecha no disponible';
    final String status = audit['estadoGeneral'] ?? audit['estado'] ?? audit['status'] ?? 'Estado desconocido';
    final String lote = audit['lote']?.toString() ?? '';
    final String observaciones = audit['observaciones']?.toString() ?? '';
    final String recomendaciones = audit['recomendaciones']?.toString() ?? '';
    final String severidad = audit['severidad']?.toString() ?? '';
    final String cultivo = audit['cultivo']?.toString() ?? audit['tipoCultivo']?.toString() ?? '';
    final String areaHectareas = audit['areaHectareas']?.toString() ?? '';
    final String plantasAfectadas = audit['plantasAfectadas']?.toString() ?? '';
    final String numeroFoco = audit['numeroFoco']?.toString() ?? '';
    final String nivelAnalisis = audit['nivelAnalisis']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Auditoría $auditType'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cliente/Hacienda: $clientName', style: const TextStyle(fontWeight: FontWeight.w500)),
              if (lote.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Lote: $lote'),
              ],
              if (cultivo.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Cultivo: $cultivo'),
              ],
              if (numeroFoco.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('N° Foco: $numeroFoco'),
              ],
              if (plantasAfectadas.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Plantas afectadas: $plantasAfectadas'),
              ],
              if (areaHectareas.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Área (ha): $areaHectareas'),
              ],
              if (severidad.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Severidad: $severidad'),
              ],
              if (nivelAnalisis.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Nivel de análisis: $nivelAnalisis'),
              ],
              const SizedBox(height: 8),
              Text('Fecha: $date'),
              const SizedBox(height: 8),
              Text('Estado: $status'),
              const SizedBox(height: 8),
              Text('Tipo: $auditType'),
              if (observaciones.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Observaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(observaciones),
              ],
              if (recomendaciones.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Recomendaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(recomendaciones),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
