import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/secure_storage_service.dart';
import '../../core/constants/api_constants.dart';

class ConductorService {
  /// 🔹 Obtiene el token JWT guardado en el almacenamiento seguro
  Future<String?> _getAuthToken() async {
    return await SecureStorageService.getToken();
  }

  /// 🔹 Hace una petición GET al endpoint con el tipo indicado
  Future<List<dynamic>> _getViajes(String dni, String tipo) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('❌ Token no encontrado. Inicia sesión nuevamente.');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.obtenerViajes}/$dni/$tipo');
    print('🌐 GET => $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded;
        } else {
          print('⚠️ La respuesta no es una lista: $decoded');
          return [];
        }
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('💥 Error al obtener viajes: $e');
      return [];
    }
  }

  /// 🚦 Obtiene los viajes del conductor con estado "pendiente"
  Future<List<dynamic>> getViajesPendientes(String dni) async {
    print('🕓 Buscando viajes pendientes para DNI: $dni');
    return await _getViajes(dni, 'pendiente');
  }

  /// 🛣️ Obtiene los viajes del conductor con estado "en_curso"
  Future<List<dynamic>> getViajesEnCurso(String dni) async {
    print('🚗 Buscando viajes en curso para DNI: $dni');
    return await _getViajes(dni, 'curso');
  }

    /// 🔁 Cambia el estado de un viaje (pendiente ⇄ en_curso)
  Future<bool> cambiarEstadoViaje(String idViaje, String nuevoEstado) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('❌ Token no encontrado. Inicia sesión nuevamente.');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.cambiarEstadoViaje}');
    print('📤 POST => $url');
    print('📝 Datos => {id_viaje: $idViaje, estado: $nuevoEstado}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id_viaje': idViaje,
          'estado': nuevoEstado,
        }),
      );

      print('📥 Respuesta (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Estado de viaje actualizado correctamente.');
        return true;
      } else {
        print('❌ Error al cambiar estado: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('💥 Error en la petición POST: $e');
      return false;
    }
  }
}
