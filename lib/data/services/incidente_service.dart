import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/utils/secure_storage_service.dart';
import 'geolocation_service.dart' as gps;

class IncidenteService {
  // Obtenemos el token de autenticación
  Future<String?> _getAuthToken() async {
    return await SecureStorageService.getToken();
  }

  // Obtenemos el DNI guardado del usuario actual
  Future<String?> _getUsuarioDNI() async {
    return await SecureStorageService.getDNI(); // <- aquí guardas el DNI al login
  }

Future<bool> crearIncidencia(String tipo, [String? descripcion]) async {
    // 🔹 Obtenemos el DNI desde el storage
    final dni = await _getUsuarioDNI();
    if (dni == null) throw Exception('No se encontró el DNI del usuario');

    // 🔹 Obtenemos el token
    final token = await _getAuthToken();
    if (token == null) throw Exception('Token no encontrado');

    // 🔹 Obtenemos la ubicación
    final pos = await gps.GeolocationService().getCurrentPosition();
    if (pos == null) throw Exception('No se pudo obtener GPS');

    // 🔹 Enviamos la incidencia al backend
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.crearincidente}');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'dni': dni,  // aquí usamos el DNI obtenido
        'tipo': tipo,
        if (descripcion != null && descripcion.isNotEmpty) 'Descripcion': descripcion,
        'latitud': pos.latitude,
        'longitud': pos.longitude,
      }),
    );

    print('Status code POST: ${response.statusCode}');
    print('Response POST: ${response.body}');

    return response.statusCode == 201;
}

}
