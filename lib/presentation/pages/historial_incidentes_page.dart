import 'package:flutter/material.dart';
import '../../data/services/incidens_service.dart';

class HistorialIncidentesPage extends StatefulWidget {
  @override
  State<HistorialIncidentesPage> createState() => _HistorialIncidentesPageState();
}

class _HistorialIncidentesPageState extends State<HistorialIncidentesPage> {
  late Future<List<dynamic>> _futureIncidentes;

  @override
  void initState() {
    super.initState();
    _futureIncidentes = IncidensService.getIncidentesByConductor();
  }

  // Función para formatear fecha 
  String formatFecha(String fechaIso) {
    try {
      if (fechaIso.isEmpty) return "";
      DateTime dt = DateTime.parse(fechaIso).toLocal();
      return "${dt.day.toString().padLeft(2, '0')}/"
             "${dt.month.toString().padLeft(2, '0')}/"
             "${dt.year}";
    } catch (e) {
      return "";
    }
  }

  // Función para formatear hora
  String formatHora(String fechaIso) {
    try {
      if (fechaIso.isEmpty) return "";
      DateTime dt = DateTime.parse(fechaIso).toLocal(); // <-- aLocal
      return "${dt.hour.toString().padLeft(2, '0')}:"
             "${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF4EB),
      appBar: AppBar(
        title: const Text(
          "Historial de Incidentes",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
        shadowColor: Colors.black26,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder(
        future: _futureIncidentes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final incidentes = snapshot.data!;

          if (incidentes.isEmpty) {
            return const Center(
              child: Text(
                "No tienes incidentes enviados.",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            );
          }

          return ListView.builder(
            itemCount: incidentes.length,
            itemBuilder: (context, index) {
              final item = incidentes[index];
              final tipo = item["tipo"] ?? "Sin tipo";

              final fechaIso = item["createdAt"] ?? "";
              final fecha = formatFecha(fechaIso);
              final hora = formatHora(fechaIso);

              return Card(
                color: Colors.white,
                elevation: 3,
                shadowColor: Colors.black12,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(
                    tipo,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    "Fecha: $fecha\nHora: $hora",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
