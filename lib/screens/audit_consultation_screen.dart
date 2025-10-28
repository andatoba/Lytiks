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
  String _selectedFilter = 'Todas';
  final List<String> _filters = ['Todas', 'Moko', 'Sigatoka', 'Regular'];

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

  void _performSearch() {
    final searchQuery = _searchController.text.toLowerCase();

    if (searchQuery.isEmpty) {
      setState(() {
        _filteredAudits = List.from(_audits);
      });
      return;
    }

    setState(() {
      _filteredAudits = _audits.where((audit) {
        final clientName = (audit['clientName'] ?? '').toString().toLowerCase();
        final auditType = (audit['type'] ?? '').toString().toLowerCase();
        final date = (audit['date'] ?? '').toString().toLowerCase();
        final status = (audit['status'] ?? '').toString().toLowerCase();

        return clientName.contains(searchQuery) ||
            auditType.contains(searchQuery) ||
            date.contains(searchQuery) ||
            status.contains(searchQuery);
      }).toList();
    });
  }

  void _onFilterChanged(String? newFilter) {
    if (newFilter != null) {
      setState(() {
        _selectedFilter = newFilter;
      });

      // Aplicar filtro local
      if (newFilter == 'Todas') {
        setState(() {
          _filteredAudits = List.from(_audits);
        });
      } else {
        setState(() {
          _filteredAudits = _audits.where((audit) {
            final auditType = (audit['type'] ?? '').toString();
            return auditType == newFilter;
          }).toList();
        });
      }

      // Aplicar búsqueda si hay texto en el campo
      if (_searchController.text.isNotEmpty) {
        _performSearch();
      }
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

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
              hintText: 'Buscar por cliente, fecha o tipo...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Filtrar por tipo:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  isExpanded: true,
                  items: _filters.map((filter) {
                    return DropdownMenuItem(value: filter, child: Text(filter));
                  }).toList(),
                  onChanged: _onFilterChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuditList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAudits,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_filteredAudits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No se encontraron auditorías',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
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
    final String clientName = audit['clientName'] ?? 'Cliente Desconocido';
    final String date =
        audit['date'] ?? DateTime.now().toString().split(' ')[0];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status),
          child: Icon(_getAuditIcon(auditType), color: Colors.white, size: 20),
        ),
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
    final String auditType = audit['type'] ?? 'Regular';
    final String clientName = audit['clientName'] ?? 'Cliente Desconocido';
    final String date = audit['date'] ?? 'Fecha no disponible';
    final String status = audit['status'] ?? 'Estado desconocido';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Auditoría $auditType'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cliente: $clientName',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text('Fecha: $date'),
            const SizedBox(height: 8),
            Text('Estado: $status'),
            const SizedBox(height: 8),
            Text('Tipo: $auditType'),
            const SizedBox(height: 16),
            const Text(
              'Funcionalidad de detalles completos en desarrollo...',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
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
