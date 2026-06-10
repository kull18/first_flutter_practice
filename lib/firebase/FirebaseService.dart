import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/main.dart'; // Para acceder al navigatorKey
import 'package:untitled1/services/RemoteWipeService.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("--- Mensaje recibido en SEGUNDO PLANO ---");
  
  final action = message.data["action"];
  final userId = message.data["userId"];

  if (action == "delete_sensitive_data") {
    await Remotewipeservice().execute(userId);
    print('Datos eliminados desde segundo plano');
  }
}

class Firebaseservice {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    String? token = await _messaging.getToken();
    print("========= TOKEN FCM =========");
    print(token);
    print("=============================");


    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("--- Mensaje recibido en PRIMER PLANO ---");
      
      final action = message.data["action"];
      final userId = message.data["userId"];

      if (action == "delete_sensitive_data") {
        await Remotewipeservice().execute(userId);
        print('Datos eliminados en primer plano');
        
        // Mostrar la alerta en pantalla
        _showWipeDialog();
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('El usuario abrió la app desde una notificación');
    });
  }

  void _showWipeDialog() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text('Alerta de Seguridad'),
            ],
          ),
          content: const Text(
            'Se ha ejecutado una orden de borrado remoto. '
            'Toda la información sensible ha sido eliminada por seguridad.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }
}
