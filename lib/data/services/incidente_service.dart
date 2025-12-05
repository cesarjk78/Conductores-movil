import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/utils/secure_storage_service.dart';
import '../../data/services/geolocation_service.dart' as gps;

class IncidenteService {
    Future<String?> _getAuthToken() async {
      return await SecureStorageService.getToken();
    }

    Future<bool> _crearincidencia(String dni, String tipo, [String? descripcion]) async {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Token no encontrado, Inicie Sesion Nuevamente');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.crearincidente}');
      final pos = await gps.GeolocationService().getCurrentPosition();
      if (pos == null) {
        throw Exception('El gps no se pudo obtener');
      }

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'dni': dni,
            if (descripcion != null && descripcion.isNotEmpty) 'Descripcion': descripcion,
            'tipo': tipo,
            'latitud': pos.latitude,
            'longitud': pos.longitude,
          }),
        );

        if (response.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    }


    Future<List> _obtenerIncidentes(String dni) async{
      final token = await _getAuthToken();
      if (token == null){
        throw Exception('No hay token, vuelve a iniciar sesion');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.obtenerIncidente}/$dni');

      try{
        final response1 = await http.get(
          url, 
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },

        );

        if (response1.statusCode == 200){
          final List<dynamic> data = jsonDecode(response1.body);
          return data;
        } else {
          throw Exception('Error al obtener incidentes: ${response1.statusCode} - ${response1.body}');
        }
      } catch(e){
          throw Exception('Excepción al obtener incidentes: $e');
      }

    }
}