import 'package:flutter/material.dart';
import '../services/is_usuarios_service.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final IsUsuariosService _service = IsUsuariosService();
  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> _roles = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final usuarios = await _service.getAllUsuarios();
      final roles = await _service.getRoles();
      setState(() {
        _usuarios = usuarios;
        _roles = roles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredUsuarios {
    if (_searchQuery.isEmpty) return _usuarios;
    return _usuarios.where((user) {
      final searchLower = _searchQuery.toLowerCase();
      return (user['usuario']?.toString().toLowerCase().contains(searchLower) ?? false) ||
          (user['nombres']?.toString().toLowerCase().contains(searchLower) ?? false) ||
          (user['apellidos']?.toString().toLowerCase().contains(searchLower) ?? false) ||
          (user['correo']?.toString().toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  void _showUsuarioDialog({Map<String, dynamic>? usuario}) {
    final isEditing = usuario != null;
    final usuarioController = TextEditingController(text: usuario?['usuario'] ?? '');
    final nombresController = TextEditingController(text: usuario?['nombres'] ?? '');
    final apellidosController = TextEditingController(text: usuario?['apellidos'] ?? '');
    final correoController = TextEditingController(text: usuario?['correo'] ?? '');
    final telefonoController = TextEditingController(text: usuario?['telefono_cel'] ?? '');
    final cedulaController = TextEditingController(text: usuario?['cedula'] ?? '');
    final passwordController = TextEditingController();
    
    int? selectedRolId = usuario?['id_roles'];
    bool accesoAppMovil = usuario?['acceso_app_movil'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Editar Usuario' : 'Nuevo Usuario'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usuarioController,
                    enabled: !isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Usuario *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nombresController,
                    decoration: const InputDecoration(
                      labelText: 'Nombres *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: apellidosController,
                    decoration: const InputDecoration(
                      labelText: 'Apellidos *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: correoController,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: telefonoController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: cedulaController,
                    decoration: const InputDecoration(
                      labelText: 'Cédula',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: isEditing ? 'Nueva Contraseña (dejar vacío para no cambiar)' : 'Contraseña *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedRolId,
                    decoration: const InputDecoration(
                      labelText: 'Rol',
                      border: OutlineInputBorder(),
                    ),
                    items: _roles.map((rol) {
                      return DropdownMenuItem<int>(
                        value: rol['id'],
                        child: Text(rol['nombre'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedRolId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Acceso a App Móvil'),
                    subtitle: const Text('Permitir inicio de sesión desde la aplicación móvil'),
                    value: accesoAppMovil,
                    onChanged: (value) {
                      setDialogState(() => accesoAppMovil = value ?? false);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validaciones
                if (usuarioController.text.isEmpty || nombresController.text.isEmpty || apellidosController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Completa los campos obligatorios'), backgroundColor: Colors.orange),
                  );
                  return;
                }

                if (!isEditing && passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('La contraseña es obligatoria'), backgroundColor: Colors.orange),
                  );
                  return;
                }

                try {
                  final userData = {
                    'usuario': usuarioController.text,
                    'nombres': nombresController.text,
                    'apellidos': apellidosController.text,
                    'correo': correoController.text,
                    'telefono_cel': telefonoController.text,
                    'cedula': cedulaController.text,
                    'id_roles': selectedRolId,
                    'acceso_app_movil': accesoAppMovil,
                    'usuario_actual': 'ADMIN',
                  };

                  if (passwordController.text.isNotEmpty) {
                    userData['password'] = passwordController.text;
                  }

                  if (isEditing) {
                    await _service.updateUsuario(usuario['id'], userData);
                  } else {
                    await _service.createUsuario(userData);
                  }

                  Navigator.pop(context);
                  _loadData();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEditing ? 'Usuario actualizado' : 'Usuario creado'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: Text(isEditing ? 'Actualizar' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleAccesoApp(Map<String, dynamic> usuario) async {
    final nuevoAcceso = !(usuario['acceso_app_movil'] ?? false);
    try {
      await _service.cambiarAccesoApp(usuario['id'], nuevoAcceso);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nuevoAcceso ? 'Acceso concedido' : 'Acceso revocado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _toggleEstado(Map<String, dynamic> usuario) async {
    final nuevoEstado = usuario['estado'] == 'A' ? 'I' : 'A';
    try {
      await _service.cambiarEstado(usuario['id'], nuevoEstado);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nuevoEstado == 'A' ? 'Usuario activado' : 'Usuario desactivado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _resetPassword(Map<String, dynamic> usuario) {
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetear Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Usuario: ${usuario['usuario']}'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nueva Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingresa una contraseña'), backgroundColor: Colors.orange),
                );
                return;
              }

              try {
                await _service.resetPassword(usuario['id'], passwordController.text);
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contraseña restablecida'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Resetear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestión de Usuarios',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Administra usuarios y permisos de acceso',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showUsuarioDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Nuevo Usuario'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Búsqueda
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar usuarios...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsuarios.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty ? 'No hay usuarios registrados' : 'No se encontraron usuarios',
                              style: const TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24.0),
                        itemCount: _filteredUsuarios.length,
                        itemBuilder: (context, index) {
                          final usuario = _filteredUsuarios[index];
                          final isActive = usuario['estado'] == 'A';
                          final hasAppAccess = usuario['acceso_app_movil'] ?? false;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isActive ? Colors.blue : Colors.grey,
                                child: Text(
                                  (usuario['nombres'] ?? 'U')[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                '${usuario['nombres']} ${usuario['apellidos']}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Usuario: ${usuario['usuario']}'),
                                  Text('Rol: ${usuario['rol'] ?? 'Sin rol'}'),
                                  if (usuario['correo'] != null) Text('Correo: ${usuario['correo']}'),
                                ],
                              ),
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  // Badge de estado
                                  Chip(
                                    label: Text(isActive ? 'Activo' : 'Inactivo', style: const TextStyle(fontSize: 12)),
                                    backgroundColor: isActive ? Colors.green[100] : Colors.red[100],
                                    side: BorderSide.none,
                                  ),
                                  // Badge de acceso app
                                  Chip(
                                    avatar: Icon(
                                      hasAppAccess ? Icons.phone_android : Icons.phone_android_outlined,
                                      size: 16,
                                      color: hasAppAccess ? Colors.white : Colors.grey,
                                    ),
                                    label: Text(
                                      hasAppAccess ? 'App' : 'Sin app',
                                      style: TextStyle(fontSize: 12, color: hasAppAccess ? Colors.white : Colors.grey),
                                    ),
                                    backgroundColor: hasAppAccess ? Colors.blue : Colors.grey[200],
                                    side: BorderSide.none,
                                  ),
                                  // Menú de acciones
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'edit':
                                          _showUsuarioDialog(usuario: usuario);
                                          break;
                                        case 'toggle_status':
                                          _toggleEstado(usuario);
                                          break;
                                        case 'toggle_app':
                                          _toggleAccesoApp(usuario);
                                          break;
                                        case 'reset_password':
                                          _resetPassword(usuario);
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 20),
                                            SizedBox(width: 8),
                                            Text('Editar'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'toggle_status',
                                        child: Row(
                                          children: [
                                            Icon(isActive ? Icons.block : Icons.check_circle, size: 20),
                                            const SizedBox(width: 8),
                                            Text(isActive ? 'Desactivar' : 'Activar'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'toggle_app',
                                        child: Row(
                                          children: [
                                            Icon(hasAppAccess ? Icons.phone_disabled : Icons.phone_android, size: 20),
                                            const SizedBox(width: 8),
                                            Text(hasAppAccess ? 'Revocar acceso app' : 'Conceder acceso app'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'reset_password',
                                        child: Row(
                                          children: [
                                            Icon(Icons.lock_reset, size: 20),
                                            SizedBox(width: 8),
                                            Text('Resetear contraseña'),
                                          ],
                                        ),
                                      ),
                                    ],
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
    );
  }
}
