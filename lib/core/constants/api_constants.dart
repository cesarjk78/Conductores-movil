class ApiConstants {
  static const String baseUrl = 'https://backend-tesis-jvfm.onrender.com';
  static const String loginEndpoint = '/api/auth/login/conductor';
  static const String logoutEndpoint = '/auth/logout';
  static const String obtenerViajes = '/api/viaje/conductores';
  static const String cambiarEstadoViaje = '/api/viaje/cambiar-estado';

  //INCIDENTE
  static const String crearincidente = '/api/incidente/create';
  static const String obtenerIncidente = 'api/incidente/conductor';

  
  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}