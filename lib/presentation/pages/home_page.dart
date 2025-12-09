import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../../data/services/weather_service.dart';
import '../../data/services/obtenerViaje.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final weatherService = WeatherService();
  final conductorService = ConductorService();


  double? _currentTemp;
  String? _currentLocation;
  bool _loadingWeather = true;

  bool _loadingViajes = true;
  List<dynamic> _viajes = [];
  String _tipoViaje = ''; // "En curso" o "Pendientes"

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final info = await weatherService.getWeatherInfo();

      final district = info['district'] as String?;
      final province = info['province'] as String?;
      final locationText = (district != null && province != null)
          ? "$district, $province"
          : district ?? province ?? "Ubicación desconocida";

      setState(() {
        _currentTemp = info['temperature'];
        _currentLocation = locationText;
        _loadingWeather = false;
      });
    } catch (e) {
      print("❌ Error al cargar el clima: $e");
      setState(() => _loadingWeather = false);
    }
  }

  Future<void> _loadViajes(String dni) async {
    try {
      final enCurso = await conductorService.getViajesEnCurso(dni);

      if (enCurso.isNotEmpty) {
        setState(() {
          _viajes = enCurso;
          _tipoViaje = "En curso";
          _loadingViajes = false;
        });
      } else {
        final pendientes = await conductorService.getViajesPendientes(dni);
        setState(() {
          _viajes = pendientes;
          _tipoViaje = "Pendientes";
          _loadingViajes = false;
        });
      }
    } catch (e) {
      print("❌ Error al cargar viajes: $e");
      setState(() => _loadingViajes = false);
    }
  }

  Future<void> _iniciarViaje(BuildContext context, String idViaje) async {

    final exito = await ConductorService().cambiarEstadoViaje(idViaje, 'en-curso');

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Viaje finalizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ No se pudo finalizar el viaje'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6B4582);
    const Color secondaryColor = Color(0xFFE4E4E4);
    const Color textColor = Color(0xFF333333);

    return ChangeNotifierProvider<HomeController>(
      create: (_) => HomeController()..loadUser(),
      child: Consumer<HomeController>(
        builder: (context, controller, child) {
          if (controller.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = controller.user;
          if (user == null) {
            return const Scaffold(
              body: Center(child: Text('Usuario no encontrado')),
            );
          }

          if (_loadingViajes) {
            _loadViajes(user.identificacion);
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              title: const Text(
                'La Perla de Altomayo',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('👋', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 8),
                      Text(
                        '¡Bienvenido, ${user.nombres}!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildUserCard(user, secondaryColor),
                  const SizedBox(height: 20),
                  _buildBusWeatherCard(secondaryColor),
                  const SizedBox(height: 20),
                  if (_loadingViajes)
                    const Center(child: CircularProgressIndicator())
                  else if (_viajes.isEmpty)
                    const Center(child: Text('No hay viajes disponibles.'))
                  else
                    _buildViajesList(),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => controller.logout(),
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ----------------- COMPONENTES REUTILIZABLES -----------------

  Widget _buildUserCard(dynamic user, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('👤 ${user.nombres} ${user.apellidos}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('📧 Correo: ${user.email}', style: const TextStyle(fontSize: 16)),
          Text('🆔 DNI: ${user.identificacion}', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBusWeatherCard(Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bus n. 4521', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Siguiente parada', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.cloud, color: Colors.grey),
              Text(
                _loadingWeather
                    ? '...'
                    : _currentTemp != null
                        ? '${_currentTemp!.toStringAsFixed(1)}°C'
                        : 'N/D',
                style: const TextStyle(fontSize: 16),
              ),
              Text(_currentLocation ?? 'Ubicación...', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViajesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🚌 Viajes $_tipoViaje', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._viajes.map((v) => _buildViajeCard(v)).toList(),
      ],
    );
  }

Widget _buildViajeCard(dynamic viaje) {
  const Color cardColor = Color(0xFFE4E4E4);

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          viaje['ruta_id']?['nombre'] ?? 'Ruta desconocida',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text('Origen: ${viaje['origen'] ?? '---'}',
            style: const TextStyle(fontSize: 15)),
        Text('Destino: ${viaje['destino'] ?? '---'}',
            style: const TextStyle(fontSize: 15)),

        const SizedBox(height: 12),

        // Mostrar botón solo si el viaje es pendiente
        if (_tipoViaje == "Pendientes")
          ElevatedButton(
            onPressed: () {
              final idViaje = viaje['_id'];
              _iniciarViaje(context, idViaje);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Empezar viaje",
              style: TextStyle(color: Colors.white),
            ),
          ),
      ],
    ),
  );
}

}


