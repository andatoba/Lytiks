import 'package:flutter/material.dart';

/// Utilidades comunes para la aplicación Lytiks
class LytiksUtils {
  /// Colores del tema de la aplicación
  static const Color primaryColor = Color(0xFF004B63);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;
  static const Color errorColor = Colors.red;

  /// Muestra un SnackBar con mensaje de éxito
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Muestra un SnackBar con mensaje de error
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: errorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Muestra un SnackBar con mensaje de advertencia
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: warningColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Muestra un SnackBar con información
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Estilo de botón estándar para la aplicación
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  /// Estilo de botón secundario
  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.grey.shade200,
    foregroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  /// Decoración de contenedor estándar
  static BoxDecoration containerDecoration = BoxDecoration(
    border: Border.all(color: Colors.grey.shade300),
    borderRadius: BorderRadius.circular(8),
  );

  /// Decoración de contenedor con gradiente
  static BoxDecoration gradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryColor.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
    ),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: primaryColor.withOpacity(0.2)),
  );

  /// Validador de campo requerido
  static String? requiredFieldValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido';
    }
    return null;
  }

  /// Validador de email
  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingrese un email válido';
    }

    return null;
  }

  /// Validador de teléfono
  static String? phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido';
    }

    final phoneRegex = RegExp(r'^\d{8,15}$');
    if (!phoneRegex.hasMatch(
      value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), ''),
    )) {
      return 'Ingrese un teléfono válido';
    }

    return null;
  }

  /// Formatea un número como porcentaje
  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  /// Convierte una calificación a color
  static Color getRatingColor(String rating) {
    switch (rating.toLowerCase()) {
      case 'alto':
        return successColor;
      case 'medio':
        return warningColor;
      case 'bajo':
        return errorColor;
      default:
        return Colors.grey;
    }
  }

  /// Obtiene el color de puntuación basado en porcentaje
  static Color getScoreColor(double percentage) {
    if (percentage >= 80) return successColor;
    if (percentage >= 50) return warningColor;
    return errorColor;
  }
}
