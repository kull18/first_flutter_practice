import 'dart:io';
import 'package:flutter/foundation.dart'; // Para kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';

class SecurityService {
  static const MethodChannel _adbChannel = MethodChannel('security/adb');

  static Future<bool> _isAdbEnabled() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool enabled = await _adbChannel.invokeMethod('isAdbEnabled');
      return enabled;
    } catch (e) {
      debugPrint("Error verificando ADB: $e");
      return false;
    }
  }

  static void _showAdbAlert() {
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
                Icon(Icons.usb_off, color: Colors.red, size: 28),
                SizedBox(width: 10),
                Text('Depuración USB Detectada', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: const Text(
              'Por motivos de seguridad, esta aplicación no puede ejecutarse '
                  'mientras la Depuración USB esté activa en tu dispositivo.\n\n'
                  'Para continuar, desactívala desde:\n'
                  'Ajustes → Opciones de desarrollador → Depuración USB.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text(
                  'CERRAR APLICACIÓN',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  /// Ejecuta todas las comprobaciones de seguridad
  static Future<void> checkSecurity() async {
    if (kDebugMode) {
      _showDebugWarning();
    } else {
      final bool adbEnabled = await _isAdbEnabled();
      if (adbEnabled) {
        _showAdbAlert();
        return; // No seguimos evaluando si ya está bloqueado
      }
    }

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
