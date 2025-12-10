import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> planes = [
    {
      "hora": "08:00 AM",
      "titulo": "Revisión de unidad",
      "descripcion": "Verificar estado general del bus.",
      "icono": Icons.build_circle_outlined
    },
    {
      "hora": "10:30 AM",
      "titulo": "Punto de control",
      "descripcion": "Llegada al punto de control principal.",
      "icono": Icons.location_on_outlined
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF4EB),
      appBar: AppBar(
        title: const Text(
          'Mis planes',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5E4B8A),
        child: const Icon(Icons.add),
        onPressed: () {
          _mostrarFormulario(context);
        },
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: Image.asset(
                'assets/porqmiras.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Itinerario de hoy",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5E4B8A),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: planes.map((p) => _buildPlanCard(p)).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(plan["icono"], size: 40, color: const Color(0xFF5E4B8A)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan["hora"],
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(plan["titulo"],
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(plan["descripcion"],
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarFormulario(BuildContext context) {
    final TextEditingController horaCtrl = TextEditingController();
    final TextEditingController tituloCtrl = TextEditingController();
    final TextEditingController descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar plan"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: horaCtrl,
                  decoration: const InputDecoration(
                      labelText: "Hora (ej: 09:00 AM)"),
                ),
                TextField(
                  controller: tituloCtrl,
                  decoration: const InputDecoration(labelText: "Título"),
                ),
                TextField(
                  controller: descCtrl,
                  decoration:
                      const InputDecoration(labelText: "Descripción"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  planes.add({
                    "hora": horaCtrl.text,
                    "titulo": tituloCtrl.text,
                    "descripcion": descCtrl.text,
                    "icono": Icons.event_note_outlined
                  });
                });
                Navigator.pop(context);
              },
              child: const Text("Agregar"),
            )
          ],
        );
      },
    );
  }
}