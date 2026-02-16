import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/logo_service.dart';

/// Widget que carga y muestra el logo activo desde la base de datos
/// Si falla o no existe, muestra el logo por defecto de assets
class DynamicLogoWidget extends StatefulWidget {
  final double? height;
  final double? width;
  final BoxFit fit;
  final String fallbackAsset;

  const DynamicLogoWidget({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.fallbackAsset = 'assets/images/logo1.png',
  });

  @override
  State<DynamicLogoWidget> createState() => _DynamicLogoWidgetState();
}

class _DynamicLogoWidgetState extends State<DynamicLogoWidget> {
  final LogoService _logoService = LogoService();
  Map<String, dynamic>? _logoData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadLogo();
  }

  Future<void> _loadLogo() async {
    try {
      final logoData = await _logoService.getLogoActivo();
      setState(() {
        _logoData = logoData;
        _isLoading = false;
        _hasError = logoData == null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: widget.height,
        width: widget.width,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Si hay error o no hay logo, mostrar el fallback
    if (_hasError || _logoData == null) {
      return Image.asset(
        widget.fallbackAsset,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
      );
    }

    // Intentar mostrar logo desde base64 primero
    final logoBase64 = _logoData!['logoBase64'];
    if (logoBase64 != null && logoBase64.toString().isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(logoBase64.toString()),
          height: widget.height,
          width: widget.width,
          fit: widget.fit,
          errorBuilder: (context, error, stackTrace) {
            // Si falla decodificar, usar fallback
            return Image.asset(
              widget.fallbackAsset,
              height: widget.height,
              width: widget.width,
              fit: widget.fit,
            );
          },
        );
      } catch (e) {
        // Error al decodificar base64, usar ruta o fallback
      }
    }

    // Si no hay base64, intentar con ruta_logo
    final rutaLogo = _logoData!['rutaLogo'];
    if (rutaLogo != null && rutaLogo.toString().isNotEmpty) {
      return Image.network(
        rutaLogo.toString(),
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            height: widget.height,
            width: widget.width,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // Si falla cargar desde URL, usar fallback
          return Image.asset(
            widget.fallbackAsset,
            height: widget.height,
            width: widget.width,
            fit: widget.fit,
          );
        },
      );
    }

    // Si no hay base64 ni ruta, usar fallback
    return Image.asset(
      widget.fallbackAsset,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
    );
  }
}
