// lib/providers/SessionProvider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled1/main.dart';

class SessionProvider extends ChangeNotifier {
  static const int _timeoutSeconds = 15; // 15s pruebas / 300s producción
  Timer? _timer;
  bool _sessionExpired = false;

  bool get sessionExpired => _sessionExpired;

  late final bool Function(KeyEvent) _keyHandler;

  SessionProvider() {
    _keyHandler = (KeyEvent event) {
      resetTimer();
      return false; // No consume el evento, lo deja pasar al árbol de widgets
    };
    HardwareKeyboard.instance.addHandler(_keyHandler);
  }

  void resetTimer() {
    _timer?.cancel();
    _sessionExpired = false;
    _timer = Timer(const Duration(seconds: _timeoutSeconds), _onTimeout);
  }

  void _onTimeout() {
    _sessionExpired = true;
    notifyListeners();
    _navigateToLogin();
  }

  void _navigateToLogin() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false, // Borra toda la pila de navegación
    );

    // Pequeño delay para que la navegación termine antes de mostrar el diálogo
    Future.delayed(const Duration(milliseconds: 300), () {
      final ctx = navigatorKey.currentContext;
      if (ctx == null) return;

      showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lock_clock, color: Colors.red),
              SizedBox(width: 8),
              Text('Sesión Expirada'),
            ],
          ),
          content: const Text(
            'Tu sesión fue cerrada por inactividad por razones de seguridad.',
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                final ctx = navigatorKey.currentContext;
                if (ctx != null) Navigator.of(ctx).pop();
              },
              child: const Text(
                'Entendido',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyHandler);
    _timer?.cancel();
    super.dispose();
  }
}