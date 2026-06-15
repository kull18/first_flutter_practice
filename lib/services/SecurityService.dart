import 'dart:io';
import 'package:flutter/foundation.dart'; // Para kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';

class SecurityService {
  /// Ejecuta todas las comprobaciones de seguridad
  static Future<void> checkSecurity() async {
    // 1. Verificar si es Modo Debug
    if (kDebugMode) {
      _showDebugWarning();
      // No retornamos para que también pueda detectar Frida si está presente
    }

    // 2. Verificar Frida
    bool isFridaRunning = await _detectFrida();
    if (isFridaRunning) {
      _showSecurityAlert("Frida Server");
    }
  }

  static Future<bool> _detectFrida() async {
    // Comprobación de Puerto
    try {
      final socket = await Socket.connect('127.0.0.1', 27042, 
          timeout: const Duration(milliseconds: 300));
      await socket.close();
      return true;
    } catch (_) {}

    // Comprobación de Mapas de Memoria (Android)
    try {
      final mapsFile = File('/proc/self/maps');
      if (mapsFile.existsSync()) {
        final content = await mapsFile.readAsString();
        if (content.toLowerCase().contains('frida')) return true;
      }
    } catch (_) {}

    return false;
  }

  static void _showDebugWarning() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Row(
              children: [
                Icon(Icons.bug_report, color: Colors.orange, size: 28),
                SizedBox(width: 10),
                Text('Modo Debug Activo', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: const Text(
              'La aplicación se está ejecutando en un entorno de desarrollo. '
              'La sesión automática ha sido desactivada para facilitar el debug.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }
  }

  static void _showSecurityAlert(String tool) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Row(
              children: [
                Icon(Icons.gpp_bad_outlined, color: Colors.red, size: 28),
                SizedBox(width: 10),
                Text('Amenaza Crítica', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: Text(
              'Se ha detectado la herramienta "$tool". '
              'La aplicación se cerrará por motivos de seguridad.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('CERRAR', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }
  }
}
