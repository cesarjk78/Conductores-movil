import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/secure_storage_service.dart';

class IncidensService {
  static const String baseUrl = "https://backend-tesis-jvfm.onrender.com";

  static Future<List<dynamic>> getIncidentesByConductor() async {
    final dni = await SecureStorageService.getDNI();
    final token = await SecureStorageService.getToken();

    if (dni == null) throw Exception("DNI no encontrado");
    if (token == null) throw Exception("Token no encontrado");

    final url = Uri.parse("$baseUrl/api/incidente/conductor/$dni");


    final res = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);

      // Si viene como: { "incidentes": [ ... ] }
      if (decoded is Map && decoded.containsKey("incidentes")) {
        return decoded["incidentes"];
      }

      // Si viene como lista directa
      if (decoded is List) {
        return decoded;
      }

      throw Exception("El backend no devolvió una lista válida");
    }

    throw Exception("Error al obtener incidentes: ${res.statusCode} - ${res.body}");
  }
}
