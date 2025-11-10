// lib/services/geolocation_service.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Servicio singleton que encapsula la geolocalización.
/// Provee:
/// - requestPermissionIfNeeded()
/// - getCurrentPosition()
/// - getLastKnownPosition()
/// - positionStream (para escuchar actualizaciones)
/// - stopPositionStream()
class GeolocationService {
  GeolocationService._internal();
  static final GeolocationService _instance = GeolocationService._internal();
  factory GeolocationService() => _instance;

  StreamSubscription<Position>? _positionSub;
  final StreamController<Position> _positionController =
      StreamController<Position>.broadcast();

  /// Exponer stream público (broadcast) para múltiples listeners
  Stream<Position> get positionStream => _positionController.stream;

  /// Verifica permisos y solicita si es necesario.
  /// Devuelve true si al final hay permiso.
  Future<bool> requestPermissionIfNeeded() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Permiso denegado permanentemente.
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Verifica que el servicio de localización esté activo.
  Future<bool> ensureLocationServiceEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      // Puedes intentar abrir la configuración con Geolocator.openLocationSettings()
      // pero eso depende de la UX que quieras.
      return false;
    }
    return true;
  }

  /// Obtiene la posición actual (espera a obtenerla).
  /// Retorna null si no hay permiso o el servicio no está habilitado.
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    final hasPermission = await requestPermissionIfNeeded();
    if (!hasPermission) return null;

    final serviceEnabled = await ensureLocationServiceEnabled();
    if (!serviceEnabled) return null;

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeLimit,
      );
      return pos;
    } catch (e) {
      // Manejo simple de errores (puedes registrar/loggear)
      return null;
    }
  }

  /// Devuelve la última posición conocida (sin forzar nueva lectura).
  Future<Position?> getLastKnownPosition() async {
    try {
      final pos = await Geolocator.getLastKnownPosition();
      return pos;
    } catch (e) {
      return null;
    }
  }

/// Inicia la escucha en segundo plano (stream) y publica posiciones en positionStream.
/// Si ya hay una suscripción activa, no crea otra.
/// [distanceFilter] en metros, [intervalDuration] para frecuencia mínima.
void startPositionStream({
  LocationAccuracy accuracy = LocationAccuracy.best,
  int distanceFilter = 10,
  Duration intervalDuration = const Duration(seconds: 10),
}) {
  if (_positionSub != null) return; // ya escuchando

  // ✅ Usa la clase específica para Android (puedes ajustar para otras plataformas)
  final locationSettings = AndroidSettings(
    accuracy: accuracy,
    distanceFilter: distanceFilter,
    intervalDuration: intervalDuration,
    forceLocationManager: false,
    foregroundNotificationConfig: const ForegroundNotificationConfig(
      notificationText:
          "La app está recibiendo tu ubicación en segundo plano.",
      notificationTitle: "Rastreo activo",
      enableWakeLock: true,
    ),
  );

  _positionSub = Geolocator.getPositionStream(locationSettings: locationSettings)
      .listen((pos) {
    _positionController.add(pos);
  }, onError: (err) {
    // Manejo opcional de errores
  });
}


  /// Detiene la escucha del stream (libera recursos).
  Future<void> stopPositionStream() async {
    await _positionSub?.cancel();
    _positionSub = null;
  }

  /// Limpia recursos del service (usar cuando app se cierra o ya no necesites)
  Future<void> dispose() async {
    await stopPositionStream();
    await _positionController.close();
  }
}
