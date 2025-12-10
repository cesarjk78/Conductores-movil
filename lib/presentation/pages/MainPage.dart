// main_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../widgets/BottomNav.dart';
import 'home_page.dart';
import 'viaje_screen.dart';
import 'chatsi_page.dart';
import 'incidencias_page.dart';
import 'historial_incidentes_page.dart';

class PerfilPage extends StatelessWidget {
  final Map<String, dynamic> user;
  const PerfilPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Perfil de ${user['nombres']}',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeController>(
      create: (_) => HomeController()..loadUser(),
      child: Consumer<HomeController>(
        builder: (context, controller, child) {
          // Mientras carga el usuario
          if (controller.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Si no hay usuario
          final user = controller.user;
          if (user == null) {
            return const Scaffold(
              body: Center(child: Text('Usuario no encontrado')),
            );
          }

          // Construimos las páginas usando HomeController
          final pages = [
            HomePage(),
            const MapaPage(),
            ChatPage(),
            IncidenciasPage(),
            HistorialIncidentesPage(),

          ];

          return Scaffold(
            body: pages[_currentIndex],
            bottomNavigationBar: BottomNav(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          );
        },
      ),
    );
  }
}
