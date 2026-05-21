import 'package:detect_fake_location/detect_fake_location.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:screen_protector/screen_protector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bloquear capturas de pantalla
  await ScreenProtector.preventScreenshotOn();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Seguro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  late Future<bool> _checkLocationFuture;

  @override
  void initState() {
    super.initState();
    // Cambiamos la asignación directa por nuestra función que pide permisos primero
    _checkLocationFuture = _verificarPermisosYDetectar();
  }

  // Esta función se encarga de asegurar que existan permisos antes de validar el Fake GPS
  Future<bool> _verificarPermisosYDetectar() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    // --- PLAN B: Preguntarle directamente a Geolocator si la coordenada es falsa ---
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // Baja precisión para que responda rápido
        timeLimit: const Duration(seconds: 5),
      );

      // Devuelve 'true' si el sistema detecta que la coordenada fue alterada/simulada
      return position.isMocked;
    } catch (e) {
      print("Error al obtener posición: $e");
      // Si falla, intentamos usar la otra librería como respaldo
      return await DetectFakeLocation().detectFakeLocation();
    }
  }

  @override
  void dispose() {
    userController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla de Login'),
        centerTitle: true,
      ),
      body: FutureBuilder<bool>(
        future: _checkLocationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error al verificar la seguridad del dispositivo.'),
            );
          }

          final bool isFakeLocation = snapshot.data ?? false;

          if (isFakeLocation) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Corregido para centrar el contenido verticalmente
                  children: const [
                    Icon(Icons.gpp_bad, size: 80, color: Colors.red),
                    SizedBox(height: 20),
                    Text(
                      'Acceso Denegado',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Se ha detectado un servicio de ubicación falsa activo. Desactívalo para poder ingresar a la aplicación.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock, size: 80, color: Colors.blue),
                      const SizedBox(height: 20),
                      const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: userController,
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Usuario: ${userController.text}',
                              ),
                            ),
                          );
                        },
                        child: const Text('Ingresar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}