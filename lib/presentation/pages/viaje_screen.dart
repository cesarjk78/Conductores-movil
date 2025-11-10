// viaje_screen.dart (MapaPage)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../../data/services/obtenerViaje.dart';

class MapaPage extends StatelessWidget {
  const MapaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = context.watch<HomeController>();
    final dni = homeController.user?.identificacion ?? '';

    if (dni.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('DNI no disponible')),
      );
    }

    return FutureBuilder<List<dynamic>>(
      future: ConductorService().getViajesEnCurso(dni),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error al cargar viajes: ${snapshot.error}')),
          );
        }

        final viajes = snapshot.data;
        if (viajes == null || viajes.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('No hay viajes en curso')),
          );
        }

        final viaje = viajes.first;
        final ruta = viaje['ruta_id']?['nombre'] ?? 'Ruta desconocida';
        final origen = viaje['ruta_id']?['paraderos']?[0]?['nombre'] ?? '---';
        final destino = viaje['ruta_id']?['paraderos']?.last?['nombre'] ?? '---';
        final bus = viaje['bus_id']?['placa'] ?? '---';
        final conductor = '${viaje['conductor_id']?['datos_personal']?['nombres'] ?? ''} '
            '${viaje['conductor_id']?['datos_personal']?['apellidos'] ?? ''}';

        return Scaffold(
          backgroundColor: const Color(0xFFEFE8EF),
          appBar: AppBar(
            title: Text('Mapa del viaje: $ruta'),
            backgroundColor: const Color(0xFF673AB7),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.brown, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/busgira.gif',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    ruta,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('Origen: $origen', style: const TextStyle(fontSize: 16)),
                  Text('Destino: $destino', style: const TextStyle(fontSize: 16)),
                  Text('Bus: $bus', style: const TextStyle(fontSize: 16)),
                  Text('Conductor: $conductor', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('En ruta', style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 8),
                        Row(children: [_buildDot(), _buildDot(), _buildDot()]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildActionButton('EMERGENCIA TOTAL', const Color(0xFFB71C1C)),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  const SizedBox(height: 40),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF673AB7),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Finalizar viaje',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(String text, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      width: 8.0,
      height: 8.0,
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
    );
  }
}
