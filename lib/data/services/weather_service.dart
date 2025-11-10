import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Define el tiempo de vida (Time-To-Live) de los datos en caché: 5 minutos.
const Duration CACHE_DURATION = Duration(minutes: 5);

class WeatherService {
  // --- Variables para el Cacheo ---
  Map<String, dynamic>? _cachedInfo;
  DateTime? _lastFetchTime;

  /// Obtiene la ubicación actual del usuario
  Future<Position?> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
  }

  /// === Funciones Auxiliares de Obtención de Datos ===

  Future<Map<String, String?>> _fetchLocationDetails(double lat, double lon) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'FlutterApp/1.0 (marcelo@example.com)'
      });

      if (response.statusCode == 200) {
        final address = jsonDecode(response.body)['address'];

        // 🎯 AJUSTE CLAVE: Prioriza 'village' y 'state'
        final district = address?['village'] ?? address?['suburb'] ?? address?['county'] ?? address?['municipality'];
        final province = address?['state'] ?? address?['province'];
        
        return {'district': district as String?, 'province': province as String?};
      }
    } catch (e) {
      print('Error al obtener el nombre de la ubicación: $e');
    }
    return {'district': null, 'province': null};
  }

  Future<double?> _fetchTemperature(double lat, double lon) async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m';
    
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final tempValue = jsonDecode(response.body)['current']?['temperature_2m'];
        if (tempValue is num) return tempValue.toDouble();
      }
    } catch (e) {
      print('Error al obtener la temperatura: $e');
    }
    return null;
  }

  // === Función Central de Cacheo ===

  /// Devuelve un mapa con la temperatura, distrito y provincia.
  Future<Map<String, dynamic>> getWeatherInfo() async {
    // 1. VERIFICAR CACHÉ
    if (_cachedInfo != null && _lastFetchTime != null) {
      final timeElapsed = DateTime.now().difference(_lastFetchTime!);

      if (timeElapsed < CACHE_DURATION) {
        return _cachedInfo!;
      }
    }

    // 2. OBTENER POSICIÓN
    final position = await _getCurrentPosition();
    if (position == null) {
      return {'district': null, 'province': null, 'temperature': null};
    }

    final lat = position.latitude;
    final lon = position.longitude;

    // 3. OBTENER DATOS FRESCOS
    final temperatureFuture = _fetchTemperature(lat, lon);
    final locationFuture = _fetchLocationDetails(lat, lon);

    final results = await Future.wait([temperatureFuture, locationFuture]);

    final temperature = results[0] as double?;
    final location = results[1] as Map<String, String?>;

    final freshData = {
      'district': location['district'], 
      'province': location['province'], 
      'temperature': temperature
    };

    // 4. ACTUALIZAR CACHÉ
    if (temperature != null || location['district'] != null || location['province'] != null) {
      _cachedInfo = freshData;
      _lastFetchTime = DateTime.now();
    }

    return freshData;
  }

  // === Método Solicitado: Devuelve Distrito y Provincia en Texto ===
  
  /// Devuelve la ubicación en formato de texto: "Distrito, Provincia"
  /// Ej: "La Pampa, Ancash"
  Future<String?> getDistrictProvinceText() async {
    // Llama al método con caché.
    final info = await getWeatherInfo();
    
    final district = info['district'] as String?;
    final province = info['province'] as String?;

    if (district != null && province != null) {
      // Si ambos existen, devuelve "Distrito, Provincia"
      return '$district, $province';
    } else if (district != null) {
      // Si solo existe el distrito, devuelve solo el distrito
      return district;
    } else if (province != null) {
      // Si solo existe la provincia, devuelve solo la provincia
      return province;
    }
    
    return null;
  }

  // MÉTODOS SIMPLIFICADOS
  
  Future<double?> getCurrentTemperature() async {
    final info = await getWeatherInfo();
    return info['temperature'] as double?;
  }
}