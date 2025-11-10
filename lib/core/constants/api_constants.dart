class ApiConstants {
  static const String baseUrl = 'https://backend-tesis-jvfm.onrender.com';
  static const String loginEndpoint = '/api/auth/login/conductor';
  static const String logoutEndpoint = '/auth/logout';
  static const String obtenerViajes = '/api/viaje/conductores';
  
  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}